param(
    [Parameter(Mandatory = $true)][string]$Slug,
    [Parameter(Mandatory = $true)][string]$Title,
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($true)

$dir = Join-Path (Join-Path (Join-Path $Root 'docs') 'loop') $Slug
if (Test-Path $dir) { Write-Host "已存在: $dir"; exit 1 }
New-Item -ItemType Directory -Force -Path $dir | Out-Null

function Write-Utf8([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

$stateTpl = @'
# 状态

status: draft
epic: __SLUG__
title: __TITLE__
'@

$specTpl = @'
# __TITLE__ · spec

> 一句话：为 <谁> 解决 <什么问题>，验收看第 4 节。

## 1. 背景与目标

- 现状：
- 目标：
- 非目标（至少 3 条）：

## 2. 用户故事

### US-1 <一句话>（P1）

- 为什么：
- 独立验收：
- Given / When / Then：

## 3. 需求（CAP）

| id | 能力 | intent | success |
|---|---|---|---|
| CAP-1 |  |  |  |

## 4. 验收（AC）

| id | 挂 CAP | 判定（二元） | 怎么跑 |
|---|---|---|---|
| AC-1 | CAP-1 |  |  |

## 5. 约束（R）

| id | 约束 | 来源 |
|---|---|---|
| R-1 |  |  |

## 6. 待确认

| # | 问题 | 默认假设 | 影响 |
|---|---|---|---|
'@

$planTpl = @'
# __TITLE__ · plan

## 1. 技术上下文

| 项 | 值 |
|---|---|
| 语言 / 运行时 | |
| 依赖（含许可） | |
| 外部命令 | |
| 存储 | |

## 2. 宪法检查

| 原则 | 写计划前 | 写计划后 | 说明 |
|---|---|---|---|

## 3. 结构

```text
<目录树，标注新增 / 修改>
```

## 4. 数据契约

| 文件 | 谁写 | 谁读 | 稳定字段 |
|---|---|---|---|

## 5. 阶段

| 阶段 | 内容 | 退出条件 |
|---|---|---|
| Phase 0 | 选型 | 每项决策有替代方案 |
| Phase 1 | 契约 | 契约可校验 |
| Phase 2 | 实现 | tasks 全绿 |

## 6. 风险（ST）

| id | 风险 | 触发 | 影响 | 缓解 | 挂 CAP |
|---|---|---|---|---|---|
| ST-1 |  |  |  |  | CAP-1 |
'@

$tasksTpl = @'
# __TITLE__ · tasks

> 每个任务 RED→GREEN：先写失败测试，再实现，最后跑全量。
> 完成一个任务，把它的勾选框改成 [x]；`built` 之前必须全部勾上。

## 全局约束

- 测试命令：
- 全量检查：
- 允许修改的路径：

## T-1 <一句话>

- [ ] 完成
- 挂 AC：AC-1
- RED：<新测试与断言>
- 期望：失败，报 <错误>
- GREEN：<最小实现>
- 验证：<命令> → 期望 <输出>
- 回滚：git checkout -- <文件>
'@

$ledgerTpl = @'
# ledger

> 只追加，不修改。

## 轮次 0 · __DATE__

- 创建：__SLUG__（__TITLE__）
- 状态：draft
'@

$date = Get-Date -Format 'yyyy-MM-dd'

Write-Utf8 (Join-Path $dir 'state.md') ($stateTpl.Replace('__SLUG__', $Slug).Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'spec.md') ($specTpl.Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'plan.md') ($planTpl.Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'tasks.md') ($tasksTpl.Replace('__TITLE__', $Title))
Write-Utf8 (Join-Path $dir 'ledger.md') ($ledgerTpl.Replace('__SLUG__', $Slug).Replace('__TITLE__', $Title).Replace('__DATE__', $date))

Write-Host "已创建: $dir"
Write-Host "  spec.md / plan.md / tasks.md / state.md / ledger.md"
