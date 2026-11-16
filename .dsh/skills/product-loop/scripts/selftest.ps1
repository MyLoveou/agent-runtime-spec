param()

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$psCmd = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $psCmd) { $psCmd = Get-Command powershell -ErrorAction SilentlyContinue }
if (-not $psCmd) { Write-Host "找不到 pwsh / powershell"; exit 2 }
$ps = $psCmd.Source
$pass = 0
$fail = 0

function Assert-Exit([string]$Name, [int]$Expected, [int]$Actual) {
    if ($Expected -eq $Actual) {
        Write-Host "  ok   $Name（退出码 $Actual）"
        $script:pass++
    } else {
        Write-Host "  FAIL $Name：期望 $Expected，实际 $Actual"
        $script:fail++
    }
}

$tmpBase = [System.IO.Path]::GetTempPath()
$root = Join-Path $tmpBase ("loop-selftest-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $root | Out-Null
$enc = New-Object System.Text.UTF8Encoding($true)

try {
    # 1. 脚手架
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'new-epic.ps1') -Slug demo -Title 'Demo' -Root $root | Out-Null
    $demoDir = Join-Path (Join-Path (Join-Path $root 'docs') 'loop') 'demo'
    $files = @('spec.md', 'plan.md', 'tasks.md', 'state.md', 'ledger.md') | ForEach-Object { Test-Path (Join-Path $demoDir $_) }
    if ($files -notcontains $false) { Write-Host "  ok   脚手架生成五个文件"; $pass++ } else { Write-Host "  FAIL 脚手架缺文件"; $fail++ }

    # 2. 全新模板可通过
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'check-loop.ps1') -Root $root | Out-Null
    Assert-Exit '新模板应通过' 0 $LASTEXITCODE

    # 3. 悬空引用（AC -> CAP-9）
    $specPath = Join-Path $demoDir 'spec.md'
    $specBackup = [System.IO.File]::ReadAllText($specPath)
    [System.IO.File]::WriteAllText($specPath, $specBackup.Replace('| AC-1 | CAP-1 |', '| AC-1 | CAP-9 |'), $enc)
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'check-loop.ps1') -Root $root | Out-Null
    Assert-Exit '悬空引用应被拦' 1 $LASTEXITCODE
    [System.IO.File]::WriteAllText($specPath, $specBackup, $enc)

    # 4. 非法状态迁移
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To in-progress -Root $root | Out-Null
    Assert-Exit 'draft->in-progress 应被拒' 1 $LASTEXITCODE

    # 5. 合法迁移
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To ready-for-dev -Root $root | Out-Null
    Assert-Exit 'draft->ready-for-dev 应通过' 0 $LASTEXITCODE

    # 6. blocked 缺原因
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To blocked -Root $root | Out-Null
    Assert-Exit 'blocked 缺原因应被拒' 1 $LASTEXITCODE

    # 7. done 权限
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To in-progress -Root $root | Out-Null
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To in-review -Root $root | Out-Null
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To built -Root $root | Out-Null
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To done -Root $root | Out-Null
    Assert-Exit 'done 无 -Actor human 应被拒' 1 $LASTEXITCODE
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'ticket.ps1') -Epic demo -To done -Actor human -Root $root | Out-Null
    Assert-Exit 'done 带 -Actor human 应通过' 0 $LASTEXITCODE

    # 8. built 但任务未勾选
    $root2 = Join-Path $tmpBase ("loop-selftest2-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $root2 | Out-Null
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'new-epic.ps1') -Slug demo2 -Title 'Demo2' -Root $root2 | Out-Null
    $demo2Dir = Join-Path (Join-Path (Join-Path $root2 'docs') 'loop') 'demo2'
    $statePath = Join-Path $demo2Dir 'state.md'
    [System.IO.File]::WriteAllText($statePath, ([System.IO.File]::ReadAllText($statePath)).Replace('status: draft', 'status: built'), $enc)
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'check-loop.ps1') -Root $root2 | Out-Null
    Assert-Exit 'built 但任务未勾选应被拦' 1 $LASTEXITCODE
    Remove-Item $root2 -Recurse -Force

    # 9. ledger 与 state 不一致
    $statePath = Join-Path $demoDir 'state.md'
    $stateBackup = [System.IO.File]::ReadAllText($statePath)
    [System.IO.File]::WriteAllText($statePath, $stateBackup.Replace('status: done', 'status: in-progress'), $enc)
    & $ps -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'check-loop.ps1') -Root $root | Out-Null
    Assert-Exit 'ledger 与 state 不一致应被拦' 1 $LASTEXITCODE
    [System.IO.File]::WriteAllText($statePath, $stateBackup, $enc)

    Write-Host ""
    if ($fail -eq 0) {
        Write-Host "selftest  ok  通过 $pass/$($pass + $fail)"
        exit 0
    } else {
        Write-Host "selftest  failed  通过 $pass，失败 $fail"
        exit 1
    }
}
finally {
    if (Test-Path $root) { Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue }
}
