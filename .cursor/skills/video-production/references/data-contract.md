# 数据契约（合成数据与字幕）

> 模板工程只认这一份 JSON。改字段先改契约，再改模板与生成脚本，别在模板里读散落的文件。

## 1. 合成数据

```jsonc
{
  "options": {
    "width": 3840,
    "height": 2160,
    "fps": 30,
    "theme": "light",                 // dark / light，只改这里
    "opening": false,                 // 是否渲染片头
    "durationPerItem": 9,             // 条目缺省时长（秒）
    "subtitles": [],                  // 本期字幕，按集注入，不全局共享
    "backgroundMusic": "ep/<主题>/audio/bgm.mp3",
    "openingAssets": "ep/<主题>/opening"
  },
  "items": [
    {
      "kind": "book",                 // book / card / transition
      "title": "…",
      "cover": "ep/<主题>/covers/01.png",
      "description": "…",
      "duration": 9,                  // 覆盖 durationPerItem
      "data": { "author": "…", "word_count": 0, "status": "连载" }
    },
    { "kind": "card", "title": "封面介绍", "duration": 8 }
  ]
}
```

规则：

1. 所有媒体路径都带 `ep/<主题>/` 前缀 —— 单集隔离的基础；
2. `duration` 在条目上（秒），缺省用 `options.durationPerItem`；
3. 字幕**只**走 `options.subtitles`，模板里不许静态 import 全局字幕文件；
4. `openingAssets` 显式指定，避免片头素材指到别的期；
5. 条目顺序即画面顺序，渲染脚本按它排时间轴。

## 2. 单集存档

```
src/data/
├─ current.json            # 当前活跃，被生成脚本覆盖
└─ episodes/<主题>.json    # 每期存档，互不覆盖
```

切换期 = 换 `current.json`。存档的意义：改模板后能回放任意一期，且不会串素材。

## 3. 字幕数据

```jsonc
[
  { "start": 210, "end": 360, "text": "…" },   // start/end 是成片绝对帧号
  { "start": 756, "end": 900, "text": "…" }
]
```

- **绝对帧**，不是卡片内相对帧；
- 片头内的 cue 可直接写死；正文 cue 从片头结束的那一帧开始累加；
- 每两项之间有 8 帧转场重叠，第 N 项起点要减 `8 × (N−1)`（详见 [subtitles.md](subtitles.md)）。

## 4. 总帧数与片头

```
总帧 = Σ(条目帧数) − (条目数 − 1) × TRANSITION_FRAMES
若 opening === false，再减去 OPENING_DURATION
```

- `TRANSITION_FRAMES` 固定 8；
- 关片头不减时长 → 尾部多一段黑屏（最常见的一类返工）；
- 帧数 = 秒 × fps，先算秒再取整，避免逐条累积误差。

## 5. 渲染入口

| 合成 | 分辨率 | 用途 |
|------|--------|------|
| `full` | 3840×2160 | 成片 |
| `review` | 1920×1080 | 审片，内容与 full 一致 |

两个合成共用同一份数据与组件，只有尺寸不同 —— 别为审片维护第二套模板。

## 6. 变更纪律

改契约时按顺序来：

1. 改本文件（字段名、语义）；
2. 改生成脚本；
3. 改模板与类型定义；
4. 用**上一期已归档的数据**跑一遍，确认向后兼容；
5. 三处都改完再出片。
