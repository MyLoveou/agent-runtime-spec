# infra（二方基础能力库）

> 业务仓：infra workspace（仓外，gitmove 工作区，根目录只有 `workspace.toml` / `AGENTS.md`）。
> 9 个成员仓各自独立版本与发布。

## 这个项目是什么

`infra-core` / `platforms` / `service` / `media` / `audio` / `toolbox` 是 Python 包，`infra-web`（`@infra/vue`）与
`infra-video`（`@infra/video`，Remotion）是前端包，`infra-bundle` 是元包与安装入口。
成员仓被 `.gitignore` 排除，是独立的 git 仓库。

## 为什么这么装配

- **cursor + dsh**：工作区根有 `AGENTS.md`（两个平台都读）；根目录没有 `.opencode/`，本次不加。
- **规则 27 条**：`common-*`（通用纪律）+ `typescript-*` + `vue-*` + `api-contracts` + `docs-maintenance` + 三个入口；
  不带 `java-*`（Python 后端）与 `react-*`（前端是 Vue）。
- **技能 26 个**：需求 / 设计 / 计划 / 审查 / 验收；界面工艺（`baseline-ui`、`better-*`、`oil-ui`）；
  `mermaid-diagrams`（架构图多）；`learning-notes`（交付后经验总结）；`project-assembly`（本库还要向下游分发子集）。
- **Agent 7 个**：多一个 `doc-sync`——这仓文档与版本矩阵需要跟着发版走。

## 一个限制要知道

成员仓单独打开（例如直接打开 `infra-core`）**看不到**工作区根目录的 `.cursor/` 与 `.dsh/`。
两种处理：

- 在工作区根目录打开（推荐，规则覆盖全部成员）；
- 或对具体成员单独导出：把该成员临时建成一个装配单。

## 怎么导出

```powershell
skills/project-assembly/scripts/assemble.ps1 -Project infra -Target <业务仓目录>
```

导出只写目标目录，从不回写本库；目标已有同名且内容不同的文件默认跳过（`-Force` 才覆盖）。

## 经验总结

按 v2.2.0 规范写 `temp/经验总结/infra/`。workflow 仓的 `AGENTS.md` 已写「跨项目临时沉淀在 temp」，
与规范一致；未挂 temp 的机器按「本地 + 待迁移」降级。
