# 变更记录

## 2026-11-07（oil-ui 的定方向方法）

- 从 oil-oil/oil-ui 接入 `oil-ui`：产品事实、主角、调性、灰度结构、方向卡、真实画面验收
- 不收生图脚本、风格对比页生成器、版本检查和完整版推销
- 确认前仍停在 `project-spec-design`；已有产品不换皮；动效仍默认不加
- 技能数 29 → 30；`gitmove-v2` 与 `source-manager` 装配单启用
## 2026-11-07（界面工艺技能）

- 从 ibelick/ui-skills 接入：`baseline-ui`、`fixing-accessibility`、`fixing-motion-performance`、`improve-ui`、`component-canvas`、`create-canvas`
- 从 jakubkrehel/skills 接入风格与样式：`better-ui`、`better-layout`、`better-typography`（配方保留原文数值）
- 定观感仍走 `project-spec-design`，只改样式的门禁仍走 `project-spec-style`；`workflow-triggers` 增加界面工艺分流
- `gitmove-v2` 与 `source-manager` 装配单启用这 9 个技能，并补上 `project-spec-design` / `project-spec-style`
- 技能数 20 → 29
## 2026-11-06（记录导出的单向限制）

- `projects/README.md` 增「已知限制」：单向顺序、冲突不合并、不能跨项目反哺、不接受时别导出
- `project-assembly` Skill 增同名小节（三份一致）
- 决策 D-20261106-12：接受该限制，先只记录，不改实现；引用式分发留待以后
## 2026-11-06（装配单导出工具）

- 新增 `project-assembly` 技能：`assemble.ps1` 按 `assembly.json` 把规则 / Agent / Skill 子集单向导出到业务仓
- 安全默认：内容不同不覆盖（`-Force` 才覆盖）、不删目标文件、不动 `opencode.json` / `mcp.json`、拒绝往本仓内部写
- 边界写进 D-20261106-11：允许「仓 → 外」导出，仍然禁止「仓内生成 / 同步」
- 技能数 19 → 20；AGENTS / README 里「没有脚本」的表述改为「只有单向导出」
## 2026-11-06（按项目装配单）

- 新增 `projects/`：每个业务仓一份 `assembly.json`，记录启用的规则 / Skill / Agent；只存名字，不复制资产
- 新增 `projects/_template/`（复制即用）与 `projects/source-manager/`（示例）
- `spec-check` 新增装配单校验：引用存在、`include`/`exclude` 不相交、`platforms` 合法、目录名与 `project` 一致
- `selftest` 增至 6 条断言；链接扫描范围加入 `projects/`
## 2026-11-06（video-production：收件箱沉淀成技能）

- 新增 `video-production`：九步流水线 + 四条设计决定 + 8 份 references（流水线 / 数据契约 / 动效 / 字幕 / 口播 / 图片 / 素材获取 / 坑 / infra）
- 不打包脚本：只写能力需求与判断标准；`infra` 作为可选后端单列
- `spec-check` 副本比对扩到整个 Skill 目录（含 `references/`），防止多文件技能漏改一个平台
- 技能数 18 → 19，README / STRUCTURE / AGENTS / facts 同步
## 2026-11-06（可选项收尾：自测 / 提交快照 / 跨平台）

- `encoding-guard -Mode push` 改为检查**提交里的内容**：工作区与提交不一致时不再拿错版本（走 `git archive` 取 HEAD blob）
- `spec-check` 新增 `selftest.ps1`：5 条负例断言（健康副本 / 副本不一致 / 分类漂移 / 坏链 / 盘符路径），CI 每次跑
- 自测当场修掉校验器自己的一个 bug：原来用「路径含 `temp`」跳过收件箱，导致在 `%TEMP%` 下扫描为空
- `spec-runtime-maintain` 增「自动化闸门」一节，指向三个脚本
- STRUCTURE 补 `LICENSE`；CI 增加自测步骤

