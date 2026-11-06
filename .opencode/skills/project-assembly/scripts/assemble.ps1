<#
.SYNOPSIS
    project-assembly — 按 projects/<项目>/assembly.json 把资产子集导出到业务仓。

.DESCRIPTION
    单向导出：本仓平台目录是唯一真源，脚本只往 -Target 写，**从不回写本仓**。

    复制什么：
      规则     include 展开后减掉 exclude（cursor 取 .mdc，opencode 取 .md；dsh 无规则）
      Agent    按清单（cursor 用 agents/，opencode 用 agent/）
      Skill    整个目录（含 references/ scripts/）
      入口     assembly.entry 里列出的文件或目录（如 AGENTS.md、docs/）

    不做什么：
      不合并 opencode.json / mcp.json 之类配置文件（会覆盖用户配置）；
      不删除目标里多出来的文件；
      不改写本仓任何内容。

.PARAMETER Project
    projects/ 下的目录名，必须与 assembly.json 的 project 字段一致。

.PARAMETER Target
    业务仓根目录；不存在会自动创建。

.PARAMETER Platforms
    覆盖 assembly.json 的平台选择，可选 cursor / opencode / dsh。

.PARAMETER DryRun
    只打印计划，不复制。

.PARAMETER Force
    目标已存在且内容不同时覆盖（默认跳过并提示）。

.EXAMPLE
    .\assemble.ps1 -Project source-manager -Target D:\tmp\demo -DryRun

.EXAMPLE
    .\assemble.ps1 -Project source-manager -Target D:\Project\SourceManager
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Project,

    [Parameter(Mandatory = $true)]
    [string]$Target,

    [string[]]$Platforms = @(),

    [switch]$DryRun,

    [switch]$Force,

    [string]$Root = ''
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

if ([string]::IsNullOrWhiteSpace($Root)) {
    $gitRoot = (& git rev-parse --show-toplevel 2>$null) -join ''
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($gitRoot)) { $Root = $gitRoot }
    else { $Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path }
}
$Root = (Resolve-Path -LiteralPath $Root).Path

# ---------- 读装配单 ----------
$asmPath = Join-Path $Root "projects/$Project/assembly.json"
if (-not (Test-Path -LiteralPath $asmPath)) {
    Write-Host "找不到装配单：projects/$Project/assembly.json" -ForegroundColor Red
    exit 1
}
try { $asm = Get-Content -LiteralPath $asmPath -Raw -Encoding UTF8 | ConvertFrom-Json }
catch { Write-Host "装配单解析失败：$($_.Exception.Message)" -ForegroundColor Red; exit 1 }

if ($asm.project -ne $Project) {
    Write-Host "assembly.json 的 project 是 '$($asm.project)'，与目录名 '$Project' 不一致" -ForegroundColor Red
    exit 1
}

$plats = $Platforms
if ($null -eq $plats -or $plats.Count -eq 0) { $plats = @($asm.platforms) }
$valid = @('cursor', 'opencode', 'dsh')
foreach ($p in $plats) {
    if ($valid -notcontains $p) { Write-Host "不支持的平台：$p" -ForegroundColor Red; exit 1 }
}

# ---------- 安全边界 ----------
$targetFull = [System.IO.Path]::GetFullPath($Target)
if ($targetFull.TrimEnd('\', '/') -eq $Root.TrimEnd('\', '/')) {
    Write-Host '拒绝：目标不能是本仓根目录' -ForegroundColor Red
    exit 1
}
$insideRepo = $targetFull.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)
if ($insideRepo) {
    Write-Host "拒绝：目标落在本仓内部（$targetFull），导出只写外部路径" -ForegroundColor Red
    exit 1
}

