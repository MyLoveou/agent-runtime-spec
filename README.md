# 项目规范 · 多平台运行时库

> Cursor / OpenCode / DeepSeek Harness 三套运行时，各自一个自包含目录。
> **拷目录即可用**：没有生成、没有同步、没有域包、没有脚本。

## 目录

```
.
├─ .cursor/          # Cursor 运行时（完整）
│  ├─ rules/*.mdc          42 条
│  ├─ agents/*.md          9 个
│  ├─ skills/<name>/       17 个
│  ├─ workflows/  evals/
│  ├─ hooks/hooks.json
│  ├─ mcp.json  mcp/
│  └─ constraints.md
├─ .opencode/        # OpenCode 运行时（完整）
│  ├─ opencode.json        instructions + mcp
│  ├─ rules/*.md           42 条（正文同 Cursor）
│  ├─ agent/*.md           9 个
│  ├─ skills/<name>/       17 个
│  ├─ workflows/  evals/  mcp/
│  └─ constraints.md
├─ .dsh/             # DeepSeek Harness：只有 skills/
│  ├─ skills/<name>/       17 个
│  └─ README.md            平台限制说明
├─ AGENTS.md         # 三平台共用入口
├─ docs/             # 本仓自身文档
├─ temp/             # 跨仓收件箱（submodule → MyLoveou/temp）
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

`temp/` 不属于拷贝单元：它是本仓自己的收件箱，业务仓不需要。

## 跨项目收件箱（`temp/`）

`temp/` 是 submodule，指向私有仓 `MyLoveou/temp`（跨项目临时沉淀区）。用途：**其他项目把对本仓的要求、建议、跑通的经验丢进去，本仓按需吸收**。

```powershell
git submodule update --init            # 首次拉到 temp/
git submodule update --remote temp     # 拉收件箱最新
```

- 只在本仓读写，不进 `拷贝单元`，不影响三平台的任何运行时资产。
- 里面每个条目一个子目录，命名 `YYYY-MM-DD-来源-主题`，子目录必须有 `README.md` 写清来源、范围、建议去向。
- 吸收完（改进规则/Skill 或明确不做）就删掉该子目录，保持常空；结论记进 `docs/product/`。
- `MyLoveou/temp` 是私有仓，主仓是公开的：这里只提交 submodule 指针，不提交收件内容。没有权限的克隆方拿到的是空目录，属正常。

## 提交前校验（`encoding-guard`）

页面上的成片问号不是显示问题，是**数据已损坏**：非 ASCII 字符被编码器替换成 `?`，原字找不回来。本仓用 `encoding-guard` 在提交前拦住这类内容。

```powershell
skills/encoding-guard/scripts/install-hooks.ps1                  # 装进当前仓库：pre-commit + pre-push
skills/encoding-guard/scripts/check-encoding.ps1 -Mode commit    # 手动跑一次
```

拦：`U+FFFD` 替换符、连续问号、GBK 乱码片段、坏掉的文件名与提交信息；`-Mode remote` 还能查仓库描述。细节见 `skills/encoding-guard/SKILL.md`（三平台各一份）。

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
