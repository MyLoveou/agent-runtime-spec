# 动效与版式

> 这份是「返工重灾区」的规则化版本。新增模板或改动画前先读，能省掉一轮「又动了一下」。

## 一、动效铁律

| 规则 | 说明 |
|------|------|
| 图片入场 **≤1 秒**，之后**完全静止** | 落位后不允许任何缩放 / 位移 |
| **禁止 Ken Burns** | 不做全程缓慢放大、不持续漂移 |
| 文字入场完成后静止 | 不做持续抖动、不做呼吸缩放 |
| 背景可以动，但不带动内容 | 背景循环不能引起卡片缩放 |
| 转场统一 8 帧 | `TRANSITION_FRAMES = 8`，线性 + 淡入淡出 |

### 为什么写死

早期封面用 spring 缩放 `0.86 → 1`，damping 偏小会**过冲**（约 1.02 再回落），观感是「已经到位了又弹一下」。

**结论：封面 / 卡片用「淡入」，不用「缩放进入」。**

## 二、组件职责

| 组件 | 职责 | 动效 |
|------|------|------|
| `CoverFrame` | 圆角封面框（边框 + 阴影 + 占位） | 仅 opacity 淡入，不缩放 |
| `Grain` | 胶片颗粒层 | 静态 |
| `SubtitleOverlay` | 底部字幕条（按帧匹配 cue） | 静态切换 |
| `BackgroundFx` | CSS 背景动效（波纹 / 光斑 / 星野 等） | 独立循环 |
| `BackgroundVideo` | 视频背景（`Loop` + 静音） | 独立循环 |
| `TagList` / `ProgressBar` | 标签、进度 | 入场淡入 |

## 三、版式参数（以 3840×2160 为基准）

全部**按画面比例**算，换分辨率不失真：

| 元素 | 值 |
|------|-----|
| 封面高 | `height × 0.54`（宽 = 高 × 0.75，3:4） |
| 封面左边距 | `width × 0.075` |
| 文字区起点 | `width × 0.37` |
| 文字区宽度 | `width × 0.55` |
| 标题字号 | `height × 0.048`（4K 约 104 px） |
| 元信息字号 | `height × 0.021` |
| 简介字号 | `height × 0.0185` |

### 入场时序（帧）

```
分隔线  delay 2  / 16 帧
封面    淡入（无位移、无缩放）
标题    delay 6  / 16 帧
元信息  delay 12 / 16 帧
简介    delay 18 / 16 帧
```

一张卡片内所有元素在 **34 帧（约 1.1 秒）**内就位，之后完全静止。

## 四、配色

两套主题，字段固定：`background / backgroundGlow / accent / accentSoft / card / border / mode`。

- 深色：`#0b1220 → #060a12`，accent `#60a5fa`；
- 浅色：白底浅色风格，适合明亮素材；
- 换主题只改 `options.theme`，**模板里不许写死颜色**。

## 五、结构

```
full / review 合成
├─ Opening（可选，options.opening=false 关掉）
├─ TransitionSeries（每项一个 Sequence + 8 帧淡入淡出）
│  ├─ card（封面介绍 / 过渡 / 收尾）
│  └─ item（N 个条目卡）
├─ SubtitleOverlay（cue 来自 options.subtitles，每期独立）
└─ Audio（开场 BGM / 正片循环 / 片尾）
```

- 总帧数按 [data-contract.md](data-contract.md) §4 计算；
- 关片头要减 `OPENING_DURATION`，否则尾部黑屏。

## 六、常见返工清单

| 现象 | 原因 | 修法 |
|------|------|------|
| 封面「又动了一下」 | spring 过冲 | 只淡入，`scale` 固定 1 |
| 卡片位置左右跳 | 封面尺寸随源图比例变化 | 统一画布 cover 裁切 |
| 尾部黑屏 | 关片头后没减时长 | `opening ? OPENING_DURATION : 0` |
| 字幕串期 | 字幕写死在全局 json | 改成 `options.subtitles` 按集注入 |
| 背景抢注意力 | 背景未压暗 / 未虚化 | `backgroundVideoDim` + `blur` |
| 4K 渲染读图慢 | PNG 体积过大 | 先转 JPG q95 |
| 视频背景不动 | `OffthreadVideo` 没有 `loop` | 外面包一层 `Loop` |
| Studio 报 `xxx is not defined` | HMR 缓存旧模块 | 大改后重启 Studio |

## 七、改模板的检查顺序

1. 静态截图对不对（版式参数、字号、留白）；
2. 单卡动效是否 ≤1 秒且落位静止；
3. 连续三卡是否节奏一致（不忽快忽慢）；
4. 关片头 / 开片头两种模式各出一遍；
5. 4K 与 1080p 各抽一帧比对。
