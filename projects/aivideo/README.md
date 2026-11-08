# aivideo（AI 视频）

> 业务仓：AI 视频（仓外，`D:` 盘独立项目），用 ComfyUI + Wan2.2 做 AI 生成视频。
> gitmove 别名 `aivideo`，分组 `biz`。

## 这个项目是什么

从一张参考图或一段提示词出发，用 ComfyUI 的 HTTP API 批量跑工作流，出 5 秒片段，再拼成长片。
主链路：分镜 → 工作流 JSON → API 提交 → 片段 → 合片 / 字幕 → 成片。
不服务于现有视频流水线（小说推荐那套是模板渲染，不是生成），产物自成一体。

## 为什么这么装配

- **只启 dsh**：这个仓在 DeepSeek Harness 里干活，没有 Cursor / OpenCode 的工作流；DSH 项目级只认 `.dsh/skills`。
- **生成端不外借**：ComfyUI 工作流 JSON、跑批脚本、角色参考图都是业务资产，留在业务仓，本库只给方法与门禁。
- **四个视频 Skill**：`video-compose`（素材 → treatment → EDL → 合片）、`video-captions`（逐词字幕）、`video-cut-grammar`（剪辑点判断）、`video-shortform-script`（15–90 秒脚本）——生成出来的片段要靠它们才成片。
- **质量门**：`project-spec`（复杂需求先设计）、`code-review-gate`（改跑批脚本）、`verification-gate`（交付前）、`encoding-guard`（中文路径 / GBK / BOM 踩过太多次）。
- **检索与沉淀**：`search-first`（换模型 / 加节点 / 加依赖前先搜）、`knowledge-extract`（把实测结论沉淀成事实与规则）。
- **不加 `video-production`**：那是「模板固定、只换数据」的卡片式长视频（Remotion + 数据流水线），与生成式出片不是一条链路；真要做长片拼接时再评估。
- **entry 留空**：业务仓自己维护 `AGENTS.md`，那是它的真源，不从规范库覆盖。

## 当前状态

| 项 | 值 |
|----|-----|
| 装配单建立 | 2026-11-08 |
| 导出范围 | 业务仓 `.dsh/skills/` 10 个 Skill（见 `assembly.json`） |
| 业务仓侧 | `gitmove init` 完成（`.git/gitmove.toml`），已注册到项目表（`aivideo` / `biz`） |
| 备份 | gitmove v2 + restic 单盘（E 盘 `backup/aivideo-restic`）；密码文件在用户目录 `.gitmove/` 下，不进仓库 |
| 最近一次同步 | 2026-11-08 首次导出 |

已知限制：单向导出，本库改动不会自动同步到业务仓；需要重新跑 `assemble.ps1` 覆盖。

## 怎么更新

在本库根执行（`-Target` 填业务仓路径，`-Root` 填本库根）：

```powershell
& .\.dsh\skills\project-assembly\scripts\assemble.ps1 `
  -Project aivideo -Target <业务仓> -Root <本库根> -DryRun

# 确认后去掉 -DryRun；内容不同时需要 -Force 才覆盖
```

注意：脚本默认按**当前目录**的 git 根找装配单，不在本库根时要显式给 `-Root`。

## 本次补装（2026-11-08）

| Skill | 为什么补 |
|-------|----------|
| `comfy-workflow` | 本仓 `工具/跑工作流.py` 直接打 `POST /prompt`；这个技能覆盖提交、轮询、取产物、节点报错与显存纪律 |
| `learning-notes` | DSH 没有规则机制，交付后的经验总结只能靠技能兜底 |