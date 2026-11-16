---
name: product-loop
description: >-
  自驱产品迭代循环：调研 → 规格（CAP/AC/R）→ 评审门（人批准）→ 分支实现（RED→GREEN）→ 闸门 → 合并记账 → 下一轮。
  用于「我授权你连续推进，但新需求要我点头」的场景。
  触发：自驱开发、自动循环、探索需求、连续迭代、子代理开发、评审门、产品循环、product loop。
---

# 产品迭代循环

## 何时用

- 用户明确说「你自己找需求、安排实现，持续做」；
- 有多个小需求可以按轮次推进；
- 有子代理可以并行（调研 / 开发 / 审查）。

**没有明确授权不启动；没有评审门不连续改需求。**

## 三层结构

| 层 | 规模 | 内容 |
|---|---|---|
| Initiative | 一个成果，多个 epic | 一句话目标 + 边界 |
| Epic | 一个能力，8–12 个 story | 一起交付、一起部署 |
| Story | **一次构建会话**（≈500 行改动，不含测试） | 一条可独立验收的改动 |

**票就是规格。** 每个 epic 文件里写：`Requirements`（带稳定 id）、`Constraints`（带来源）、
`Done when`、`Boundaries`（不做什么）、`References`（要读哪些文档）。
下游一律读票，不读散落在聊天里的结论。

## 两个产物（规格与实现分离）

| 文件 | 只写什么 | 不写什么 |
|---|---|---|
| `spec.md` | 做什么、给谁、可验收的结果 | 技术选型、文件清单 |
| `plan.md` | 怎么做：栈、结构、阶段、风险 | 需求变更 |
| `tasks.md` | 每步 RED→GREEN 的任务 | 架构决策 |

项目级再放一份 `constitution.md`：≤5 条不可违背的原则（如「只读合法副本」「零网络」），
每次 plan 前后各检查一次。

## id 体系（引用必须闭合）

| 前缀 | 含义 | 例子 |
|---|---|---|
| `CAP-n` | 能力（带 intent + success） | `CAP-3` 可检索站 |
| `AC-n` | 验收（二元可判定） | `AC-5` 搜「图书馆」命中 1 条 |
| `R-n` | 约束 | `R-2` 只写 `out/` |
| `ST-n` | 风险 | `ST-4` 音画不同步 |
| `T-n` | 任务 | `T-7` 生成 timeline |

规则：每个 `AC` 挂一个 `CAP`；每个 `T` 挂一个或多个 `AC`；每个 `R`/`ST` 挂一个 `CAP`。
**不允许悬空引用**，校验不过不许开工。

## 状态机

```
draft → ready-for-dev → in-progress → in-review → built → done
                                    ↘ blocked（带原因）
                                    ↘ dropped
```

- agent 最多改到 `built`；`done` 只能由人或编排器标记；
- 进入 `in-progress` 前必须是 `ready-for-dev`（plan 通过验收模板检查）；
- `blocked` 必须写原因，且同一原因出现两次就停下问人。

## 一轮循环（八步）

| # | 步骤 | 门禁 |
|---|---|---|
| 1 | 调研：市场 + 技术各一份 | 都要有证据来源，无证据标「假设」 |
| 2 | 写候选卡（≤3 个） | 每张都要有「不做的代价」 |
| 3 | **评审门：交人批准** | **未明确批准 = 未批准** |
| 4 | 规格：`spec.md` + `AC` 表 | `AC` 全部二元可判定 |
| 5 | 计划：`plan.md` + `tasks.md` | 每任务有 RED→GREEN；契约（数据结构/接口）先定 |
| 6 | 分支实现 | 一需求一分支；**提交不推送** |
| 7 | 闸门：测试 / 构建 / 审查 / 验收 | 任一红就修；同一失败 2 次即停 |
| 8 | 合并 + 记账 + 下一轮 | 合并前再跑一次闸门 |

## 评审门：候选卡

```markdown
### 候选 <N>：<一句话>

- 用户痛点：<谁、什么场景、现在怎么凑合>
- 证据：<链接 / 数据 / 原话>（没有就写「假设」）
- 竞品做法：<做到什么程度>
- 最小可行形态：<一句话>
- 不做的代价：<会错过什么>
- 成本 S/M/L　风险 低/中/高
- 建议：做 / 缓 / 不做（给理由）
```

