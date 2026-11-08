# MCP 配置

> 目标：让 agent 通过 MCP 直接调 ComfyUI（查模型、建/改工作流、出图），而不是手写 HTTP。
> **MCP 配置属于业务仓，不属于本规范库**；本页给的是可直接复制的片段。

## 前置

1. ComfyUI 已在本机运行，默认 `http://127.0.0.1:8188`；
2. 能用 `curl <HOST>/system_stats` 拿到版本号；
3. Node.js 18+（`npx` 方式）或 Python 3.10+（pip 方式）。

## Cursor

项目级 `.cursor/mcp.json`（或用户级 `~/.cursor/mcp.json`）：

```json
{
  "mcpServers": {
    "comfyui": {
      "command": "npx",
      "args": ["-y", "comfyui-mcp"],
      "env": {
        "COMFYUI_URL": "http://127.0.0.1:8188"
      }
    }
  }
}
```

- 服务地址：包默认连本地 `127.0.0.1:8188`；远程实例按所选包文档设 URL（环境变量名以包文档为准）；
- 改完重启 Cursor → Settings → MCP，看到 `comfyui` 为绿。

## OpenCode

`opencode.json`：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "comfyui": {
      "type": "local",
      "command": ["npx", "-y", "comfyui-mcp"],
      "enabled": true
    }
  }
}
```

验证：`opencode debug config` 能看到 `mcp.comfyui`。

## 验证 MCP 真的通了

按顺序做三件事，任何一步失败都先修连接，别急着出图：

1. 列工具：应能看到「运行工作流 / 查询队列 / 列模型」这类工具；
2. 只读调用：查一次系统信息或模型列表（不产生副作用）；
3. 冒烟出图：用内置/默认工作流出 1 张 512×512，确认产物路径可访问。

## 远程 / 云端

- 远程自建（VPS / RunPod / 内网）：把服务地址指过去，并确认端口可达；
- Comfy Cloud：官方 MCP 支持云端连接，需要账号与额度；本技能默认按**本地**写，云端只作为可选路径；
- 不要在 MCP 配置里写长期密钥到仓库；用环境变量或本机配置。

## 安全

ComfyUI 默认无鉴权，`/prompt` 可执行任意已装节点（含写文件、联网的自定义节点）：

- 只绑 `127.0.0.1`，不要 `--listen 0.0.0.0` 暴露到局域网；
- MCP 只连自己的实例；
- 外部来源的工作流先读节点清单，再决定跑不跑。

## 与导出工具的关系

`project-assembly` 的导出**不合并** `mcp.json` / `opencode.json`（避免覆盖业务仓已有配置）。
所以：**MCP 片段要业务仓自己加**，本页就是给这份复制用的。

## 选型参考

| 方案 | 形态 | 说明 |
|---|---|---|
| `comfyui-mcp`（npm） | 本地 MCP 服务 | `npx -y comfyui-mcp`，自带建图与模型知识 |
| 官方 Comfy MCP | 本地/云端 | 见 [docs.comfy.org/agent-tools/mcp](https://docs.comfy.org/agent-tools/mcp) |
| 官方 coding-agent skills | 插件/技能 | [Comfy-Org/comfy-skills](https://github.com/Comfy-Org/comfy-skills)，Claude Code 插件形态 |

选一个即可，不要同时装两套 MCP（工具名会撞）。
