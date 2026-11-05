# .dsh · DeepSeek Harness 运行时

> 本目录只承载 DSH **原生支持**的项目级资产：Skill。
> 规则、Agent、hooks、MCP 在 DSH 里没有项目级等价物，不要往这里塞。

## 目录约定

```
.dsh/
└─ skills/<name>/SKILL.md     # 项目级 Skill（优先级 100，高于 ~/.dsh 与 ~/.agents）
```

名称必须 kebab-case 且与文件夹同名；frontmatter 至少要有 `name` 与 `description`
（没有 description 的 Skill 不会出现在模型目录里）。

## DSH 的加载顺序

| 优先级 | 来源 | 路径 |
|--------|------|------|
| 100 | 项目 | `<项目>/.dsh/skills` |
| 200 | 项目 | `<项目>/.agents/skills` |
| 400 | 用户 | `~/.dsh/skills` |
| 500 | 用户 | `~/.agents/skills` |

同名时项目级覆盖用户级。装了本目录后，建议卸掉同名的全局副本，避免两份并存。

## 指令入口

DSH 的项目指令只认 `AGENTS.md` / `CLAUDE.md`（从项目根逐目录向下加载，`.local.md` 作为叠加层）。
**DSH 不读 `.cursor/`、不读 `.opencode/`**，所以规则类内容在 DSH 侧的等效物只有根 `AGENTS.md` 摘要
和 Skill 内文。本目录不镜像规则，也不引用其他平台目录的文件——单独拷走 `.dsh/` + `AGENTS.md` 即可工作。

## 新增 Skill

1. 在本目录建 `skills/<name>/SKILL.md`；正文与本仓另两个平台的同名 Skill 逐字一致（但彼此不引用文件）；
2. 三份副本只允许 frontmatter 与目录名不同，正文必须逐字一致；
3. 重开会话后生效（DSH 在会话启动时扫描 skill 根）。

## 不做的事

- 不放 `.cursor/rules`、`.opencode/agent` 的镜像（DSH 不读）；
- 不放 MCP 配置（DSH 的 MCP 是全局配置，没有项目级入口）；
- 不放 hooks（DSH 无此机制）。