## 2026-11-06（收尾：分类计数 / 绝对路径 / 许可证）

- STRUCTURE 的规则分类改为实际值（common 14 / java 5 / react 5 / vue 5 / typescript 5 / 其它 8），spec-check 新增该分类的漂移检查
- 文档里的本机绝对路径改成「仓外」表述；spec-check 新增「文档不得出现盘符路径」检查
- 新增 MIT `LICENSE`，README 补「许可」小节、facts 记录

## 2026-11-06（docs/standards 占位化，校验零豁免）

- `代码审查.md` / `TDD与测试.md` / `Bugbot审查.md` 去掉业务项目残留（savePatch / TipTap / app-services / `../功能/…`）与失效链接，改为 `{占位符}` 样板
- 删除 `.speccheck.json`：`spec-check` 从 8 条警告降到 0，进入零豁免
- 顺带修正样板里引用的 Agent / Skill 名（`vue-reviewer` 等并不存在，改用本库的 `code-reviewer` / `frontend-dev` / `backend-dev` / `qa-engineer` / `build-fix`）

## 2026-11-06（结构校验自动化）

- 新增 `spec-check` Skill（三份）：校验资产集合、Skill 三份逐字一致、规则正文一致、frontmatter 合法、正文无平台前缀、相对链接、JSON、文档计数、平台目录纯度
- 新增 `.github/workflows/spec-check.yml`：push / PR 自动跑 `check-spec.ps1` + `check-encoding.ps1`
- 新增根 `.speccheck.json` 豁免清单（当前只放 `docs/standards/**` 的历史坏链）
- Skill 数量 17 → 18，README / STRUCTURE / AGENTS / facts 同步

## 2026-11-06（修跨平台坏链）

- 规则里的旧路径链接（`testing.md`、`../typescript/testing.md` 等）改成纯规则名（`common-testing`、`typescript-testing`），两个平台都不再断
- `mcp/README.md` 两版重写：去掉已移除的 knowledge-graph 与「真源在仓库根 `mcp/`」的失效说法；OpenCode 版改为指向 `opencode.json#mcp`
- 坏链 26 → 8，剩下的都在 `docs/standards/`（业务项目残留引用，待占位化）

## 2026-11-06（全局运行时清零）

- 清空各平台全局安装：`~/.agents/skills` 386、`~/.cursor/skills` 294、`skills-cursor` 26、rules 121 / commands 94 / agents 67 / hooks 17、`~/.opencode` 210、`~/.config/opencode/skills` 11、`~/.claude/skills` 11
- 全部归档到仓外 `_archive/global-agent-20261106`（含 `restore.ps1`），可原样还原
- 效果：DSH 新会话 Skill 目录从 400+ 收敛为本仓 17 个 + 平台自带
- 定性：全局 Skill 与「拷目录即用」互斥，统一改用项目级（D-20261106-07）

## 2026-11-06（编码门禁）

- 新增 `encoding-guard` Skill（三平台各一份）：`check-encoding.ps1` 查问号替字、U+FFFD、mojibake、非法 UTF-8、坏文件名 / 提交信息 / 仓库描述；`install-hooks.ps1` 装 pre-commit + pre-push，校验不过就挡住
- 新增根 `.encodingignore`：示例文档可放行，避免守卫误伤自己
- 起因：仓库描述里出现 21 个问号（非 ASCII 被编码器替换，不可逆）

## 2026-11-06（跨仓收件箱）

- 新增 `temp/`：submodule 指向私有仓 `MyLoveou/temp`，用于接其他项目对本仓的要求 / 建议 / 经验
- 只提交 submodule 指针，收件内容不公开；吸收完即删，结论进 `docs/product/`
- 不参与「拷到业务仓」的拷贝单元

## 2026-11-06（三套自包含运行时）

