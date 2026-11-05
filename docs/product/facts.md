# 项目事实基线

> 本仓库（cursor-project-spec）的实现与方向。只写已确认项。

**最后核对**：2026-11-06（拆成 `.cursor/` `.opencode/` `.dsh/` 三套自包含运行时）

---

## 一、项目实现（现状）

### 做什么

- 产品一句话：给业务仓提供 Cursor / OpenCode / DeepSeek Harness 三套**自包含**运行时（规则、Agent、Skill、工作流、MCP），拷贝即用。
- 已交付：42 条规则、9 个 Agent、16 个 Skill（`project-spec` 家族、需求、规划、验收、`mermaid-diagrams`、`spec-runtime-maintain`）、4 条工作流、3 个评测样例；Cursor hooks 与 MCP（codegraph / git / ssh）。
- **尚未实现**：OpenCode 版 hooks（要写 TS plugin）；DSH 侧的规则自动加载（平台不支持，只能靠根 `AGENTS.md`）。

### 怎么做的

| 层 | 位置 |
|----|------|
| Cursor | `.cursor/`：`.mdc` 规则 + `agents/` + `skills/` + `hooks/` + `mcp.json` + `constraints.md` |
| OpenCode | `.opencode/`：`opencode.json` + `.md` 规则 + `agent/` + `skills/` + `mcp/` |
| DSH | `.dsh/skills/`（平台只支持项目级 Skill） |
| 入口 | 根 `AGENTS.md`，三平台共用 |
| 本仓文档 | `docs/product`、`docs/requirements`、`docs/standards` |

无生成脚本、无同步脚本、无共享源目录；一致性靠正文去平台化 + `spec-runtime-maintain` 的发布清单。

### 验收

- OpenCode：`opencode debug config`、`opencode debug skill`
- Cursor：重载窗口，Rules 面板与 `@agent` 可用
- DSH：新会话 Skill 目录含本仓 16 个 Skill
- 一致性：同一 Skill 三份正文逐字一致；规则 `.mdc` 去 frontmatter == `.md`

### 实现边界

- 本仓负责：平台运行时的内容与结构。
- 本仓不负责：业务功能实现、生产主机密钥、全局 Skill 安装（同名全局副本会与项目副本抢，建议用完卸）。

---

## 二、项目方向（已确认）

- 近端：一平台一目录、拷贝即用；新增资产三份同步，不回到「源目录 + 脚本」。
- 明确不做：`shared/` 共享层、生成/同步脚本、域包 bundle、跨平台目录引用。
- 原则：正文平台中立；差异只允许在 frontmatter 与扩展名；DSH 只放 Skill。
- OpenCode 的 `instructions` 只放入口级规则，其余按需读（避免每会话多烧 token）。

## 未确认

（无）
