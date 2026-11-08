# 自定义工作流

> 目标：把「一个能出图的节点图」变成可复用、可参数化、可版本管理的资产。

## 一、先搞清两种格式

| 格式 | 结构 | 用途 |
|---|---|---|
| **UI 格式** | `{"nodes":[...], "links":[...], "extra":{...}}` | ComfyUI 界面保存用；`/prompt` 不认 |
| **API 格式** | `{"<node_id>": {"class_type": "...", "inputs": {...}}}` | 提交给 `/prompt`、给 agent 读 |

只有 API 格式能被程序执行。判断方法：顶层键是数字/字符串 id，值是 `class_type` + `inputs`。

## 二、从 UI 导出 API 格式

1. 在 ComfyUI 界面把图调到能出结果；
2. 打开设置里的 **Dev Mode**（旧版在菜单里直接有 `Save (API Format)`）；
3. 菜单 `Workflow → Export (API)` 或 `Save (API Format)`，得到 JSON；
4. 打开确认：顶层是节点 id，不是 `nodes/links`。

> 每导出一次，节点 id 可能变化。**对外引用（脚本、模板）之前先定版**，之后只在 `inputs` 里改值。

## 三、从零拼一个（顺序固定）

```
加载器 → 条件编码 → 空 latent → 采样器 → 解码 → 保存
```

最小 SDXL text2img 需要 6 个节点：

| 角色 | class_type | 关键输入 |
|---|---|---|
| 模型 | `CheckpointLoaderSimple` | `ckpt_name` |
| 正向 | `CLIPTextEncode` | `text`, `clip: [模型, 1]` |
| 负向 | `CLIPTextEncode` | `text`, `clip: [模型, 1]` |
| 画布 | `EmptyLatentImage` | `width`/`height`（64 倍数）, `batch_size` |
| 采样 | `KSampler` | `model:[模型,0]`, `positive`, `negative`, `latent_image`, `seed`/`steps`/`cfg`/`sampler_name` |
| 解码 | `VAEDecode` | `samples:[采样器,0]`, `vae:[模型,2]` |
| 保存 | `SaveImage` | `images:[解码,0]`, `filename_prefix` |

**最容易漏的是 `VAEDecode`**：`KSampler` 输出的是 `LATENT`，`SaveImage` 要 `IMAGE`。漏了会报：

```
Return type mismatch between linked nodes:
images, received_type(LATENT) mismatch input_type(IMAGE)
```

完整可跑模板见 [../templates/txt2img-sdxl.json](../templates/txt2img-sdxl.json)。

## 四、参数注入点

只改 `inputs` 里的值，别动结构：

| 想改 | 改哪个节点 | 字段 |
|---|---|---|
| 提示词 | 两个 `CLIPTextEncode` | `text` |
| 种子 | `KSampler` | `seed`（固定可复现，递增出变体） |
| 步数 / CFG | `KSampler` | `steps` / `cfg` |
| 采样器 | `KSampler` | `sampler_name` / `scheduler` |
| 尺寸 | `EmptyLatentImage` | `width` / `height` |
| 批量 | `EmptyLatentImage` | `batch_size`（显存不够先降到 1） |
| 输出前缀 | `SaveImage` | `filename_prefix` |
| img2img 输入图 | `LoadImage` | `image`（必须是 `/upload/image` 返回的 name） |

## 五、提交前的两道自检

1. **节点存在**：`GET /object_info/<class_type>` 有返回，说明节点已装；
2. **模型存在**：`GET /object_info/CheckpointLoaderSimple` 的 `ckpt_name` 列表里有你要的名字。

缺任何一项，提交必报 `node_errors`，别浪费一次排队。

## 六、版本化与交接

一个工作流就是一个目录：

```
workflows/<名字>/
├─ workflow.json     # API 格式
├─ params.md         # 每个参数的含义、默认值、推荐范围
└─ README.md         # 需要的模型、自定义节点、显存下限、示例产物
```

规矩：

- `workflow.json` 入库，产物不入库；
- 换模型 / 加节点 = 新导出一份，别在原地改结构；
- `README.md` 必须写清「缺什么会跑不起来」——换机器时这是唯一线索。

## 七、常见错误对照

| 报错 | 原因 | 修法 |
|---|---|---|
| `return_type_mismatch` | 漏 `VAEDecode` / 接错输出序号 | 按报错里的 `linked_node` 补节点或改索引 |
| `value_not_in_list` | `ckpt_name` / `sampler_name` 不在列表 | 查 `/object_info` 用准确名字 |
| `required_input_missing` | 节点少了必填输入 | 对照模板补齐 |
| 提交成功但一直 pending | 前面有任务卡住 | 查 `/queue`，必要时 `/interrupt` |
| 出图全黑/噪点 | 模型与采样器/cfg 不匹配 | 换模型推荐参数，降 cfg 重试 |