回复 `1、3 做` / `全部缓` / `候选 2 换做法`；**没有明确回复就停下来等**。

## 执行纪律（每个任务）

1. **先写失败测试，再写实现**；测试跑不过就不许写实现；
2. 五类高风险输入优先补测试：编码/路径分隔符、转义、边界空值、外部命令缺失、超长输入；
3. **验证在前**：说「完成」必须附命令与输出，不接受「应该可以」；
4. 一次只改一个变量，改不动就回退，不留半成品；
5. 人工修订必须申报（写进 `plan.md` 的修订记录），不许静默改数据。

## 预算与停止

| 项 | 默认 |
|---|---|
| 每轮候选 | ≤3 |
| 单需求改动 | ≤15 文件，超了拆 story |
| 单需求尝试 | 2 次；仍红 → `blocked` |
| 连续失败 | 2 轮 → 停，报告 |
| 每轮回报 | 做了什么 / 绿的证据 / 下一步候选 |

**停止条件**：用户中断 / 评审门未过 / 连续失败 2 次 / 预算耗尽。除此之外不要自己停。

## 记账

| 记什么 | 写哪 |
|---|---|
| 需求与取舍 | `docs/product/decisions.md`（一条一决策） |
| 现状变化 | `docs/product/facts.md` |
| 跨轮进度 | `handoff.md` / `HANDOFF.md` |
| 坑与原理 | `temp/经验总结/<项目>/` |

## 反模式

| 不要 | 为什么 |
|---|---|
| 自己批准自己的需求 | 评审门是唯一人工闸 |
| 一轮塞 10 个需求 | 无法验收，无法回滚 |
| 规格里写文件清单 | 那是 plan 的事，混了就改不动 |
| 改完不记 decisions | 下一轮重复讨论 |
| 直推主分支 | 出问题无法定点回滚 |
| 「我感觉这个功能好」 | 候选卡必须有证据或明确标为假设 |

## 细则

- 模板（spec / plan / tasks / 契约）：[references/spec-templates.md](references/spec-templates.md)
- 契约（id、状态机、ledger、blocked 原因）：[references/loop-contract.md](references/loop-contract.md)


## 脚本（契约的可执行版本）

目录约定：`docs/loop/<epic>/{spec,plan,tasks,state,ledger}.md`

| 脚本 | 用途 | 失败时 |
|---|---|---|
| `scripts/new-epic.ps1 -Slug <x> -Title <y>` | 生成五件套骨架 | 目录已存在 |
| `scripts/check-loop.ps1 [-Json]` | 校验 id 闭合、状态合法、任务挂 AC、AC 可量化、ledger 存在 | 退出码 1，逐条列出 |
| `scripts/ticket.ps1 -Epic <x> -To <status> [-Actor agent\|human] [-Reason] [-Evidence]` | 状态迁移 + 追加 ledger 行 | 非法迁移 / blocked 缺原因 / 未勾任务进 in-review·built·done / 非人工标 done |
| `scripts/selftest.ps1` | 脚本自身的回归（10 条断言） | 任一断言失败 |

```powershell
pwsh -File scripts/new-epic.ps1 -Slug export-v2 -Title "导出 v2"
pwsh -File scripts/check-loop.ps1
pwsh -File scripts/ticket.ps1 -Epic export-v2 -To ready-for-dev -Evidence "spec/plan 已填"
pwsh -File scripts/selftest.ps1
```

### 任务级状态

`tasks.md` 里每个 `## T-n` 下必须有一行勾选框：

```markdown
## T-1 加 provenance 字段

- [ ] 完成
- 挂 AC：AC-1
- 验证：python -m unittest discover -s tests
```

- 做完改成 `- [x] 完成`；
- 勾了但没写「验证」→ `check-loop` 报错；
- 状态到 `in-review` / `built` / `done` 时仍有未勾任务 → `check-loop` 报错。

这条堵的是「自称做完」：`built` 不再靠嘴说，靠勾选框与验证命令。

`done` 只能由人标：需要 `DSH_TICKET_ACTOR=human`，否则脚本拒绝。
## 来源

结构吸收自 [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)（票树 / 状态机 / blocked 语义）、
[GitHub Spec Kit](https://github.com/github/spec-kit)（spec/plan 分离、宪法、契约模板，MIT）、
[obra/superpowers](https://github.com/obra/superpowers)（RED→GREEN、验证在前，MIT），
按本库的平台中立要求重写。
