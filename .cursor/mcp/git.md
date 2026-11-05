# Git MCP

> 包：`mcp-server-git`（官方参考实现，经 `uvx` 运行）  
> 作用：对**当前工作区仓库**做 status / log / diff / 分支查询；写操作与规范库 G9 一致。

## 依赖

[安装 uv](https://docs.astral.sh/uv/getting-started/installation/)，确认 `uvx --version`。

Windows 若 `uvx` 不在 PATH：安装后重启 Cursor。

## 配置

```json
"git": {
  "command": "uvx",
  "args": ["mcp-server-git", "--repository", "${workspaceFolder}"]
}
```

只绑定工作区根，不要指向无关磁盘路径。

## 允许的操作

| 类 | 例子 | 条件 |
|----|------|------|
| 读 | status、log、diff、blame、分支列表 | 随时 |
| 写 | add / commit / checkout / push | **仅当用户明确要求**（G9） |

禁止：force push、硬重置、改 git config、跳过 hook。与用户规则里的 Git Safety Protocol 相同。

无 Git MCP 时用 Shell `git`，行为约束不变。
