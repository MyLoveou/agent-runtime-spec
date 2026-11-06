# video（视频制作）

> 业务仓：视频制作（仓外），做小说推荐类长视频 —— 碧蓝航线、星穹铁道、综漫等。

## 这个项目是什么

模板固定、只换数据的卡片式长视频：一期 15–30 本书，3–10 分钟，出 4K + 1080p。
Remotion 负责渲染，Python 脚本负责数据（采集、清洗、封面、点评、配音字幕、归档）。

## 为什么这么装配

- **只启 dsh**：这个仓只在 DeepSeek Harness 里干活（项目根是 `CLAUDE.md`），没有 Cursor / OpenCode 的工作流；
- **video-production 必选**：它就是这套流水线的方法论（9 步 + 10 份 references），本仓的业务主技能；
- **加三件质量门**：`code-review-gate`（脚本改动）、`verification-gate`（交付前）、`encoding-guard`（中文路径 / GBK / BOM 踩过太多次）；
- **不加 agents**：DSH 没有 agent 机制，加了也不会生效；
- **entry 留空**：业务仓已有自己的 `CLAUDE.md`，那是它的真源，不从规范库覆盖。

## 当前状态

- 装配单：2026-11-07 建立
- 导出范围：业仓 `.dsh/skills/` 6 个 Skill（见 `assembly.json`）
- 已知限制：单向导出，本库改动不会自动同步到业务仓；需要重新跑 `assemble.ps1` 覆盖

## 怎么更新

在本库根执行（`-Target` 填业务仓路径，清单见业务仓 `CLAUDE.md`）：

```powershell
& .\.dsh\skills\project-assembly\scripts\assemble.ps1 `
  -Project video -Target <业务仓> -Root <本库根> -DryRun

# 确认后去掉 -DryRun；内容不同时需要 -Force 才覆盖
```

注意：脚本默认按**当前目录**的 git 根找装配单，不在本库根时要显式给 `-Root`。
