param(
    [string]$Root = (Get-Location).Path,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$errors = New-Object System.Collections.ArrayList
$warnings = New-Object System.Collections.ArrayList

function Add-Err([string]$m) { [void]$errors.Add($m) }
function Add-Warn([string]$m) { [void]$warnings.Add($m) }

$loopDir = Join-Path $Root 'docs\loop'
if (-not (Test-Path $loopDir)) {
    if ($Json) { '{ "ok": true, "epics": 0, "errors": [], "warnings": ["no docs/loop"] }' }
    else { Write-Host 'check-loop  ok  （没有 docs/loop，跳过）' }
    exit 0
}

$statusEnum = @('draft', 'ready-for-dev', 'in-progress', 'in-review', 'built', 'done', 'blocked', 'dropped')
$transitions = @{
    'draft'         = @('ready-for-dev', 'dropped')
    'ready-for-dev' = @('in-progress', 'blocked', 'dropped')
    'in-progress'   = @('in-review', 'blocked', 'dropped')
    'in-review'     = @('built', 'blocked', 'in-progress')
    'built'         = @('done', 'in-review')
    'done'          = @('in-review')
    'blocked'       = @('in-progress', 'dropped')
    'dropped'       = @()
}

function Get-Ids([string]$text, [string]$prefix) {
    $set = @{}
    foreach ($m in [regex]::Matches($text, "(?m)^\|\s*($prefix-\d+)\s*\|")) { $set[$m.Groups[1].Value] = $true }
    return $set
}

function Get-Refs([string]$text, [string]$pattern) {
    $set = @{}
    foreach ($m in [regex]::Matches($text, $pattern)) { $set[$m.Groups[0].Value] = $true }
    return $set
}

$epics = Get-ChildItem $loopDir -Directory | Sort-Object Name
$count = 0

foreach ($e in $epics) {
    $count++
    $specPath = Join-Path $e.FullName 'spec.md'
    $planPath = Join-Path $e.FullName 'plan.md'
    $tasksPath = Join-Path $e.FullName 'tasks.md'
    $statePath = Join-Path $e.FullName 'state.md'
    $ledgerPath = Join-Path $e.FullName 'ledger.md'
    $name = $e.Name

    foreach ($p in @($specPath, $planPath, $tasksPath, $statePath)) {
        if (-not (Test-Path $p)) { Add-Err "${name}: 缺少 $([System.IO.Path]::GetFileName($p))" }
    }
    if ($errors.Count -gt 0) { continue }

    $spec = [System.IO.File]::ReadAllText($specPath)
    $plan = [System.IO.File]::ReadAllText($planPath)
    $tasks = [System.IO.File]::ReadAllText($tasksPath)
    $state = [System.IO.File]::ReadAllText($statePath)

    $caps = Get-Ids $spec 'CAP'
    $acs = Get-Ids $spec 'AC'
    $rs = Get-Ids $spec 'R'
    $sts = Get-Ids $plan 'ST'
    $ts = @{}
    foreach ($m in [regex]::Matches($tasks, '(?m)^##\s+(T-\d+)\b')) { $ts[$m.Groups[1].Value] = $true }

    if ($caps.Count -eq 0) { Add-Err "${name}: spec 里没有 CAP" }
    if ($acs.Count -eq 0) { Add-Err "${name}: spec 里没有 AC" }

    # AC -> CAP
    foreach ($m in [regex]::Matches($spec, '(?m)^\|\s*(AC-\d+)\s*\|\s*(CAP-\d+)\s*\|')) {
        $ac = $m.Groups[1].Value; $cap = $m.Groups[2].Value
        if (-not $caps.ContainsKey($cap)) { Add-Err "${name}: $ac 引用了不存在的 $cap" }
    }
    # T -> AC
    foreach ($m in [regex]::Matches($tasks, '(?m)^-\s*挂 AC[：:]\s*(.+)$')) {
        $tn = 'T-?'
        $line = $m.Groups[1].Value
        foreach ($am in [regex]::Matches($line, 'AC-\d+')) {
            if (-not $acs.ContainsKey($am.Value)) { Add-Err "${name}: 任务引用了不存在的 $($am.Value)" }
        }
    }
    # R -> CAP（R 表最后一列可选；只校验出现过的 CAP 引用）
    foreach ($m in [regex]::Matches($spec, '(?m)^\|\s*(R-\d+)\s*\|(.+)$')) {
        foreach ($cm in [regex]::Matches($m.Groups[2].Value, 'CAP-\d+')) {
            if (-not $caps.ContainsKey($cm.Value)) { Add-Err "${name}: $($m.Groups[1].Value) 引用不存在的 $($cm.Value)" }
        }
    }
    # ST -> CAP
    foreach ($m in [regex]::Matches($plan, '(?m)^\|\s*(ST-\d+)\s*\|(.+)$')) {
        foreach ($cm in [regex]::Matches($m.Groups[2].Value, 'CAP-\d+')) {
            if (-not $caps.ContainsKey($cm.Value)) { Add-Err "${name}: $($m.Groups[1].Value) 引用不存在的 $($cm.Value)" }
        }
    }
    # 每个任务至少挂一个 AC
    $taskBlocks = [regex]::Split($tasks, '(?m)^##\s+')
    foreach ($b in $taskBlocks) {
        if ($b -match '^(T-\d+)\b') {
            $tid = $Matches[1]
            if ($b -notmatch 'AC-\d+') { Add-Err "${name}: $tid 没有挂 AC" }
            if ($b -notmatch '(?m)^-\s*RED[：:]') { Add-Warn "${name}: $tid 没写 RED" }
            if ($b -notmatch '(?m)^-\s*验证[：:]') { Add-Warn "${name}: $tid 没写验证命令" }
        }
    }
    # AC 必须二元可判定：至少包含数字或明确比较词
    foreach ($m in [regex]::Matches($spec, '(?m)^\|\s*(AC-\d+)\s*\|[^|]*\|([^|]*)\|')) {
        $ac = $m.Groups[1].Value; $judge = $m.Groups[2].Value
        if ($judge -notmatch '\d|等于|相同|通过|失败|为 0|≤|≥|<|>') {
            Add-Warn "${name}: $ac 的判定可能不可量化（'$($judge.Trim())'）"
        }
    }

    # 状态
    if ($state -notmatch '(?m)^status:\s*(\S+)\s*$') { Add-Err "${name}: state.md 缺少 status" }
    else {
        $cur = $Matches[1]
        if ($statusEnum -notcontains $cur) { Add-Err "${name}: 非法状态 '$cur'" }
    }

    # ledger 必须存在且非空
    if (-not (Test-Path $ledgerPath)) { Add-Err "${name}: 缺少 ledger.md" }
    else {
        $lg = [System.IO.File]::ReadAllText($ledgerPath)
        if ($lg -notmatch '##\s*(轮次|Round)\s*\d+') { Add-Warn "${name}: ledger 没有轮次记录" }
    }
}

if ($errors.Count -gt 0) {
    if ($Json) {
        $obj = @{ ok = $false; epics = $count; errors = @($errors); warnings = @($warnings) }
        $obj | ConvertTo-Json -Depth 5
    } else {
        Write-Host "check-loop  failed  错误 $($errors.Count)，警告 $($warnings.Count)（epic $count）"
        foreach ($x in $errors) { Write-Host "  x $x" }
        foreach ($x in $warnings) { Write-Host "  ! $x" }
    }
    exit 1
}

if ($Json) {
    $obj = @{ ok = $true; epics = $count; errors = @(); warnings = @($warnings) }
    $obj | ConvertTo-Json -Depth 5
} else {
    Write-Host "check-loop  ok  epic $count，警告 $($warnings.Count)"
    foreach ($x in $warnings) { Write-Host "  ! $x" }
}
exit 0
