# aitrain（AI 训练）

> 业务仓：AI 训练（仓外，gitmove 别名 `aitrain`），给 AI视频 项目造资产：数据集 → LoRA → 评测。

## 这个项目是什么

角色 LoRA 的训练仓：收集清洗数据集、跑 sd-scripts 训练、出评测图挑版本，产物是 `.safetensors`。
**不做分镜、不出片**——那些在 `aivideo` 项目里。

## 为什么这么装配

- **只启 dsh**：训练在 DeepSeek Harness 里做，没有 Cursor / OpenCode 工作流；
- **不要 video-\***：剪辑、字幕、脚本那四个技能是制作仓的，训练仓用不上；
- **要编码校验**：中文路径 + BOM + 乱码踩过太多次（`encoding-guard`）；
- **要知识沉淀**：每次训练的结论（触发词失效、prompt 哨兵值）写进 `文档/` 与 `LoRA/<角色>/元数据.md`；
- **entry 留空**：业务仓自己维护 `AGENTS.md`。

## 当前状态

| 项 | 值 |
|---|---|
| 装配单建立 | 2026-11-08 |
| 迁移来源 | 从 `aivideo` 拆出（训练部分整体迁走） |
| 已训角色 | 企业（Illustrious-XL v1.1，8 轮，触发词 `enterprise_(azur_lane)`） |
| 结论 | 基座已认识官方标签，LoRA 无可见增益；方案 B（自造触发词）待验证 |

## 怎么更新

```powershell
& .\.dsh\skills\project-assembly\scripts\assemble.ps1 `
  -Project aitrain -Target <业务仓> -Root <本库根> -DryRun
```

## 本次补装（2026-11-08）

| Skill | 为什么补 |
|-------|----------|
| `comfy-workflow` | 评测图走 ComfyUI HTTP API（`工具/出评测图.py` → `跑工作流.py`），提交与排错规则与制作仓共用 |
| `eval-harness` | 把「这个 LoRA 好不好」变成可判定：固定提示词 × 种子 × 评判标准，避免凭感觉挑版本 |
| `learning-notes` | 训练结论（触发词失效、prompt 哨兵值）要沉淀给人看，DSH 无规则机制 |