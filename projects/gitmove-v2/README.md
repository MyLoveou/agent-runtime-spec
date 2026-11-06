# gitmove-v2

> Electron + Vue 3 桌面壳，Rust 核心（`crates/core` + `crates/cli`），Python sidecar 过渡期。

## 为什么这么装配

- **技术栈**：TypeScript + Vue 3 + Pinia（渲染层）、Node（Electron 主进程）、Rust（核心）、Python（过渡期 sidecar）。
- **平台**：`cursor` + `dsh`。该项目目前没有任何平台目录（`.cursor` / `.opencode` / `.dsh` 都不存在），是干净导入；若实际用 OpenCode，把 `platforms` 加上 `opencode` 即可。
- **规则**：`common-*` + `typescript-*` + `vue-*` + `frontend-vue` + 四个入口规则（`project-core` / `ai-execution` / `workflow-triggers` / `docs-maintenance`）；排除 `java-*`、`react-*`、`backend-spring`、`api-contracts`。
- **Skill**：project-spec 家族（需求 / 设计 / 计划 / 验收）+ 两道门禁（`encoding-guard` / `spec-check`）+ 构建修复（`build-fix`）+ 检索类（`search-first` / `knowledge-extract`）+ 跨会话（`dynamic-workflow-mode`）。
- **Agent**：`architect` / `planner` / `code-reviewer` / `frontend-vue-dev` / `backend-dev` / `qa-engineer`（Electron 主进程按后端对待）。
- **入口**：`entry` 为空——项目已有自己的 `AGENTS.md`（工作约定：代码结构、文档纪律、技术约束）与 `docs/`（decisions / design / requirements），**不从本库覆盖**。

## 已知空白

- **Rust 没有对应规则**：本库 42 条规则只覆盖 common / java / react / vue / typescript / frontend，没有 rust。`crates/core` 目前只能靠项目自有约定；如果 Rust 比重继续上升，值得在本库补一条 `rust-*` 规则。
- **Python sidecar** 同理，没有专门规则。

## 当前状态

| 项 | 值 |
|----|-----|
| 装配单核对 | 2026-11-06 |
| 业务仓 | `gitmove-v2`（仓外，远程 `MyLoveou/gitmove`） |
| 首次导出 | 未执行（dry-run：101 文件） |
| 导入前注意 | 业务仓有未提交的 Rust 改动，先提交再导入 |

## 导入建议

1. 先提交业务仓现有改动（`crates/cli/src/main.rs`、`crates/core/src/misc.rs`）；
2. `assemble.ps1 -Project gitmove-v2 -Target <gitmove-v2> -DryRun` 复核；
3. 去掉 `-DryRun` 执行，再把新增文件单独提交（一次性 101 个新文件，可拆成 rules / skills / agents 三批）；
4. 导入后按 `project-assembly` 的清单手动做：`constraints.md` 占位符、确认 `opencode.json`（若用 OpenCode）。
