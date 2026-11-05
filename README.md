# 项目规范 · 多平台运行时库

> Cursor / OpenCode / DeepSeek Harness 三套运行时，各自一个自包含目录。
> **拷目录即可用**：没有生成、没有同步、没有域包、没有脚本。

## 目录

```
.
├─ .cursor/          # Cursor 运行时（完整）
│  ├─ rules/*.mdc          42 条
│  ├─ agents/*.md          9 个
│  ├─ skills/<name>/       16 个
│  ├─ workflows/  evals/
│  ├─ hooks/hooks.json
│  ├─ mcp.json  mcp/
│  └─ constraints.md
├─ .opencode/        # OpenCode 运行时（完整）
│  ├─ opencode.json        instructions + mcp
│  ├─ rules/*.md           42 条（正文同 Cursor）
│  ├─ agent/*.md           9 个
│  ├─ skills/<name>/       16 个
│  ├─ workflows/  evals/  mcp/
│  └─ constraints.md
├─ .dsh/             # DeepSeek Harness：只有 skills/
│  ├─ skills/<name>/       16 个
│  └─ README.md            平台限制说明
├─ AGENTS.md         # 三平台共用入口
├─ docs/             # 本仓自身文档
└─ README.md  STRUCTURE.md  CHANGELOG.md
```

## 拷到业务仓

| 平台 | 必拷 | 建议同拷 | 生效 |
|------|------|----------|------|
| Cursor | `.cursor/` | `AGENTS.md`、`docs/` | 重载窗口 |
| OpenCode | `.opencode/` | `AGENTS.md`、`docs/` | 重开 opencode |
| DSH | `.dsh/` | `AGENTS.md`、`docs/` | 新会话 |

**拷贝单元 = 平台目录 + `AGENTS.md` + `docs/`。** 只拷平台目录，规则与 Skill 能用；但入口文档、事实基线、项目规范在根目录，别漏。

拷完填两处：`constraints.md` 的 `{占位符}`、`docs/product/facts.md` 的实现与方向。

## 平台差异（为什么不是三份一模一样）

| 维度 | Cursor | OpenCode | DSH |
|------|--------|----------|-----|
| 规则 | `.mdc` + `globs`/`alwaysApply`，按需注入 | `.md` + `instructions`，**全量注入** | 无（只有 `AGENTS.md`） |
| Agent | `agents/` | `agent/`（`mode: subagent`） | 无 |
| Skill | ✓ | ✓ | ✓ |
| 工作流 / 评测 | 纯文档 | 纯文档 | 无效 |
| Hooks | `hooks.json` | 不移植（要写 TS plugin） | 无 |
| MCP | `mcp.json` | `opencode.json` 的 `mcp` | 全局配置，无项目级 |

OpenCode 只把 6 个入口规则放进 `instructions`（`project-core`、`ai-execution`、`workflow-triggers`、`common-openspec` + `AGENTS.md` + `constraints.md`），其余 36 条按需读——全塞进去每次会话多烧约 15k tokens。

DSH 项目级只认 `.dsh/skills`（优先级 100），没有项目级 Agent / 命令 / hooks / MCP；规则等效物只有根 `AGENTS.md`。

## 新增资产

见 `spec-runtime-maintain` Skill（三个平台目录各一份）。核心三条：

1. 每个应放平台各写一份完整副本，不建 `shared/`、不跨目录引用；
2. 正文平台中立，不写平台前缀；
3. 三份副本去掉 frontmatter 后逐字一致。

## 本仓文档

- [docs/product/facts.md](docs/product/facts.md)：实现与方向
- [docs/product/decisions.md](docs/product/decisions.md)：历次拍板
- [docs/requirements/features/](docs/requirements/features/)：需求与设计
- [docs/standards/](docs/standards/)：项目规范样板（动工门禁、编码约定、审查）

## 历史

重构前是「`rules/` + `shared/` + 生成脚本」结构，tag `pre-restructure` 可查。旧脚本与域包已删除，需要时从 git 历史取。
