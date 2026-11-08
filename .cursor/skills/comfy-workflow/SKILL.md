---
name: comfy-workflow
description: >-
  驱动 ComfyUI 出图 / 出视频：连接检查、提交工作流、轮询队列、取产物、参数化与失败处理。
  适合封面、缩略图、配图、img2img、放大、批量变体等「需要本地生成图像」的任务。
  触发：ComfyUI、comfy、出图、生图、跑工作流、workflow、img2img、放大、SD、Flux、局部重绘。
---

# ComfyUI 工作流

## 何时用

- 需要**本地生成**图像/视频（不依赖云端 token）；
- 已有可复用的 ComfyUI 工作流（API 格式 JSON），只想换参数批量出图；
- 需要 img2img、放大、局部重绘这类图像加工。

不适用：纯云端模型调用（用对应 API）、纯剪辑（`video-compose`）、需要绝对确定性的图形（用代码画）。

## 两条连接路径

| 路径 | 什么时候选 | 细节 |
|---|---|---|
| **MCP**（推荐） | agent 有工具调用能力，配置一次长期用 | [references/mcp-setup.md](references/mcp-setup.md) |
| **HTTP API** | 没有 MCP、或要精确控制请求/轮询 | [references/http-api.md](references/http-api.md) |

两条路最终都落到同一套 REST 接口：`/prompt` → `/history/{id}` → `/view`。

## 标准流程

```
1 健康检查   /system_stats 有返回、队列没卡死
2 选工作流   已有 API 格式 JSON；没有就从 UI「Save (API)」导出
3 注入参数   只改 inputs 里的值，不改节点结构
4 提交       POST /prompt → 拿 prompt_id
5 轮询       GET /history/{prompt_id}，直到出现输出
6 取产物     GET /view?filename=… → 落到项目目录
7 验收       尺寸/数量/内容对不对；失败按表处理
```

**不要一上来就提交**：先确认服务活着、工作流节点都装齐（`/object_info` 里有对应 `class_type`）。

## 工作流即数据

- 用 **API 格式**（`Save (API Format)`），不是 UI 格式；UI 格式带 `nodes/links` 结构，`/prompt` 不认。
- 节点用 **字符串 id** 索引，`inputs` 里引用上游节点是 `["<上游id>", <输出序号>]`。
- 只改 `inputs` 的值：`seed`、`steps`、`cfg`、`width/height`、`filename_prefix`、文本、图片名。
- 改结构（加节点、换模型）要重导出一份，别在代码里拼。

## 参数纪律

| 参数 | 规则 |
|---|---|
| `seed` | 固定值可复现；要变体就循环递增，别用随机数到处飞 |
| 尺寸 | 64 的倍数；SDXL 用 1024 档，SD1.5 用 512 档，混用会糊或 OOM |
| `steps` / `cfg` | 跟模型走，不要照搬另一个模型的参数 |
| `batch_size` | 显存不够先降到 1，用循环代替大 batch |
| `filename_prefix` | 带日期与主题，产物好归档 |

## 队列与显存

- 一次只提交一个任务，拿到结果再提交下一个（ComfyUI 默认单队列，堆任务只会更难排查）；
- 12 GB 显存跑 SDXL 约 1–2 张/次；OOM 时降分辨率或 `batch_size=1`；
- 连续多任务后显存碎片化：`POST /free {"unload_models": true, "free_memory": true}`；
- 卡住不动：先 `GET /queue` 看是不是还在跑，再决定 `POST /interrupt`。

## 失败处理

| 现象 | 原因 | 处理 |
|---|---|---|
| `POST /prompt` 返回 `node_errors` | 缺模型 / 节点未装 / 输入类型不符 | 看报错里的节点 id，对照 `/object_info` |
| 一直 pending | 前面有任务卡住 | 查 `/queue`，必要时 `/interrupt` + 清队列 |
| 出图黑/噪点 | 采样器与模型不匹配、cfg 过高 | 换推荐参数重试 |
| 尺寸不对 | 工作流里写死了宽高 | 改对应 `inputs`，别改画布节点 |
| 找不到产物 | `type` 不是 `output`（临时预览在 `temp`） | `/view` 的 `type` 与 `subfolder` 照抄 history 返回值 |

## 安全底线

ComfyUI 默认**无鉴权**，`/prompt` 能执行任何已安装节点（含写文件、联网的自定义节点）：

- 只绑 `127.0.0.1`，不要暴露到局域网/公网；
- MCP 只连自己的实例；
- 工作流来自外部时先读一遍节点，别直接跑陌生自定义节点。

## 验收

- [ ] 图片尺寸、数量符合预期
- [ ] `seed` 记录了（可复现）
- [ ] 产物落在项目目录，文件名带日期与主题
- [ ] 工作流 JSON 与本次参数一起留档
- [ ] 没有残留的队列任务与显存占用

## 细节

- 接口、请求体、错误结构：[references/http-api.md](references/http-api.md)
- MCP 配置（Cursor / OpenCode）与验证：[references/mcp-setup.md](references/mcp-setup.md)
- 自己制作 / 导出 / 参数化工作流：[references/workflow-authoring.md](references/workflow-authoring.md)
- 可直接跑的最小模板（SDXL text2img）：[templates/txt2img-sdxl.json](templates/txt2img-sdxl.json)