- 顶层改为 `.cursor/`、`.opencode/`、`.dsh/`，各自完整、可单独拷走
- 删除 `rules/`、`agents/`、`shared/`、`platforms/`、`mcp/`、`templates/`、`domains/`、`scripts/`，以及 generate / bootstrap / apply-domain / sync-domain / install-global 全部脚本
- 正文去平台化：不写平台前缀，三份副本去掉 frontmatter 后逐字一致
- OpenCode 只把 6 个入口规则放进 `instructions`，其余按需读（避免每会话约 15k tokens）
- DSH 项目级只支持 Skill，故 `.dsh/` 仅 `skills/`；规则等效物为根 `AGENTS.md`
- 新增 `spec-runtime-maintain` Skill（三平台目录维护与发布自检）
- 加厚模板并入 `skills/project-spec/templates/`；`docs-standards` 落到 `docs/standards/`
- 删除规范扫描器与 enterprise-cert 域包（tag `pre-restructure` 可查）
- `.gitignore` 反转：`.cursor/` 入库，`.codex/` 继续忽略

## 2026-09-24（Mermaid 图质量 Skill）

- 新增 `mermaid-diagrams`：时序图、流程图、状态图的选型与交图检查
- 设计模板的系统协作指向该 Skill

## 2026-09-23（短规则、审查口吻、MCP 合一）

- `rules/java`、`rules/react`、`rules/vue` 收成项目栈短规则
- `code-reviewer` 改为对照设计、切片契约与安全阻断
- common 规则不装用户全局，只随业务仓 bootstrap
- 知识图谱说明并入 `mcp/knowledge-graph.md`，不进默认 `mcp.json`

## 2026-09-23（生成物与残留对齐）

- `.cursor/`、`.codex/` 不入库；`generate.ps1` 的 `OutputDir` 必须是项目根
- Java/Vue/React 测试规则去掉强制覆盖率，并去掉已删除 Skill / `@e2e-runner` 引用
- `planner` 去掉订阅计费示例，计划形状改跟 project-spec

## 2026-09-23（组合式拆实现）

- L2/L3 增加 **关注点分离 + 能力组合**：UI / 功能 / 算法分模块提供，页面或应用门面为组合根
- 与一版本一能力并存：实现可并行切片，组合进主路径才算交付
- L2 §5.3 **切片契约**；`verification-gate` 按切片验收；`tests.md` 增加切片列
- 规范库自有 `docs/product/facts.md` / `decisions.md`
- `install-global-skills.ps1` 同时写入 `~/.cursor/skills` 与 `~/.agents/skills`
- `architect` 对齐 project-spec；`sessionStart` hook 先读事实与决策
- 评测：`shared/evals/_example-composition.md`；测试规则不再强制 80%/tdd-guide

## 2026-09-17（复杂需求必须先过设计阶段）

- L2 `设计.md`：原则、模型、交互、模块划分、功能拆分、抽象；未确认不得写 L3、不得 apply（G1a）
- `project-spec-design` 仅视觉；能力设计走 `project-spec` 设计阶段

## 2026-09-12（全局安装开发 Skill）

- `scripts/install-global-skills.ps1`：把 `shared/skills` 装到 `%USERPROFILE%\.cursor\skills`

## 2026-09-12（MCP：CodeGraph / git / ssh）

- 新增仓库根 `mcp/`：Cursor `mcp.json` + CodeGraph、Git、远程 SSH 说明与主机登记模板
- 规则 `rules/common/mcp.md`；bootstrap 部署到 `.cursor/mcp.json`

## 2026-09-12（事实基线 + 压缩决策记忆）

- `docs/product/facts.md`：项目实现与项目方向（G0 必读）
- `docs/product/decisions.md`：每次拍板的压缩条目，跨会话先读；与 change `handoff.md` 分工

## 2026-09-12（project-spec 融合规范目录与架构）

- `project-spec` 与 `requirements-refinement` 共用 `docs/requirements/features/<id>/需求.md` + `实现方案.md`
- propose 必须对照项目规范与现有架构；L3 不再写到 `docs/design/features/<id>-plan.md`

