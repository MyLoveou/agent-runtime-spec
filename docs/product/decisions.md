# 项目决策记忆（压缩）

> 跨会话先读最近条 + `facts.md`。每条 ≤8 行。

## 有效决策

### D-20261106-05 · 用 `temp/` submodule 收其他项目的要求

- 场景：其他项目要把对本仓的要求 / 建议 / 经验同步进来
- **决定**：`temp/` 为 submodule，指向私有仓 `MyLoveou/temp`；主仓只提交指针，不提交收件内容
- **不选**：收件内容直接进主仓（本仓公开，会带出他项目私有信息）；拷无 `.git` 的副本（失去同步能力）
- **配套**：条目命名 `YYYY-MM-DD-来源-主题`，每个带 `README.md`；吸收完即删，结论写进 `docs/product/`
- **落点**：`README.md` §跨项目收件箱、`STRUCTURE.md`、`AGENTS.md`
- 状态：有效

### D-20261106-04 · DSH 目录只放 Skill

- **依据**：DSH 项目级只识别 `.dsh/skills`（优先级 100）与 `.agents/skills`（200）；无项目级 Agent / 命令 / hooks / MCP；项目指令只读 `AGENTS.md` / `CLAUDE.md`
- **决定**：`.dsh/` 只放 16 个 Skill + README；规则等效物是根 `AGENTS.md`
- **不选**：把 rules/agents 镜像进 `.dsh`——平台不读，纯负担
- 状态：有效

### D-20261106-03 · 一平台一目录，拷贝即用

- 场景：结构性重构
- **决定**：顶层只保留 `.cursor/`、`.opencode/`、`.dsh/`，各自完整；不设 `shared/`、不生成、不同步
- **不选**：源目录 + `generate.ps1` / `bootstrap-project.ps1`（维护两套路径，脚本本身成了负担）
- **落点**：`README.md`、`STRUCTURE.md`、`spec-runtime-maintain`
- 状态：有效

### D-20261106-02 · 正文平台中立，三份逐字一致

- **决定**：正文不写 `.cursor/`、`.opencode/`、`.dsh/` 前缀；差异只允许在 frontmatter 与扩展名
- **不选**：跨目录引用（`.opencode` 直接读 `.cursor/rules`，官方示例支持）——看似省事，但单拷一个目录就废
- **例外**：根 `AGENTS.md` 必须列出三个真实路径
- 状态：有效

### D-20261106-01 · 删除域包与扫描器

- **决定**：`domains/`（含 bundle 与 manifest）、`scripts/scan`、6 个搬运脚本全部删除，tag `pre-restructure` 留存
- **不选**：保留域包 → 与新结构重复；保留扫描器 → 违反「本仓不要脚本」
- 状态：有效

### D-20260923-04 · 规则不装用户全局；MCP 说明只留 mcp/

- **决定**：common/栈规则只经 bootstrap 进入业务仓 `.cursor/rules/`。`install-global-skills.ps1` 只装 Skill
- **不选**：把 alwaysApply 规则装到 `~/.cursor`，以致无关仓库也套上本库门禁
- **决定**：CodeGraph 与知识图谱的说明以根目录 `mcp/` 为准。知识图谱不进默认 `mcp.json`
- **不选**：域包再维护一份安装步骤和 JSON
- 状态：被 D-20261106-03 取代（脚本已删，规则直接在各平台目录里维护）

### D-20260923-03 · 生成物不入库

- **决定**：`.cursor/` 由 `generate.ps1` 写到**项目根**下；`.cursor/` 与 `.codex/` 进 `.gitignore`
- **不选**：把生成结果当源；`OutputDir` 再传一次 `.cursor`（会套出 `.cursor/.cursor`）
- 状态：被 D-20261106-03 取代（`.cursor/` 现在是源，已入库）

### D-20260923-02 · 全局 Skill 双目录

- **决定**：`install-global-skills.ps1` 同时覆盖 `~/.cursor/skills` 与 `~/.agents/skills`
- **不选**：只装一侧导致 Cursor 与 Agents 目录漂移
- 状态：已撤销（脚本删除；改为按需拷平台目录，同名全局副本会抢项目副本）

### D-20260923-01 · 实现可按 UI/功能/算法拆，页面为组合根

- 场景：进化 project-spec
- **决定**：关注点分离 + 能力组合；依赖 `UI → 功能 → 算法`；组合进主路径才算交付
- **不选**：微服务/微前端；把一个用户能力拆成多个发版
- **落点**：`project-spec` L2 §组合式、`设计.md` §5.2–5.3
- 状态：有效

### D-20260917-01 · 复杂需求必须先过 L2 设计

- **决定**：模型/交互/模块/拆分/抽象写入 `设计.md`，确认前不得 L3/apply（G1a）
- **不选**：用文件清单冒充设计；用 `project-spec-design` 做能力设计
- 状态：有效

### D-20260912-01 · Skill 名用 project-spec，不用官方 openspec

- **决定**：Skill 目录与 yaml `name` 为 `project-spec*`；CLI 与 `openspec/` 目录名不变
- 状态：有效

## 已撤销 / 被取代

（无）
