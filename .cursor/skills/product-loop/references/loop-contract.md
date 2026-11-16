# 循环契约

> 机器可读的部分：id、状态、ledger、blocked 原因。人和 agent 都按这份来，不靠聊天记录。

## 1. id 规则

| 前缀 | 用途 | 分配者 |
|---|---|---|
| `CAP-n` | 能力 | 规格阶段 |
| `AC-n` | 验收 | 规格阶段 |
| `R-n` | 约束 | 规格阶段 |
| `ST-n` | 风险 | 计划阶段 |
| `T-n` | 任务 | 计划阶段 |

- 编号在项目内连续，**不复用、不重排**；
- 引用必须闭合：`AC→CAP`、`T→AC`、`R→CAP`、`ST→CAP`；
- 校验脚本（或 `check` 子命令）发现悬空引用即失败。

## 2. 状态机

| 状态 | 含义 | 谁能进入 | 谁能离开 |
|---|---|---|---|
| `draft` | 有票，没规格 | 任何人 | 规格完成 |
| `ready-for-dev` | 规格与计划通过检查 | agent | agent（开工） |
| `in-progress` | 实现中 | agent | agent（提交审查） |
| `in-review` | 审查/自检中 | agent | agent |
| `built` | 做完了，等人确认 | agent | 人或编排器 |
| `done` | 人确认完成 | 人或编排器 | — |
| `blocked` | 卡住，带原因 | agent | 人或编排器 |
| `dropped` | 放弃 | 人或编排器 | — |

硬规则：

- agent **不许**把票标成 `done`；
- 进 `blocked` 必须写 `blocked_reason`，且记录在票里；
- 同一 `blocked_reason` 出现两次 → 停止循环，交人。

## 3. ledger（每轮追加）

```markdown
## 轮次 <N> · <日期>

- 候选：<C-1 标题> / <C-2 标题>
- 批准：<用户原话>（未批准写「无」）
- 分支：`feat/<slug>`
- 任务：T-1 ✅ T-2 ✅ T-3 ⛔（blocked: <原因>）
- 闸门：<命令> → <输出摘要>
- 合并：<commit>
- 下一步：<候选或阻塞项>
```

ledger 只追加不修改；它替代「我记得上次做到哪」。

## 4. blocked 原因（照抄，不自创）

| 原因 | 什么时候用 |
|---|---|
| `unclear intent` | 需求本身说不清，问了也没答案 |
| `intent gap` | 实现中发现需求缺一块，必须人补 |
| `no subagents` | 流程要求并行但没有子代理能力 |
| `verification failed` | 闸门红，且修了 2 次仍红 |
| `non-convergence` | 同一问题反复出现，修不动 |
| `needs human decision` | 需要人拍板才能继续 |
| `scope too large` | 单需求超过预算（>15 文件） |

## 5. deferred（不是这张票的问题）

审查中发现但不属于本轮的：

```yaml
- summary: <一句话>
  evidence: <为什么是真的>
  location: <文件:行>
  severity: high | medium | low
  suggested: <下次开票的标题>
```

- 只有「如果为真、影响 ≥ medium」才记；
- 记完交给编排器决定是否开新票，**不在本轮顺手修**。

## 6. 提交纪律

- 提交信息：`<type>(<scope>): <一句话>`，body 写「做了什么 / 验证命令 / 影响」；
- **提交不推送**，推送由合并步骤统一做；
- 一个任务一个提交；跨任务的重构单独一轮。

## 7. 脚本

契约不是靠自觉，靠脚本：

| 命令 | 覆盖 |
|---|---|
| `scripts/check-loop.ps1` | id 闭合、状态枚举、T→AC、AC 可量化提示、ledger 存在 |
| `scripts/ticket.ps1` | 状态迁移表、blocked 必须有原因、done 只能人标 |
| `scripts/new-epic.ps1` | 五件套骨架与目录约定 |

## 8. 校验清单（开工前 / 合并前）

- [ ] `AC` 全部二元可判定
- [ ] `T` 都挂了 `AC`
- [ ] 无悬空引用
- [ ] 契约文件已定稿（改契约要单独一轮）
- [ ] 分支从最新主分支切出
- [ ] 闸门命令明确、可复制
