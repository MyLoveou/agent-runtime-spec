# 版本记录

> 语义：**semver**。主版本 = 破坏性变更（目录结构、删除资产、契约变化）；次版本 = 新增资产；修订 = 修正。
>
> 当前版本写在同一目录的 `VERSION` 文件里；tag 必须以 `v` 开头并推到远程，否则「版本 ↔ commit」只在本地成立。

| 版本 | 日期 | 摘要 |
|------|------|------|
| **2.13.1** | 2026-11-17 | `product-loop` 脚本加固：ledger 与 state 一致性校验、`-Actor human` 权限参数；实测跑通一轮完整循环 |
| **2.13.0** | 2026-11-17 | `product-loop` 补脚本：`new-epic.ps1` / `check-loop.ps1` / `ticket.ps1`，把 id 闭合、状态机、ledger 变成可执行校验 |
| **2.12.0** | 2026-11-17 | `product-loop` 重构：三层票结构、CAP/AC/R 引用闭合、状态机、blocked/deferred、spec/plan/tasks 模板；新增 `ticket-keeper` 代理；Agent 14 → 15 |
| **2.11.0** | 2026-11-16 | 新增 `product-loop` 技能与 `market-scout` / `tech-scout` 两个只读调研代理：自驱循环 + 人工评审门 + 分支纪律；Agent 12 → 14，Skill 38 → 39 |
| **2.10.0** | 2026-11-15 | 新增 `video-storyboard`（源自 storyboard-master，MIT）：六步分镜流程、五张决策表、一致性清单、提示词四模板；Skill 37 → 38 |
| **2.9.0** | 2026-11-14 | `video-production` 新增「上游技能索引」：三份 awesome list 的定位、四关筛选、缺口→候选矩阵与改编规则 |
| **2.8.0** | 2026-11-12 | 新增 `projects/aistudyhelper`：AIStudyHelper 接入（25 规则 / 18 技能 / 7 Agent，cursor + dsh） |
| **2.7.0** | 2026-11-12 | 新增 `multi-repo-ops` 技能：多仓协同的三个角色与六步流程（DSH 无子代理，靠它兜底）；Skill 36 → 37 |
| **2.6.0** | 2026-11-12 | 新增 3 个子代理（`repo-surveyor` / `exporter` / `note-curator`）与「多仓协同」工作流；Agent 9 → 12，工作流 4 → 5 |
| **2.5.0** | 2026-11-08 | temp 改为「一份 clone + 本地 junction」统一挂载；本库移除 temp submodule（6 个业务仓已挂载） |
| **2.4.0** | 2026-11-08 | 新增 `projects/infra`：二方能力库接入（30 规则 / 26 技能 / 7 Agent，cursor + dsh） |
| **2.3.0** | 2026-11-08 | 新增 `projects/resmgr`：资源管理器接入（30 规则 / 25 技能 / 6 Agent，Cursor + OpenCode） |
| **2.2.0** | 2026-11-08 | 经验总结改为集中存 temp（`temp/经验总结/<项目>/`），先搜后写防重复；规则 / 技能 / 门禁同步 |
| **2.1.3** | 2026-11-08 | `learning-notes` 定为必装技能；模板与 `gitmove-v2` / `source-manager` 补齐；`spec-check` 强制校验 |
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
