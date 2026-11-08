# resmgr（本地资源管理器）

> 业务仓：本地资源管理器（仓外，gitmove 别名 `resmgr`，分组 `biz`）。
> Electron 桌面端 + Vue 3 + Python 后端，管理本地媒体库。

## 这个项目是什么

扫描本地目录 → 入库 → 分页 / 虚拟滚动浏览 → 智能导入（CLIP 检索 + AI 建议）。
桌面端（Electron + Vue 3 + TypeScript）与后端（Python + SQLite）同仓，`apps/desktop` 与 `apps/backend`。

## 为什么这么装配

- **双平台**：仓里已有 `.cursor/` 与 `.opencode/`，两边都接；没有 `.dsh/`，不加。
- **规则子集**：`common-*`（通用纪律）+ `vue-*` + `typescript-*` + `api-contracts` + `docs-maintenance`；
  不带 `java-*`（后端是 Python）与 `react-*`（前端是 Vue）。
- **技能 25 个**：需求 / 设计 / 计划 / 审查 / 验收全套；界面工艺（`baseline-ui`、`better-*`、`oil-ui` 等）；
  `mermaid-diagrams`（这仓图多）；`learning-notes`（交付后经验总结）。
- **entry 留空**：该仓暂无 `AGENTS.md`，入口文档由它自己维护，不从规范库覆盖。

## 经验总结要迁到 temp

v2.2.0 起笔记统一放 `temp/经验总结/<项目>/`，先搜后写防重复。
该仓现有的 `docs/经验总结/`（52 篇）应迁到 `temp/经验总结/resmgr/`。

**迁移前的前置**：该仓需要挂上 temp（submodule 或本地链接）。未挂载期间按降级约定：
写在本地并标 `待迁移`，有 temp 后再移。

## 怎么导出

```powershell
skills/project-assembly/scripts/assemble.ps1 -Project resmgr -Target <业务仓目录>
```

导出只写目标目录，从不回写本库；目标已存在且内容不同的文件默认跳过（加 `-Force` 才覆盖）。
