# source-manager

> Electron + Vue 3 的桌面资源管理器，pnpm workspace（`apps/` + `packages/`）。

## 为什么这么装配

- **技术栈**：TypeScript + Vue 3 + Pinia；Electron 主进程 = Node 后端，按后端对待。
- **平台**：只用 `cursor` 与 `opencode`——本项目没有接 DSH（`agents` 只在支持 Agent 的平台生效）。
- **规则**：`common-*` 全要，`typescript-*` / `vue-*` / `frontend-vue` 是本项目栈；`java-*`、`react-*`、`backend-spring`、`api-contracts` 排除（这是本仓的示例装配，不代表项目实际状态）。
- **Skill**：走 `project-spec` 家族（需求 → 设计 → 计划 → 验收），加编码与结构门禁（`encoding-guard`、`spec-check`），再加检索类（`search-first`、`knowledge-extract`）。
- **Agent**：`architect` / `planner` / `code-reviewer` / `frontend-vue-dev` / `backend-dev` / `qa-engineer`。

## 当前状态

| 项 | 值 |
|----|-----|
| 装配单核对 | 2026-11-06（示例，按项目实际调整） |
| 业务仓 | `SourceManager`（仓外） |
| 最近一次同步 | 待记录 |

## 注意

- 本仓的 `.cursor` / `.opencode` 里如果已有旧版规则或 Skill，按清单覆盖前先 `git diff` 看一眼；
- 项目专属的规则 / Skill 放业务仓自己的平台目录，不要回灌本仓；
- 本项目的问题、事实与拍板写业务仓的 `docs/product/`。
