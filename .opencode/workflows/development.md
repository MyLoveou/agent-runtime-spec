# 开发工作流

> **目标**：在门禁满足的前提下实现，审查后进入交付。

## 入口口令

- 「按开发工作流」「开始实现」「改接口」
- 「修 bug」→ `project-spec-fix`
- 「改样式」→ `project-spec-style`
- 「构建失败」→ `build-fix`


## 前置门禁（新能力）

- [ ] OpenSpec change 已 propose 且用户确认 apply；或需求 + `plan-workflow` 已定稿
- [ ] 用户明确「直接做」并接受文档滞后时，可跳过规划

小改 / bug：走 `project-spec-fix`，可跳过全量需求沉淀。


## 流程图

```mermaid
flowchart TD
  A[开发任务] --> B{新能力?}
  B -->|是| C{规划已确认?}
  C -->|否| R[→ 需求工作流]
  C -->|是| D[search-first 若加依赖]
  B -->|否| D
  D --> E[project-spec apply 或按栈实现]
  E --> F{改 backend?}
  F -->|是| G[backend-dev + java rules]
  F -->|否| H{改 frontend?}
  G --> H
  H -->|React| I[frontend-dev + react rules]
  H -->|Vue| J[frontend-vue-dev + vue rules]
  H -->|否| K[doc-sync 若 API/实体]
  I --> K
  J --> K
  K --> L{构建失败?}
  L -->|是| M[build-fix]
  L -->|否| N[code-reviewer]
  N --> S[→ 交付工作流]
```

## 阶段

| 阶段 | Skill / Agent | Rules | 产出 |
|------|----------------|-------|------|
| 0 依赖 | `search-first` | `rules/common-security` | 依赖决策 |
| 1 实现 | `project-spec` apply；`@backend-dev` / `@frontend-dev` / `@frontend-vue-dev` | 见栈 Rules | 代码 |
| 2 构建 | `build-fix` | 栈 patterns | 构建 PASS |
| 3 契约 | `@doc-sync` | `rules/api-contracts` | design 同步 |
| 4 审查 | `code-review-gate` · `@code-reviewer` | `rules/common-code-review` | 审查意见 |
| 5 后端深验 | `backend-verify` · `@qa-engineer` | `rules/backend-spring` | 重启 + 冒烟 |

### 栈 Rules

| 改动路径 | Rules |
|----------|-------|
| `backend/**` | `rules/backend-spring`、`rules/java-*`、`rules/api-contracts` |
| React | `rules/frontend-react`、`rules/react-*`、`rules/typescript-*` |
| Vue | `rules/frontend-vue`、`rules/vue-*`、`rules/typescript-*` |
| `docs/design/**` | `rules/docs-maintenance`、`rules/api-contracts` |
