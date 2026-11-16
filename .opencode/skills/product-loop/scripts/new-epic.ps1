param(
    [Parameter(Mandatory = $true)][string]$Slug,
    [Parameter(Mandatory = $true)][string]$Title,
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($true)

$dir = Join-Path $Root "docs\loop\$Slug"
if (Test-Path $dir) { Write-Host "already exists: $dir"; exit 1 }
New-Item -ItemType Directory -Force -Path $dir | Out-Null

function Write-Utf8([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

$stateTpl = @'
# state

status: draft
epic: __SLUG__
title: __TITLE__
'@

$specTpl = @'
# __TITLE__ - spec

> one line: for <who>, solve <what>; acceptance in section 4.

## 1. Background and goal

- Current:
- Goal:
- Non-goals:

## 2. User story

### US-1 <one line> (P1)

- Why:
- Independent test:
- Given / When / Then:

## 3. Capabilities (CAP)

| id | capability | intent | success |
|---|---|---|---|
| CAP-1 |  |  |  |

## 4. Acceptance (AC)

| id | CAP | binary check | how to run |
|---|---|---|---|
| AC-1 | CAP-1 |  |  |

## 5. Constraints (R)

| id | constraint | source |
|---|---|---|
| R-1 |  |  |

## 6. Open questions

| # | question | default assumption | impact |
|---|---|---|---|
'@

$planTpl = @'
# __TITLE__ - plan

## 1. Technical context

| item | value |
|---|---|
| language / runtime | |
| dependencies (license) | |
| external commands | |
| storage | |

## 2. Constitution check

| principle | before | after | note |
|---|---|---|---|

## 3. Structure

```text
<tree>
```

## 4. Data contracts

| file | writer | reader | stable fields |
|---|---|---|---|

## 5. Phases

| phase | content | exit |
|---|---|---|
| Phase 0 | options | every decision has an alternative |
| Phase 1 | contracts | contracts validate |
| Phase 2 | implementation | tasks all green |

## 6. Risks (ST)

| id | risk | trigger | impact | mitigation | CAP |
|---|---|---|---|---|---|
| ST-1 |  |  |  |  | CAP-1 |
'@

$tasksTpl = @'
# __TITLE__ - tasks

> Every task is RED -> GREEN: write the failing test first, then implement, then run everything.

## Global rules

- Test command:
- Full check:
- Allowed paths:

## T-1 <one line>

- AC: AC-1
- RED: <new test and assertion>
- Expect: fails with <error>
- GREEN: <minimal implementation>
- Verify: <command> -> expect <output>
- Rollback: git checkout -- <file>
'@

$ledgerTpl = @'
# ledger

> Append only.

## Round 0 - __DATE__

- Created: __SLUG__ (__TITLE__)
- Status: draft
'@

$date = Get-Date -Format 'yyyy-MM-dd'

Write-Utf8 (Join-Path $dir 'state.md') ($stateTpl.Replace('__SLUG__', $Slug).Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'spec.md') ($specTpl.Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'plan.md') ($planTpl.Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'tasks.md') ($tasksTpl.Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'ledger.md') ($ledgerTpl.Replace('__SLUG__', $Slug).Replace('__TITLE__', $Title).Replace('__DATE__', $date))

Write-Host "created: $dir"
Write-Host "  spec.md / plan.md / tasks.md / state.md / ledger.md"
