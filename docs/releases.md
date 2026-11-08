# 版本记录

> 语义：**semver**。主版本 = 破坏性变更（目录结构、删除资产、契约变化）；次版本 = 新增资产；修订 = 修正。
>
> 当前版本写在同一目录的 `VERSION` 文件里；tag 必须以 `v` 开头并推到远程，否则「版本 ↔ commit」只在本地成立。

| 版本 | 日期 | 摘要 |
|------|------|------|
| **2.1.2** | 2026-11-08 | `aivideo` / `aitrain` 装配单补齐 `comfy-workflow`、`learning-notes`；`aitrain` 加 `eval-harness` |
| **2.1.1** | 2026-11-08 | `comfy-workflow` 补「自定义工作流」文档与可跑模板（含 `VAEDecode` 缺节点坑） |
| **2.1.0** | 2026-11-08 | 新增 `comfy-workflow`（ComfyUI 本地出图：HTTP API + MCP 配置片段）；技能 36 个 |
| **2.0.0** | 2026-11-08 | 三平台自包含重构（规则 / Agent / Skill 分别成目录）；删 `domains/`、生成与同步脚本；规则 43 / Agent 9 / Skill 35；CI 结构 + 编码门禁；项目装配单与单向导出；视频剪辑四件套；交付后经验总结规范 |
| 1.0.0 | 2026-11-06 | 重构前基线（`mermaid-diagrams` 接入完成） |

## 查版本对应的提交

```bash
git rev-list -n1 v2.0.0        # tag 指向的 commit
git show v2.0.0 --stat         # 该版本的提交说明
```

## 打版本的步骤

1. 合并到 `main`，确认 `spec-check` 与 `encoding-guard` 都通过；
2. 更新本表与 `VERSION`；
3. `git tag -a vX.Y.Z -m "<一句话摘要>"`；
4. `git push origin main --tags`；
5. 在本表补一行。

> 不给 tag 打 tag 的版本号是空的——`VERSION` 只是给人看的，机器认的是 tag。
