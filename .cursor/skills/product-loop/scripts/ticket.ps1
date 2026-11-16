param(
    [Parameter(Mandatory = $true)][string]$Epic,
    [Parameter(Mandatory = $true)][string]$To,
    [string]$Reason = '',
    [string]$Evidence = '',
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($true)

$dir = Join-Path $Root "docs\loop\$Epic"
$statePath = Join-Path $dir 'state.md'
$ledgerPath = Join-Path $dir 'ledger.md'
if (-not (Test-Path $statePath)) { Write-Host "找不到: $statePath"; exit 2 }

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

if ($statusEnum -notcontains $To) {
    Write-Host "非法状态: $To"
    Write-Host ("允许: " + ($statusEnum -join ', '))
    exit 2
}

$state = [System.IO.File]::ReadAllText($statePath)
if ($state -notmatch '(?m)^status:\s*(\S+)\s*$') { Write-Host 'state.md 缺少 status'; exit 2 }
$cur = $Matches[1]

$allowed = $transitions[$cur]
if ($allowed -notcontains $To) {
    Write-Host "不允许的迁移: $cur -> $To"
    Write-Host ("当前状态允许: " + $(if ($allowed.Count -gt 0) { $allowed -join ', ' } else { '（终态）' }))
    exit 1
}

# 只允许人/编排器标 done
if ($To -eq 'done' -and $env:DSH_TICKET_ACTOR -ne 'human') {
    Write-Host '拒绝: 只有人或编排器可以把票标成 done（设置 DSH_TICKET_ACTOR=human 表示人工操作）'
    exit 1
}

if ($To -eq 'blocked' -and [string]::IsNullOrWhiteSpace($Reason)) {
    Write-Host '拒绝: 进入 blocked 必须给 -Reason'
    exit 1
}

$state = [regex]::Replace($state, '(?m)^status:\s*\S+\s*$', "status: $To")
[System.IO.File]::WriteAllText($statePath, $state, $enc)

$now = Get-Date -Format 'yyyy-MM-dd HH:mm'
$line = "- $now  ``$cur -> $To``"
if ($Reason) { $line += "  原因: $Reason" }
if ($Evidence) { $line += "  证据: $Evidence" }
$ledger = [System.IO.File]::ReadAllText($ledgerPath)
if (-not $ledger.EndsWith("`n")) { $ledger += "`n" }
[System.IO.File]::WriteAllText($ledgerPath, ($ledger + $line + "`n"), $enc)

Write-Host "ticket  ok  $Epic : $cur -> $To"
if ($Reason) { Write-Host "  原因: $Reason" }
