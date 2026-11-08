# ComfyUI HTTP API

> 默认服务地址 `http://127.0.0.1:8188`。以下用占位符 `<HOST>`、`<ID>`、`<FILE>`。

## 健康检查

```bash
curl -s http://<HOST>/system_stats
# 返回 comfyui_version / devices[].vram_*
```

```bash
curl -s http://<HOST>/queue
# {"queue_running":[],"queue_pending":[]}
```

节点与模型清单（判断工作流能不能跑）：

```bash
curl -s http://<HOST>/object_info
```

## 提交工作流

```bash
curl -s -X POST http://<HOST>/prompt \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": { "<node_id>": { "class_type": "KSampler", "inputs": { } } },
    "client_id": "agent-<随机串>"
  }'
# → {"prompt_id":"<ID>","number":1}
```

要点：

- `prompt` 的键是**字符串节点 id**，值是 `{class_type, inputs}`；
- `inputs` 里引用上游节点写 `["<上游id>", <输出序号>]`；
- 校验失败会返回 `error` + `node_errors`（按节点 id 分组），照 id 查 `/object_info`。

## 轮询结果

```bash
curl -s http://<HOST>/history/<ID>
# 未完成：{}
# 完成：{"<ID>": {"outputs": {"<node_id>": {"images": [{"filename":"x.png","subfolder":"","type":"output"}]}}}}
```

轮询建议：1–2 秒一次，最多等 10 分钟；超时就 `/interrupt` 并报错。

## 取产物

```bash
curl -s -o out.png "http://<HOST>/view?filename=<FILE>&subfolder=&type=output"
```

`type` 有三种：`output`（正式产物）、`temp`（预览）、`input`（输入图）。**照抄 history 返回的 `type` 与 `subfolder`**，别自己猜。

## 上传输入图（img2img / 重绘）

```bash
curl -s -X POST http://<HOST>/upload/image \
  -F "image=@local.png" -F "overwrite=true"
# → {"name":"local.png","subfolder":"","type":"input"}
```

然后工作流里 `LoadImage` 的 `image` 填返回的 `name`。

## 队列控制

```bash
curl -s -X POST http://<HOST>/queue -H "Content-Type: application/json" -d '{"clear":true}'
curl -s -X POST http://<HOST>/interrupt
curl -s -X POST http://<HOST>/free -H "Content-Type: application/json" -d '{"unload_models":true,"free_memory":true}'
```

## 实时进度（可选）

`ws://<HOST>/ws?clientId=<id>` 会推 `progress` / `executing` / `executed` 事件；不想轮询就订阅它。轮询更简单，优先用轮询。

## 常见错误

| HTTP | 含义 |
|---|---|
| 400 + `node_errors` | 工作流校验失败（缺模型、类型不符） |
| 500 | 服务端异常，看 ComfyUI 控制台日志 |
| 连接失败 | 服务没起、端口不对、只绑了别的网卡 |

## 最小可复现脚本（PowerShell）

```powershell
$h = 'http://127.0.0.1:8188'
$wf = Get-Content .\workflow-api.json -Raw | ConvertFrom-Json
$body = @{ prompt = $wf; client_id = 'agent-' + [guid]::NewGuid() } | ConvertTo-Json -Depth 30
$r = Invoke-RestMethod -Uri "$h/prompt" -Method Post -ContentType 'application/json' -Body $body
do {
  Start-Sleep -Seconds 2
  $hist = Invoke-RestMethod -Uri "$h/history/$($r.prompt_id)"
} until ($hist.PSObject.Properties.Count -gt 0)
```

> 注意：`ConvertTo-Json` 默认深度不够会把工作流截断，必须显式 `-Depth`。
