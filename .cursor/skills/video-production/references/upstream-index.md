# 上游技能索引（参考，不 vendor）

> 本页只做**选型参考**：告诉你在外面该看哪几份索引、哪些能搬、哪些只能链接。
> 结论先给：**索引不进技能目录**，只把「补缺口」的具体做法改编进来。

## 三份索引（都是 awesome list，不是技能）

| 索引 | 规模 | 特点 | 许可 |
|---|---|---|---|
| [zhuyansen/awesome-claude-video-skills](https://github.com/zhuyansen/awesome-claude-video-skills) | 499 仓，按类型分组，**每个都读过并做安全分级** | 有「实测 16 个」的横评，含耗时 | 无标准许可 → 只引用链接 |
| [AaronAust1n/awesome-video-skills](https://github.com/AaronAust1n/awesome-video-skills) | 479 仓 | 偏「代码渲染」：Remotion / HyperFrames / three.js / Blender / manim | 无许可 → 只引用链接 |
| [ella-wang-opus/awesome-video-skills](https://github.com/ella-wang-opus/awesome-video-skills) | 17 个技能 | 视频优先、按制作阶段分（故事 / 视觉 / 动效 / 音频 / 渲染 / 质检） | 无许可 → 只引用链接 |

**共同结论**（来自 zhuyansen 的实测）：16 个技能全部通过四项基本检查，**不用技能的那次也通过了，且只用 4.4 分钟**。
所以技能的价值在「它带来的风格与工作流」，不在「能不能出片」。别为了装而装。

## 筛选四关

1. **许可**：`MIT` / `Apache-2.0` 可以改编（保留出处与 NOTICE）；`NONE` / `NOASSERTION` **只链接，不搬正文**；
2. **活性**：最近 3 个月有提交，且不是单人一次性仓库；
3. **依赖**：能否离线跑；强依赖云端 API 的不进本库（与 `comfy-workflow` 的本地原则一致）；
4. **补缺口**：先看下面的对照表，我们已经有的不要再引一遍。

## 已有能力对照（先看这张，别重复引入）

| 能力 | 本库已有 |
|---|---|
| 端到端长视频流水线 | `video-production` |
| 素材 → 成片（treatment / EDL / 合片） | `video-compose` |
| 短视频脚本 / 钩子 | `video-shortform-script` |
| 字幕（逐词 / 整句 / 烧录） | `video-captions` |
| 剪辑点判断 | `video-cut-grammar` |
| 本地出图 / 工作流 | `comfy-workflow` |
| 剧本 → 分镜（决策表 + 提示词包） | `video-storyboard` |

## 候选矩阵（缺口 → 候选 → 处置）

| 缺口 | 候选 | 许可 | 处置 |
|---|---|---|---|
| Remotion 渲染细节、组件写法 | [remotion-dev/skills](https://github.com/remotion-dev/skills) | **无** | **只链接**：思路可看，正文不能搬 |
| 镜头配方（150+ 种景别/运镜）+ 成片质检 | [Vincentwei1021/video-shotcraft](https://github.com/Vincentwei1021/video-shotcraft) | **Apache-2.0** | **可改编**：抽「镜头清单 + QA 检查表」两节 |
| 响度 / 成片工艺（广播级 LUFS） | [AbubakrChan/product-launch-motion](https://github.com/AbubakrChan/product-launch-motion) | **MIT** | **可改编**：抽音频与调色工艺 |
| 拼贴风解释片（Vox 风格） | [Alisa0808/vox-director](https://github.com/Alisa0808/vox-director) | **MIT** | 可选：有拼贴需求时再改编 |
| 剧本 → 分镜（景别/角度/运镜/光影/节奏） | [c-wang-dev/storyboard-master](https://github.com/c-wang-dev/storyboard-master) | **MIT** | ✅ 已改编为 `video-storyboard` |
| 逐词同步 + 78 个动效配方 | [Vincentwei1021/video-talkcraft](https://github.com/Vincentwei1021/video-talkcraft) | **NOASSERTION** | **只看思路**：机制可学，正文不搬 |

## 引入规则

1. **改编，不 vendor**：取方法重写正文，平台中立、不写 `~/.cursor` 之类硬编码路径；
2. **标出处**：末尾写「来源：<仓>（许可）」；Apache-2.0 还需保留 NOTICE 要求；
3. **不引入云端依赖**：需要付费 API 的步骤改为「可选路径」，默认本地；
4. **一次只引一个缺口**：一个技能对应一个能力，别再把 5 家做法混成一份。

## 什么时候不用引入

- 片子短、结构简单：直接按 `video-compose` 做，不需要新技能；
- 只是想要「更好看」：先跑 `baseline-ui` / `better-ui` 那套查看法，问题往往在排版与节奏，不在缺技能；
- 索引里 90% 的仓库是「同一套模板换个封面」，不值得逐个试。