## 2026-09-12（Skill 更名为 project-spec）

- 自定义工作流 Skill 从 `openspec*` 更名为 `project-spec` / `-fix` / `-style` / `-design`，避免与官方 OpenSpec 插件重名
- 业务仓 CLI 仍为 `openspec`；产物目录仍为 `openspec/`

## 2026-09-12（OpenSpec 场景特化）

- Skill：`project-spec-fix`（缺陷）、`project-spec-style`（改样式）、`project-spec-design`（界面方向）
- 全量 propose 仅用于新能力/改契约

## 2026-09-12（OpenSpec 个人化）

- 浓缩基线模板；规则：`project-spec` 门禁、`comments`、`knowledge-extract`
- Skill：中文 OpenSpec（tests.md / handoff.md / 加厚模板）+ `knowledge-extract`
- 跨会话以 change 内 `handoff.md` 为准

## 2026-09-12（简化为 Cursor + 自用 Skill）

- 延后 OpenCode / Hermes：删除 `platforms/opencode`、三平台 generate/bootstrap
- 删除网上/ECC 灌入的 Skill、Agent，以及 `rules/react-native`、`rules/web`
- 前端规则保留 Vue + React；新增 `shared/skills/project-spec`
- 新能力默认 OpenSpec propose → apply → archive

## 2026-07-27（enterprise-cert 工具三层）

- 纳入：知识台账文档化、`tooling/codegraph.md`、`tooling/mcp-knowledge-graph.md`、`templates/mcp.json.example`
- Skill `domain-enterprise-cert-tooling`；inventory 优先 CodeGraph；knowledge-capture 与 MCP KG 双写约定（md 为真源）
- apply 复制 `tooling/` 与 conventions 台账；`memory/.gitkeep` 占位

## 2026-07-27（enterprise-cert 纳入能力四件套）

- 域包明确挂载：`knowledge-capture` + `codebase-inventory` + `codebase-conventions` + `continuous-learning-v2`
- `bundle.manifest` 增加 continuous-learning-v2 与 conventions 模板；triggers / DOMAIN / SDD 阶段 0 已索引

## 2026-07-27（codebase-conventions：从代码提炼工程规范）

- 新增 Skill `codebase-conventions`：采样证据 →【规范待决断】→ 写入 `coding-conventions` 台账（可再收成短 Rule）
- 模板：`templates/docs-standards/coding-conventions.md.template`、`conventions-pending.md.template`
- 与 inventory / knowledge-capture / continuous-learning-v2 分工写入 workflow-triggers；enterprise-cert bundle 已纳入

## 2026-07-27（摸底防漏：codebase-inventory）

- 新增根 Skill `codebase-inventory`：四轮检索、路径证据、对抗复核、【摸底自检】、人核实门禁
- 加固 `domain-enterprise-cert-codebase-map` + 模板 + Rule `inventory-gate`；bundle 纳入该 Skill

## 2026-07-27（域包自包含 bundle）

- `bundle.manifest.json` + `scripts/sync-domain-bundle.ps1`：把依赖 Skill/Rule/Agent/Workflow 复制进 `domains/<id>/bundle/`
- `scripts/install-domain-pack.ps1`：仅持有域包目录即可装入业务仓 `.cursor/`
- `apply-domain-pack`：先合并 bundle 再合并域原生；enterprise-cert 已声明 SDD 依赖清单

## 2026-07-27（清理 AI 臆造业务事实）

- `core.mdc` 去掉未提供的状态机/审计/敏感字段/权限联动等「假不变量」
- glossary / taboos / business-rules / ui-interactions：撤销无来源「已确认」；仅保留复盘可溯源项
- DOMAIN / constraints / site-diff 标明占位 globs 与「流程≠现状」

## 2026-07-27（企业认证知识捕获 · 开放发现入库）

