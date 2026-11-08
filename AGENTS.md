# 项目规范 · 多平台运行时库

> 一个平台一个自包含目录：`.cursor/`、`.opencode/`、`.dsh/`。
> 没有生成脚本、没有同步脚本、没有共享源目录——新增资产就在每个平台目录各写一份。
> 唯一的脚本是**单向导出**（`project-assembly`）：按装配单把子集拷到外部业务仓，从不回写本仓。

## 目录

| 路径 | 内容 |
|------|------|
| `.cursor/` | Cursor：`rules`（`.mdc`）/ `agents` / `skills` / `workflows` / `evals` / `hooks` / `mcp.json` / `constraints.md` |
| `.opencode/` | OpenCode：`opencode.json` / `rules`（`.md`）/ `agent` / `skills` / `workflows` / `evals` / `mcp` |
| `.dsh/` | DeepSeek Harness：只有 `skills`（平台只支持这个） |
| `docs/` | 本仓自身：事实基线、决策记忆、需求与设计、项目规范样板 |
| `temp/` | 跨仓收件箱（submodule → `MyLoveou/temp`）：其他项目对本仓的要求 / 建议。只读进来，不进拷贝单元 |
| `projects/` | 按项目装配单：每个业务仓启用了哪些规则 / Skill / Agent（只存名字，不存副本） |
| `README.md` | 三平台怎么拷到业务仓、怎么新增资产 |
| `STRUCTURE.md` | 目录树与平台差异 |
| `CHANGELOG.md` | 变更记录 |

## 三条硬规则

1. 新增或修改资产，**每个应放平台各写一份完整副本**；不建 `shared/`，不跨目录引用。
2. 正文平台中立：不写 `.cursor/`、`.opencode/`、`.dsh/` 前缀，只写 `rules/<name>`、`skills/<name>/SKILL.md`、`constraints.md`。
3. 同一资产的三份副本，去掉 frontmatter 后必须逐字一致。

细则与发布自检见 `spec-runtime-maintain` Skill（三个平台目录各一份）。

## 推送流程（避免并发冲突）

> 默认分支是 `main`（自动化里也叫 master）。**不直接往 main 推。**

1. 从最新 main 切分支：`git switch -c feat/<主题>`（修复用 `fix/<主题>`，文档用 `docs/<主题>`）
2. 改完先过闸门：`spec-check` + `encoding-guard`
3. 推分支：`git push -u origin feat/<主题>`
4. 合并回 main：`git switch main && git pull --ff-only` → `git merge --no-ff feat/<主题>` → 再跑一次闸门 → `git push`
5. 合并后删分支：`git branch -d feat/<主题>`，远程分支一并删
6. 一条分支只做一次交付；长任务拆成多次小合并

远程 main 有新提交时，先 rebase 分支再合并——**冲突在分支里解，不把冲突留到 main**。


## 读什么

| 场景 | 先读 |
|------|------|
| 改本仓结构 / 新增资产 | `spec-runtime-maintain` |
| 项目现状与方向 | `docs/product/facts.md` |
| 历次拍板 | `docs/product/decisions.md` |
| 新能力、大改 | `project-spec`（复杂需求先 L2 设计） |
| 修 bug / 改样式 / 视觉方向 | `project-spec-fix` / `project-spec-style` / `project-spec-design` |
| 交付前 | `code-review-gate` → `verification-gate` |
| 交付后写经验总结 | `learning-notes` |

## 验收

- Cursor：重载窗口，Rules 面板能看到规则，`@architect` 等可调用
- OpenCode：`opencode debug config`、`opencode debug skill`
- DSH：新会话的 Skill 目录包含本仓 35 个 Skill

用户未要求时不 commit / push。
