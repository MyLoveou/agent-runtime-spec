# MCP 目录（OpenCode）

本库把 Agent 要用的外部工具收成 **MCP**。OpenCode 侧没有独立的 `mcp.json`：配置写在 `opencode.json` 的 `mcp` 段（`type: local` + `command` 数组）。

| 服务 | 用途 | 配置 |
|------|------|------|
| **codegraph** | 代码知识图：符号、调用链、影响面 | [codegraph.md](./codegraph.md) |
| **git** | 本地仓库：status / diff / log / 分支（写操作须用户明确要求） | [git.md](./git.md) |
| **ssh** | 已登记主机：远程命令、SFTP、健康检查 | [remote-ssh.md](./remote-ssh.md) |

OpenCode 加载：[opencode.json](../opencode.json) → 项目 `.opencode/`；全局在 `~/.config/opencode/opencode.json`。装完用 `opencode debug config` 确认 `mcp` 段已被读到。

> 知识图谱类 MCP 已不随本库分发（2026-11-06 重构时移除）；需要时自行合并，不进默认配置。

## 本机一次

1. 安装 [Node.js 18+](https://nodejs.org)（ssh 用 `npx`）
2. 安装 [uv](https://docs.astral.sh/uv/)（git 用 `uvx`）
3. 安装 CodeGraph：`npm i -g @colbymchenry/codegraph`，在业务仓 `codegraph init`
4. 复制 `hosts.example.json` 为 `hosts.json`，填**允许连接的主机**（不要提交密钥）
5. 把 `opencode.json` 的 `mcp` 段里 `SSH_MCP_ALLOWED_HOSTS` 改成与 `hosts.json` 一致
6. `opencode debug config` 确认 mcp 段生效，codegraph / git / ssh 三项都在

### 健康检查（未绿时）

| 服务 | 先确认 | 回退 |
|------|--------|------|
| codegraph | 全局 CLI 已装；业务仓已 `codegraph init` | Grep / 读代码，禁止假装查过图谱 |
| git | `uvx` 可用；仓库是 git 根 | 用 Shell 的 git |
| ssh | `hosts.json` 存在且 `SSH_MCP_ALLOWED_HOSTS` 一致；密钥仅在 `~/.ssh/` | 用户在本机终端操作 |

未启动某服务不算失败，但回答里必须写清「未用 MCP」。

密钥只放本机 `~/.ssh/`，**禁止**写进 `opencode.json` 或 git。

## 与规范分工

| 真源 | MCP 角色 |
|------|----------|
| `docs/product/facts.md` / `decisions.md` | 项目事实与拍板。跨会话以这两份为准 |
| CodeGraph | **辅助**摸现有架构；结论仍写入 `实现方案.md` / facts |
| git MCP | 看仓库状态；**commit/push 仍守 G9** |
| ssh MCP | 只动 `hosts.json` 里的机；破坏性命令先问用户 |

未启动某 MCP → 回退：Git 用 Shell、代码用 Grep、远程等用户在终端操作。禁止假装已经查过图谱或已经连上机器。