- 纠正：不以固定信号表穷尽业务；改为开放发现业务规则/领域知识/UI 交互
- Skill `domain-enterprise-cert-knowledge-capture`：【知识待决断】→ 人决断 → 写入活文档
- 活文档：`business-rules.md`、`ui-interactions.md`、`pending-decisions.md`；glossary/taboos 改为可追加台账
- Rule `confirm` 改为「表是结果不是边界」协议

## 2026-07-27（企业认证主动确认 Rule）

- 新增 `domain-enterprise-cert-confirm.mdc`：对照 taboos/glossary 信号主动输出【待确认上报】并 STOP
- `taboos.md` / `glossary.md` 标明详表 vs Rule 执行分工；triggers / sdd-gates / DOMAIN 已挂接

## 2026-07-27（企业认证 SDD 实践包）

- `domains/enterprise-cert`：glossary、taboos、site-diff/sdd-gates Rules
- Skills：`domain-enterprise-cert-sdd`、`codebase-map`、`tech-design`；templates（疑问表/摸底/方案/变更/切片验收）
- `apply-domain-pack`：域文档与 templates 复制到 `.cursor/domain-packs/<id>/`
- 触发表挂载「企业认证 SDD」口令

## 2026-07-27（业务域：企业认证）

- 新增域包 `domains/enterprise-cert`（企业认证）：核心 Rule、触发表 Skill、constraints overlay
- 根 `workflow-triggers` 登记企业认证口令 / 路径 → `domain-enterprise-cert-triggers`

## 2026-07-27（业务域配置包）

- 新增 `domains/`：按业务域隔离的 Cursor 配置包（源端组织，落地扁平合并）
- 脚手架：`domains/_template/`（DOMAIN.md、示例 rule/skill、constraints.overlay）
- Bootstrap 支持 `-Domain <id>[,id…]`；新增 `scripts/apply-domain-pack.ps1` 对已有 `.cursor/` 叠加
- 文档：`domains/README.md`、`STRUCTURE.md`、`BOOTSTRAP.md`、`README.md`、`AGENTS.md`

## 2026-06-19（ECC P0–P2）

- **P0 React PC**：`frontend-patterns`、`react-performance`、`frontend-a11y`、`nextjs-turbopack`；`web-*.mdc`（7）
- **P0 React App**：`react-native-patterns` + `react-native-*.mdc`（8）+ `frontend-react-native.mdc` + `@frontend-rn-dev`
- **P1 大型项目**：`orch-*`、`plan-orchestrate`、`team-agent-orchestration`、`architecture-decision-records`、`agent-architecture-audit`、`hexagonal-architecture`、`parallel-execution-optimizer`、`autonomous-loops`、`continuous-agent-loop`、`production-audit`
- **P2**：`cost-aware-llm-pipeline`、`cost-tracking`、`documentation-lookup`、`api-design`、`backend-patterns`、`strategic-compact`、`continuous-learning-v2`
- 新增 `scripts/sync-ecc-github-rules.ps1`；扩展 `sync-ecc-bundle.ps1` / `workflow-triggers`

## 2026-06-19（第三方 UI Skills）

- 从笔记软件 `.agents/skills/` vendoring：`frontend-design`、`ui-ux-pro-max`、`web-design-guidelines`
- `skills-lock.json` 合并四项第三方 Skill；`sync-vendor-skills.ps1` 支持整目录复制

## 2026-06-19（agent-browser）

- vendoring `agent-browser` Skill（[vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser)）→ `skills/agent-browser/`
- 新增 `skills-lock.json`、`scripts/sync-vendor-skills.ps1`；`.agents/` 为 CLI 暂存（gitignore）

## 2026-06-19（同步笔记软件实践）

