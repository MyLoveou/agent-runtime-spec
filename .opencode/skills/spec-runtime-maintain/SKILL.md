---
name: spec-runtime-maintain
description: >-
  维护本规范库的三套平台运行时（.cursor / .opencode / .dsh）。新增或修改规则、Agent、
  Skill、工作流，或做三平台同步、发布前自检时使用。
  触发：新增规则、加 Skill、改平台目录、三平台同步、发布规范库。
---

# 规范库维护

本仓是「一平台一目录」的运行时库：`.cursor/`、`.opencode/`、`.dsh/` 各自完整、可单独拷走。
没有共享源目录、没有生成脚本、没有同步脚本。**新增资产 = 在每个平台目录各写一份完整副本。**

## 1. 每个平台能装什么

| 资产 | `.cursor` | `.opencode` | `.dsh` |
|------|-----------|-------------|--------|
| 规则 | `rules/*.mdc`，`globs`/`alwaysApply` 选择性注入 | `rules/*.md`，由 `opencode.json.instructions` 载入（全量） | 不支持 |
| Agent | `agents/*.md` | `agent/*.md` | 不支持 |
| Skill | `skills/<name>/SKILL.md` | `skills/<name>/SKILL.md` | `skills/<name>/SKILL.md` |
| 工作流 | `workflows/*.md` | `workflows/*.md` | 不支持 |
| 评测 | `evals/*.md` | `evals/*.md` | 不支持 |
| Hooks | `hooks/hooks.json` | 不移植（要写 TS plugin） | 不支持 |
| MCP | `mcp.json` | `opencode.json` 的 `mcp` | 全局配置，无项目级 |

`.dsh` 只放 Skill——这是平台限制，不是遗漏。

## 2. 正文必须平台中立

- 正文**不出现** `.cursor/`、`.opencode/`、`.dsh/` 前缀
- 引用资产写相对平台根的路径：`rules/<name>`、`skills/<name>/SKILL.md`、`workflows/<name>.md`、`constraints.md`、`mcp.json`
- 需要指平台时写「本平台目录」
- **唯一例外**：根 `AGENTS.md`——它是入口，必须列出三个真实路径
- 规则与 Agent 的引用不带扩展名（`.mdc` 与 `.md` 不同）

## 3. 新增一条规则

1. `.cursor/rules/<name>.mdc`：

```md
---
description: 一句话说清何时生效
globs: backend/**/*
alwaysApply: false
---
# 标题

正文……
```

2. `.opencode/rules/<name>.md`：**同样的正文，不要 frontmatter**
3. 是否进 OpenCode 常驻上下文：只有入口级规则才加进 `opencode.json` 的 `instructions`（当前 6 个）；其余留给按需读，否则每次会话白烧 token
4. `.dsh` 不复制规则

命名沿用现状：common 规则 `common-<id>.mdc`，栈规则 `<cat>-<id>.mdc`；历史名 `project-core`、`ai-execution`、`workflow-triggers`、`docs-maintenance`、`api-contracts`、`backend-spring`、`frontend-vue`、`frontend-react` 保持不变。

## 4. 新增一个 Agent

Cursor（`agents/<name>.md`）：

```md
---
name: <name>
description: 何时用
tools: ["Read", "Grep", "Glob"]
model: sonnet
---
正文（即该 Agent 的 prompt）
```

OpenCode（`agent/<name>.md`）：

```md
---
description: "何时用"
mode: subagent
permission:
  edit: deny
---
正文
```

差异只在 frontmatter：`tools` 映射成 `permission`（只读 Agent 写 `edit: deny`），`model` 删掉（跟随会话默认，避免绑定 provider），`name` 可省（取文件名）。正文必须一致。

## 5. 新增一个 Skill

三个目录各建 `skills/<name>/SKILL.md`：

```md
---
name: <name>
description: >-
  做什么 + 何时触发；触发词写在句子里。
---
# 标题

正文……
```

正文三份**逐字一致**。`name` 必须等于目录名且 kebab-case；OpenCode 与 DSH 对没有 `description` 的 Skill 直接不展示。

## 6. 新增一条工作流 / 评测

`.cursor/workflows/`、`.opencode/workflows/`（以及 `evals/`）各放一份，正文一致。`.dsh` 不放。

## 7. 发布前自检（全绿才提交）

- [ ] 新增/改动的资产在每个应放平台都有副本
- [ ] 三份正文逐字一致（去掉 frontmatter 后比对）
- [ ] 正文无平台前缀，无 `shared/`、`scripts/`、`templates/` 路径
- [ ] 改名或删除后没有残留引用
- [ ] `.opencode/opencode.json` 的 `instructions` 没有膨胀
- [ ] `opencode debug config`、`opencode debug skill` 能跑通
- [ ] `CHANGELOG.md` 加了条目

比对用一次性命令，不要写进仓库：

```powershell
Get-ChildItem .cursor/skills -Directory | ForEach-Object {
  $a = Get-Content "$($_.FullName)\SKILL.md" -Raw
  foreach ($p in '.opencode\skills', '.dsh\skills') {
    if ($a -ne (Get-Content "$p\$($_.Name)\SKILL.md" -Raw)) { "DIFF $($_.Name) $p" }
  }
}
```

## 8. 禁止

- 建 `shared/`、`templates/`、`rules/` 之类的源目录再生成
- 写生成 / 同步脚本，或让工具回写本仓（单向导出到外部目标除外）
- 让 `.opencode` 或 `.dsh` 去读 `.cursor` 的文件
- 把全部规则塞进 OpenCode `instructions`
- 在正文里写死平台前缀
- 只改一个平台就提交

## 9. 加一个新平台

1. 建 `<平台目录>/`，按该平台原生格式放资产
2. 根 `AGENTS.md` 增加一行路径
3. 本 Skill 的能力矩阵与自检清单各加一行
4. 单拷该目录 + `AGENTS.md` 到空仓验证一次

## 10. 自动化闸门（先跑再交）

手点清单会漏，交付前跑这两条，CI 也会跑：

```powershell
skills/spec-check/scripts/check-spec.ps1      # 结构：三份一致、规则正文、计数、链接、JSON
skills/encoding-guard/scripts/check-encoding.ps1 -Mode files -Path .   # 编码：问号替字 / mojibake
skills/spec-check/scripts/selftest.ps1        # 校验器自测（改过校验器才需要）
```

失败就修，别绕过：本仓没有豁免文件，`spec-check` 的判据就是本 Skill 第 1–7 节的可执行版本。

推送走分支：`git switch -c feat/<主题>` → push 分支 → 合并 `main`，不直推 main（流程见根 `AGENTS.md`）。
