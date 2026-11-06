# 项目决策记忆（压缩）

> 跨会话先读最近条 + `facts.md`。每条 ≤8 行。

## 有效决策

### D-20261106-09 · temp 收件箱的沉淀转成一个技能

- 场景：`temp/` 里躺着视频项目沉淀（8 份文档 / 13 条坑 / 10 个脚本），需要变成可复用的运行时资产
- **决定**：收成一个 `video-production` Skill：正文只放九步流水线与四条设计决定，细节拆 `references/`；平台私有细节标注核对时间；**不打包脚本**，只写「需要什么能力、什么时候要」；`infra` 单列一节作为可选后端
- **不选**：拆成三个技能（跨技能拼流水线容易只读一半）；原样搬运 24 KB（正文过重，每次会话都烧 token）；打包 10 个项目耦合脚本（路径、模块、题材词全是私有）
- **配套**：`spec-check` 的副本比对从「只比 SKILL.md」扩到「比整个 Skill 目录」；技能数 18 → 19
- 状态：有效
### D-20261106-08 · 结构契约改为自动校验，不靠注意力

- 场景：三条硬规则与各类计数只写在文档里，已实际攒出 26 处坏链与多处计数漂移
- **决定**：`spec-check` 把判据写成脚本；本地 pre-push + GitHub Actions 双闸，任一失败即拦；默认零豁免；确需放行时才建根 `.speccheck.json`，只降级为警告，修完即删
- **不选**：只靠 review 清单（会漏）；只在 CI 跑（反馈慢）；引通用 lint（判据是本仓特有的，通用工具覆盖不了三份一致）
- **落点**：`skills/spec-check/**`（三份）、`.github/workflows/spec-check.yml`；豁免文件已删，回到零豁免
- 状态：有效
### D-20261106-07 · 全局不装 Skill / Rule，统一用项目级

- 场景：ECC 全家桶曾装进 `~/.agents/skills`（386）、`~/.cursor/skills`（294）、`~/.opencode`（210）等全局位置；安装源仓（当时的本地目录）已不存在，清单失效、无法按原样卸载
- **决定**：全局目录一律不装 Skill / Rule / Command / Hook；需要什么，就把本仓对应平台目录拷进项目
- **不选**：全局装一份省事——每会话全量加载、与项目副本同名打架、版本随全局漂移
- **落点**：`docs/product/facts.md` §实现边界；清理产物归档在仓外 `_archive/global-agent-20261106`（含 MANIFEST 与 restore.ps1）
- 状态：有效

### D-20261106-06 · 编码门禁进 pre-commit / pre-push

- 场景：仓库描述与文档里出现成片 `?`；非 ASCII 字符走了 ANSI / OEM 通道被替换，**不可逆**
- **决定**：`encoding-guard` Skill = 校验脚本 + 钩子安装器；校验不过 `exit 1`，commit / push 直接被挡
- **判定**：U+FFFD、中文行里连续三个问号、任意连续四个问号、典型 mojibake 片段、坏文件名 / 提交信息 → 拦；非 UTF-8 → 只告警（`-Strict` 才拦，避免误伤老项目的 GBK 源码）
- **不选**：只在文档里提醒（照样会漏）；自动「修复」乱码（原字已丢，无法还原，只能定位后重写）
- **落点**：`skills/encoding-guard/**`（三份）、根 `.encodingignore`、`README.md` §提交前校验
- 状态：有效

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