- 从 `笔记软件/.cursor` 合并：L1+L3 动工门禁、TDD、Bugbot、code-review 流水线
- 新增 `templates/docs-standards/`（工作流索引、代码审查、TDD、Bugbot、版本门禁）
- 新增 `templates/docs-implementation-plan.md.template`（L3 方案）
- `STRUCTURE.md` 补充 Cursor 对 `.cursor/` vs 扁平目录的发现说明

## 2026-06-19（扁平化）

- **移除 `.cursor/` 包装层**：`rules/`、`skills/`、`agents/` 等提升至规范库根目录
- 业务项目复用时移入 `<项目>/.cursor/`；Bootstrap 脚本已适配
- 删除 `.cursor/README.md`（内容并入 `STRUCTURE.md`）

## 2026-06-19（清理）

- **移除人类可读规范**：删除根目录 `ai/`、`coding/`、`backend/`、`frontend/`、`api/`、`standards/` 及 `.cursor/STANDARDS-LINK.md`
- 约定全部落在 `.cursor/`（rules、skills、workflows、agents）
- Bootstrap 模板迁至仓库根 `templates/`（不再置于 `.cursor/templates/`）
- 修复 `templates/rules/*.mdc.template` 引用，指向 `.cursor/rules/` 而非外部规范目录

## 2026-06-19

### 结构

- 规范库根目录改为 `.cursor/`（符合 Cursor 标准布局）；`rules/*.mdc.template` 置于 `.cursor/rules/`
- 新增 `BOOTSTRAP.md` 作为唯一接入步骤
- `workflow-triggers.mdc` 改为极简 Rule；详表唯一来源为 Skill
- 新增 `backend/README.md`、`frontend/README.md`、`api/README.md`、`ai/README.md`
- 路径占位符 `{SPEC_ROOT}` 替代硬编码绝对路径（模板内）

### 工作流

- 路径触发：新 Controller/migration 须 `requirements-refinement` 已定稿
- 新增 `.cursor/evals/_example-requirements-handoff.md.template`

### 去项目专属引用

- 移除特定业务项目的路径、对照表与 hooks 说明
- 修复 `..cursor` 路径笔误为 `.cursor`
- 目录 `cursor/` 重命名为 `.cursor/`；Rule 模板扁平化到 `.cursor/rules/`

### ECC vendoring（同日）

- `.cursor/agents/`：19 个 ECC agents + 5 个项目角色 agents（运行时 `*.md`）
- `.cursor/rules/`：25 条 ECC rules + 7 条项目 rules（运行时 `*.mdc`）
- `.cursor/evals/`：`_example-feature.md`、`_example-requirements-handoff.md`
- `scripts/sync-ecc-bundle.ps1`：从 `~/.cursor` 刷新 ECC 副本
- 占位符版移至 `.cursor/templates/`；BOOTSTRAP 改为整包复制 `.cursor`

### 产品/设计/Vue（同日）

- vendored Skills：`market-research`、`deep-research`、`product-capability`、`blueprint`、`frontend-design-direction`、`ui-to-vue`、`make-interfaces-feel-better`、`research-ops`
- Agents：`marketing-agent`、`a11y-architect`；Vue：`vue-reviewer`、`vue-build-resolver`、`frontend-vue-dev`
- Rules：`vue-*.mdc`（5 条）、`frontend-vue.mdc`

### 结构（2026-06-19 晚）

- 人类规范合并：`ai/`、`coding/`、`backend/`、`frontend/`、`api/` → **`standards/`**
- 业务项目**只复制** `.cursor/`；新增 `scripts/bootstrap-project.ps1`
- 新增 `.cursor/STANDARDS-LINK.md` 说明链接模式

### 工作流剧本（同日）

- `.cursor/workflows/`：需求、设计、开发、交付四条主流程
- Skill：`workflow-playbooks`；`agent-patterns.md` 对接智能体模式

### 智能体模式（同日）

- `requirements-refinement`、`parallel-execution`、`智能体模式.md`

## 2026-06-12

- 初版从业务项目实践抽离为通用库