# ---------- 规则集合 ----------
$allRules = @(Get-ChildItem -LiteralPath (Join-Path $Root '.cursor/rules') -Filter '*.mdc' | ForEach-Object { $_.BaseName })
$includeHits = @()
foreach ($pat in @($asm.rules.include)) {
    if ([string]::IsNullOrWhiteSpace($pat)) { continue }
    $includeHits += @($allRules | Where-Object { $_ -like $pat })
}
$excludeHits = @()
foreach ($pat in @($asm.rules.exclude)) {
    if ([string]::IsNullOrWhiteSpace($pat)) { continue }
    $excludeHits += @($allRules | Where-Object { $_ -like $pat })
}
$rules = @($includeHits | Where-Object { $excludeHits -notcontains $_ } | Sort-Object -Unique)
$skills = @($asm.skills | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
$agents = @($asm.agents | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)

# ---------- 复制实现 ----------
$script:copied = 0
$script:same = 0
$script:diff = 0
$script:missing = @()

function Copy-OneFile {
    param([string]$SrcRel, [string]$DstRel)
    $src = Join-Path $Root $SrcRel
    $dst = Join-Path $targetFull $DstRel
    if (-not (Test-Path -LiteralPath $src)) { $script:missing += $SrcRel; return }
    if (Test-Path -LiteralPath $dst) {
        $a = [System.IO.File]::ReadAllBytes($src)
        $b = [System.IO.File]::ReadAllBytes($dst)
        $sameBytes = ($a.Length -eq $b.Length)
        if ($sameBytes) {
            for ($i = 0; $i -lt $a.Length; $i++) { if ($a[$i] -ne $b[$i]) { $sameBytes = $false; break } }
        }
        if ($sameBytes) { $script:same++; return }
        if (-not $Force) { $script:diff++; return }
    }
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path (Split-Path $dst -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
    $script:copied++
}

function Copy-OneDir {
    param([string]$SrcRel, [string]$DstRel)
    $srcRoot = Join-Path $Root $SrcRel
    if (-not (Test-Path -LiteralPath $srcRoot)) { $script:missing += $SrcRel; return }
    Get-ChildItem -LiteralPath $srcRoot -Recurse -File | ForEach-Object {
        $inner = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/')
        Copy-OneFile -SrcRel ($SrcRel + '/' + ($inner -replace '\\', '/')) -DstRel ($DstRel + '/' + ($inner -replace '\\', '/'))
    }
}

# ---------- 组计划 ----------
foreach ($plat in $plats) {
    if ($plat -eq 'cursor') {
        foreach ($r in $rules) { Copy-OneFile ".cursor/rules/$r.mdc" ".cursor/rules/$r.mdc" }
        foreach ($a in $agents) { Copy-OneFile ".cursor/agents/$a.md" ".cursor/agents/$a.md" }
        foreach ($s in $skills) { Copy-OneDir ".cursor/skills/$s" ".cursor/skills/$s" }
    }
    elseif ($plat -eq 'opencode') {
        foreach ($r in $rules) { Copy-OneFile ".opencode/rules/$r.md" ".opencode/rules/$r.md" }
        foreach ($a in $agents) { Copy-OneFile ".opencode/agent/$a.md" ".opencode/agent/$a.md" }
        foreach ($s in $skills) { Copy-OneDir ".opencode/skills/$s" ".opencode/skills/$s" }
    }
    else {
        foreach ($s in $skills) { Copy-OneDir ".dsh/skills/$s" ".dsh/skills/$s" }
    }
}

foreach ($e in @($asm.entry)) {
    if ([string]::IsNullOrWhiteSpace($e)) { continue }
    $p = Join-Path $Root $e
    if (-not (Test-Path -LiteralPath $p)) { $script:missing += $e; continue }
    if (Test-Path -LiteralPath $p -PathType Container) { Copy-OneDir $e $e }
    else { Copy-OneFile $e $e }
}

# ---------- 汇总 ----------
$mode = if ($DryRun) { '（dry-run，未写盘）' } else { '' }
Write-Host ''
Write-Host "project-assembly  $Project -> $targetFull $mode" -ForegroundColor Cyan
Write-Host ("  平台   {0}" -f ($plats -join ', '))
Write-Host ("  规则   {0} / {1}（排除 {2}）" -f $rules.Count, $allRules.Count, $excludeHits.Count)
Write-Host ("  Skill  {0}     Agent {1}" -f $skills.Count, $agents.Count)
Write-Host ("  结果   copied={0}  same={1}  diff={2}  missing={3}" -f $script:copied, $script:same, $script:diff, $script:missing.Count)

if ($script:diff -gt 0) { Write-Host '  已有不同内容的文件被跳过；确认要覆盖请加 -Force' -ForegroundColor Yellow }
if ($script:missing.Count -gt 0) {
    Write-Host '  缺失的源文件：' -ForegroundColor Red
    $script:missing | Select-Object -Unique | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
}

Write-Host ''
Write-Host '还需要手动做：' -ForegroundColor Yellow
Write-Host '  - opencode.json：把入口规则加进 instructions，合并 mcp（脚本不动配置）'
Write-Host '  - constraints.md：填 {占位符}'
Write-Host '  - 若目标已有同名资产且你选了跳过，按 diff 手动决定'
Write-Host ''

if ($script:missing.Count -gt 0) { exit 1 }
exit 0
