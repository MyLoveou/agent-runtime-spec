# MCP 目录（Cursor）

本规范库把 Agent 要用的外部工具收成 **MCP**。真源在仓库根 `mcp/`；业务仓部署后为 `.cursor/mcp.json` + `.cursor/mcp/`。

| 服务 | 用途 | 配置 |
|------|------|------|
| **codegraph** | 代码知识图：符号、调用链、影响面 | [codegraph.md](./codegraph.md) |
| **git** | 本地仓库：status / diff / log / 分支（写操作须用户明确要求） | [git.md](./git.md) |
| **ssh** | 已登记主机：远程命令、SFTP、健康检查 | [remote-ssh.md](./remote-ssh.md) |
| **mcp-knowledge-graph**（可选） | 企业认证域的跨会话线索。不进默认 `mcp.json` | [knowledge-graph.md](./knowledge-graph.md) |

Cursor 加载：[mcp.json](./mcp.json) → 项目 `.cursor/mcp.json` 或用户 `~/.cursor/mcp.json`。

## 本机一次

1. 安装 [Node.js 18+](https://nodejs.org)（ssh 用 `npx`）
2. 安装 [uv](https://docs.astral.sh/uv/)（git 用 `uvx`）
3. 安装 CodeGraph：`npm i -g @colbymchenry/codegraph`，在业务仓 `codegraph init`
4. 复制 `hosts.example.json` 为 `hosts.json`，填**允许连接的主机**（不要提交密钥）
5. 把 `mcp.json` 里 `SSH_MCP_ALLOWED_HOSTS` 改成与 `hosts.json` 一致
6. 重启 Cursor → Settings → MCP，确认 codegraph / git / ssh 绿灯。知识图谱仅企业认证需要时再合并，见 [knowledge-graph.md](./knowledge-graph.md)

### 健康检查（未绿时）

| 服务 | 先确认 | 回退 |
|------|--------|------|
| codegraph | 全局 CLI 已装；业务仓已 `codegraph init` | Grep / 读代码，禁止假装查过图谱 |
| git | `uvx` 可用；仓库是 git 根 | 用 Shell 的 git |
| ssh | `hosts.json` 存在且 `SSH_MCP_ALLOWED_HOSTS` 一致；密钥仅在 `~/.ssh/` | 用户在本机终端操作 |
| mcp-knowledge-graph | 仅当业务仓已合并该片段，且 memory 路径可写 | 读 facts、decisions 与台账 |

未启动某服务不算失败，但回答里必须写清「未用 MCP」。

密钥只放本机 `~/.ssh/`，**禁止**写进 `mcp.json` 或 git。

## 与规范分工

| 真源 | MCP 角色 |
|------|----------|
| `docs/product/facts.md` / `decisions.md` | 项目事实与拍板。跨会话以这两份为准 |
| CodeGraph | **辅助**摸现有架构；结论仍写入 `实现方案.md` / facts |
| 知识图谱 | 可选线索。确认项必须回写 decisions 或企业认证台账 |
| git MCP | 看仓库状态；**commit/push 仍守 G9** |
| ssh MCP | 只动 `hosts.json` 里的机；破坏性命令先问用户 |

未启动某 MCP → 回退：Git 用 Shell、代码用 Grep、远程等用户在终端操作。禁止假装已经查过图谱或已经连上机器。
