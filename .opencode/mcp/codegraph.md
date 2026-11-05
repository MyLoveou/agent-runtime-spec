# CodeGraph MCP

> CLI：[colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) · `npx @colbymchenry/codegraph`  
> 作用：本地索引符号/调用/依赖；摸架构、改模块前看影响面。  
> **不**替代 `docs/product/facts.md`、`实现方案.md` 与人核实。

## 安装（每个业务仓本机）

```bash
npm i -g @colbymchenry/codegraph
cd <仓库根>
codegraph init
```

可选：`codegraph install --target=cursor --location=local`（会写 `.cursor/mcp.json`）。本规范库已提供合并片段，避免和 git/ssh 互相覆盖时，以本目录 `mcp.json` 为准手工合并。

Cursor 条目（已写入 `mcp.json`）：

```json
"codegraph": {
  "type": "stdio",
  "command": "codegraph",
  "args": ["serve", "--mcp", "--path", "${workspaceFolder}"]
}
```

必须带 `--path`：Cursor 启动 MCP 时 cwd 不一定是仓库根。

## Agent 约定

已连接时：

1. 摸现有架构、调用链、改动影响面 → **先** CodeGraph 工具（如 `codegraph_explore`，以当前版为准）
2. 图谱无命中再 Grep / 读文件
3. 结论写进 `实现方案.md` 或 facts（路径级），不要只停在聊天
4. 索引过期 → 提示用户 `codegraph init` 或按 CLI 重建，再继续

未安装或 MCP 未绿灯 → 回退 Grep，并在回复里写明「未使用 CodeGraph」。

## 注意

- 索引库本机 SQLite，按 `.gitignore` 忽略，不要当业务真源提交
- 本规范库（规则/md）索引价值有限；**业务仓**代码仓优先开 CodeGraph

## 企业认证摸底

域技能 `domain-enterprise-cert-codebase-map` 在 MCP 已连接时：先查调用链，无命中再 Grep。证据写入摸底 md。索引过期先重建再继续。
