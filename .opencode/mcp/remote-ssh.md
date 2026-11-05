# 远程主机 MCP（SSH）

> 包：`mcp-server-ssh`（`npx -y mcp-server-ssh`）  
> 作用：对**已登记**主机执行非交互命令、看系统信息、有限 SFTP。  
> 认证：本机 SSH **密钥**（默认 `~/.ssh/id_ed25519`）。禁止把密码、私钥写进仓库或 `mcp.json`。

## 登记主机

1. 复制 `hosts.example.json` → `hosts.json`（已 gitignore）
2. 填写 `allowedHosts`、`defaultUsername`、`defaultKey`
3. 把同样的主机列表写入 `mcp.json` 的 `SSH_MCP_ALLOWED_HOSTS`（逗号分隔，如 `dev.example.com,10.0.0.12`）
4. 将 `REPLACE_SSH_USER` / `REPLACE_SSH_KEY_PATH` 换成真实值（密钥**路径**，不是密钥内容）
5. `SSH_MCP_STRICT_HOST_CHECK` 保持 `true`

未把 `REPLACE_*` 改掉 → **禁止**调用 ssh 工具。

## 允许的操作（须用户点名主机）

| 类 | 可以 | 不可以（未明确要求） |
|----|------|----------------------|
| 探活 | `ssh_system_info`、磁盘/服务状态、读日志尾部 | 改防火墙、改 sshd |
| 只读文件 | `sftp_ls` / `sftp_read` / `sftp_stat`（已允许路径） | 读 `/etc/shadow`、私钥、`.env` |
| 命令 | 用户指定的非交互命令（部署脚本、重启已有服务） | `rm -rf`、格式化、全库删除、对未登记 IP 连接 |
| 传输 | 用户指定的配置/产物上传下载 | 把密钥或生产库拉到工作区 |

命令必须非交互（带 `-y` / `DEBIAN_FRONTEND=noninteractive`）。不要 `vim` / `passwd` / `top`。

## 连接

优先 `~/.ssh/config` 里的 Host 别名。`ssh_connect` 用密钥；用户未给密码时不要向用户索要密码明文写入配置。

连错环境、生产与开发分不清 → STOP 问用户。

## 失败回退

MCP 未绿灯或主机不在允许列表：说明原因，让用户在本机终端操作，不要改用未登记 IP「试一下」。
