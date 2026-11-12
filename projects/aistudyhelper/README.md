# aistudyhelper（AI 学习助手）

> 业务仓：AIStudyHelper（仓外，本地 git，无 remote）。
> 包着两个 vendor 仓：`DeepTutor-src`（Python 后端 + Next.js 前端）与 `AITeachMe`（Android / 后端 / 桌面端）。

## 这个项目是什么

题库 + 仿题 + 知识库检索 + 练习的本地学习助手。外部依赖由 `config/dependencies.json` 统一开关：
MinerU（试卷解析）、LibreOffice（.doc 转换）、Ollama（bge-m3 embedding）。

## 为什么这么装配

- **cursor + dsh**：写代码在 Cursor，跑 agent 任务在 DSH；两边都读 `AGENTS.md`。
- **规则 25 条**：`common-*`（通用纪律）+ `typescript-*`（Next.js 前端）+ `api-contracts` + `docs-maintenance` + 三个入口。
  **不带 `java-*`**：那是 Spring 后端规则，这里 Android 是 Kotlin + Gradle，套不上。
- **技能 18 个**：
  - 需求 / 设计 / 计划 / 审查 / 验收：`project-spec` 家族 + `requirements-refinement` + `plan-workflow` + 两个 gate；
  - `eval-harness`：项目已有 `probe/baseline_questions.json` 这类基线，正好把「仿题像不像」变成可判定；
  - `multi-repo-ops`：两个 vendor 仓 + 本地补丁流程（`local-changes.patch`），跨仓操作频繁；
  - `baseline-ui` / `better-ui`：Next.js 界面的快速抛光；
  - `mermaid-diagrams`、`learning-notes`、`search-first`、`dynamic-workflow-mode`、`knowledge-extract`、`encoding-guard`、`spec-check`。
- **Agent 7 个**：多一个 `doc-sync`——这个项目有 CODE_REVIEW / HANDOFF / BACKLOG 三份文档要跟着改。
- **entry 留空**：`docs/HANDOFF.md` 与 `docs/BACKLOG.md` 是它自己的真源，不从规范库覆盖。

## 三条铁律（来自项目 HANDOFF，装配时必须知道）

1. 前端构建目录是 `.next-deeptutor`，不是 `.next`——只跑 `npm run build` 的产物不会生效；
2. 构建前必须先停服务，否则 EBUSY 锁住 standalone 目录；
3. `deepseek-flash` 的思考 token 计入 `max_tokens`，预算太小会返回空串导致 `json_parse` 失败。

## 怎么导出

```powershell
skills/project-assembly/scripts/assemble.ps1 -Project aistudyhelper -Target <业务仓目录>
```

导出只写目标目录，从不回写本库；目标已有同名且内容不同的文件默认跳过（`-Force` 才覆盖）。

## 经验总结

按 v2.2.0 规范写 `temp/经验总结/aistudyhelper/`；该校验的「先搜后写」由 `learning-notes` 与 `note-curator` 负责。
