# 目录结构

> 一平台一目录，各自自包含。没有源目录、没有生成、没有同步。

## 顶层

```
.
├─ .cursor/                  # Cursor 运行时（可直接拷走）
│  ├─ rules/*.mdc            43 条（common 15 / java 5 / react 5 / vue 5 / typescript 5 / 其它 8）
│  ├─ agents/*.md            9 个
│  ├─ skills/<name>/SKILL.md 36 个（含 spec-runtime-maintain、encoding-guard、界面工艺）
│  ├─ workflows/             5 个（README + 需求/设计/开发/交付）
│  ├─ evals/                 3 个示例
│  ├─ hooks/hooks.json       sessionStart / stop
│  ├─ mcp.json               codegraph / git / ssh
│  ├─ mcp/                   说明与主机登记模板
│  └─ constraints.md         业务项目硬约束模板
│
├─ .opencode/                # OpenCode 运行时（可直接拷走）
│  ├─ opencode.json          instructions(7) + mcp(3)
│  ├─ rules/*.md             43 条（正文同 Cursor，无 frontmatter）
│  ├─ agent/*.md             9 个（mode: subagent）
│  ├─ skills/<name>/         36 个（与 Cursor 逐字一致）
│  ├─ workflows/  evals/
│  ├─ mcp/                   说明
│  └─ constraints.md
│
├─ .dsh/                     # DeepSeek Harness（只支持 Skill）
│  ├─ skills/<name>/         36 个（与 Cursor 逐字一致）
│  └─ README.md              平台限制与加载优先级
│
├─ docs/                     # 本仓自身
│  ├─ product/facts.md       实现 + 方向
│  ├─ product/decisions.md   决策记忆
│  ├─ requirements/features/ 需求 / 设计 / 实现方案
│  ├─ standards/             项目规范样板`n│  └─ releases.md            版本记录
│
├─ temp/                     # 跨仓收件箱（submodule → MyLoveou/temp）
│  └─ <YYYY-MM-DD-来源-主题>/ 其他项目的要求 / 建议，吸收完即删
│
├─ projects/                 # 按项目装配单（只存清单，不存资产副本）
│  └─ <项目>/assembly.json   启用了哪些规则 / Skill / Agent
│
├─ AGENTS.md                 # 三平台共用入口
├─ README.md  STRUCTURE.md  CHANGELOG.md
├─ .github/workflows/         # CI：spec-check（结构 + 编码）
├─ .encodingignore           # 编码校验豁免（示例文档可放行）
├─ LICENSE                    # MIT`n├─ VERSION                    # 当前版本号（与 git tag 对应）
└─ .gitignore
```

`temp/` 不是平台运行时：不参与拷贝，内容不入主仓历史，只提交 submodule 指针。

## 每个目录装什么

| 资产 | `.cursor` | `.opencode` | `.dsh` |
|------|-----------|-------------|--------|
| 规则 | `rules/*.mdc` | `rules/*.md` | — |
| Agent | `agents/*.md` | `agent/*.md` | — |
| Skill | `skills/` | `skills/` | `skills/` |
| 工作流 | `workflows/` | `workflows/` | — |
| 评测 | `evals/` | `evals/` | — |
| Hooks | `hooks/hooks.json` | —（要写 TS plugin） | — |
| MCP | `mcp.json` | `opencode.json#mcp` | —（全局配置） |
| 硬约束 | `constraints.md` | `constraints.md`（进 instructions） | 并入 `AGENTS.md` |

## 一致性契约

- 规则的正文：`.cursor/rules/<name>.mdc` 去掉 frontmatter == `.opencode/rules/<name>.md`
- Skill 的正文：三个目录逐字相同
- 正文不出现 `.cursor/`、`.opencode/`、`.dsh/` 前缀；引用写相对平台根
- 唯一例外：根 `AGENTS.md` 列出三个真实路径

## 命名

- 规则：common 用 `common-<id>`，栈规则用 `<cat>-<id>`；历史名保持原样（`project-core`、`ai-execution`、`workflow-triggers`、`docs-maintenance`、`api-contracts`、`backend-spring`、`frontend-vue`、`frontend-react`）
- Agent / Skill：kebab-case，Skill 的 `name` 必须等于目录名

## 维护

改资产 → 三份同步 → 自检清单（`spec-runtime-maintain`）→ 更新 `CHANGELOG.md`。

历史：`pre-restructure` tag 保存了旧的 `rules/ + shared/ + scripts/` 结构。
