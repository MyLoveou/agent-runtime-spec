# 项目决策记忆（压缩）

> 跨会话先读最近条 + `facts.md`。每条 ≤8 行。

## 有效决策

### D-20261108-05 · `learning-notes` 是必装技能

- 场景：经验总结此前只对三个 DSH 项目生效；`gitmove-v2`、`source-manager` 与新项目模板都漏装
- **决定**：每个装配单的 `skills` 必须含 `learning-notes`；`spec-check` 强制校验（缺即报错），`selftest` 增加对应负例；`_template` 默认带上
- **不选**：靠人记得加（这次就是漏的例子）；只在 `_template` 加而不校验（存量项目照旧漏）
- **注意**：Cursor / OpenCode 另有同名规则（alwaysApply / instructions），两边不冲突——规则管「必须写」，技能管「怎么写」
- 状态：有效

### D-20261108-04 · ComfyUI 只接方法与配置，不把服务装进仓

- 场景：本机已有 ComfyUI（桌面版，`127.0.0.1:8188`）；agent 需要本地生图能力
- **决定**：新增技能 `comfy-workflow`（HTTP API + 工作流即数据 + 队列/显存纪律 + 失败表）与 `references/mcp-setup.md`（Cursor / OpenCode 配置片段）；MCP 条目由业务仓自己加，本仓不放
- **不选**：把 ComfyUI MCP 写进本仓 `mcp.json`（本仓不产图，只会给每次会话加噪音）；把服务或模型权重入库（体积与许可）；整包搬 `Comfy-Org/comfy-skills`（Claude Code 插件形态，绑定 slash command 与云端）
- **安全**：ComfyUI 默认无鉴权，`/prompt` 可执行任意已装节点，只允许连本地回环实例
- **落点**：`skills/comfy-workflow`、`projects/video` 装配单
- 状态：有效

### D-20261108-03 · 版本用 semver + VERSION + tag，tag 必须推远程

- 场景：仓库有 `v1.0.0` 标签但只在本地，且钉在重构前的提交上；外部工具按「commit → 版本」映射时已经失真
- **决定**：主版本 = 破坏性变更（目录结构 / 删资产 / 契约变化），次版本 = 新增资产，修订 = 修正；版本号写 `VERSION`，历史写 `docs/releases.md`；每次发版打 annotated tag 并 `git push --tags`
- **不选**：只维护 `VERSION`（机器无法按 commit 定位）；只在 CHANGELOG 里写（没有可校验的锚点）
- **当前**：2.0.0（三平台自包含重构 + 删生成脚本属破坏性）
- 状态：有效

### D-20261108-02 · 推送走分支，再合并 main

- 场景：多个会话/工具同时在改本仓，直推 main 会互相顶掉
- **决定**：一律从最新 main 切 `feat|fix|docs/<主题>` 分支，推分支后再合并回 main；合并前重跑闸门；分支一次交付即删
- **不选**：直推 main（会冲突且无 review 窗口）；长驻 develop（单人仓库多一条常设分支是负担）
- **配套**：`AGENTS.md` 增「推送流程」；冲突在分支内 rebase 解决，不留给 main
- 状态：有效

### D-20261108-01 · 交付后必须附一条经验总结（学习向）

- 场景：项目由 AI 执行，但人需要理解原理；`资源管理器/docs/经验总结` 已有 51 篇可借鉴的写法（结论 + 原则 + 入口 + 踩坑 / 学习向 / 图解）
- **决定**：新增规则 `common-learning-notes`（每次交付后写一条）+ 技能 `learning-notes`（四类模板与写法）；固定目录 `docs/经验总结/`、命名 `<序号>-<类型>-<主题>.md`、序号连续；交付回复末尾附路径 + 一句话知识点
- **内容要求**：结论先行 → 原理（含替代方案与边界）→ 可验证的最小实验 → 一条延伸；禁复述代码、禁「学习了」这类空话
- **不选**：只靠自愿（会漏）；写进代码注释（读者不看）；只写「做了什么」（没有原理，等于没沉淀）
- **落点**：`rules/common-learning-notes`、`skills/learning-notes`、`verification-gate` 阶段 5 与输出格式、`AGENTS.md` 读什么表
- 状态：有效

### D-20261107-01 · 外部视频技能只改编、不整包搬运

- 场景：视频项目需要剪辑/字幕/脚本类技能；上游有 [puntorigen/avatar-skills](https://github.com/puntorigen/avatar-skills)（MIT，48 个）与 [varghq/skills](https://github.com/varghq/skills) 的 FFmpeg cookbook
- **决定**：取方法、重写正文，新增 `video-compose` / `video-shortform-script` / `video-captions` / `video-cut-grammar` 四个 skill；正文平台中立、不含 `~/.cursor` 之类硬编码路径，不打包上游 Python 脚本与云端 API 依赖
- **不选**：整包 vendor（3 份副本 × 48 技能，且正文违反「平台中立」硬规则）；直接 `npx skills add` 到本仓（会把外部路径与云端 token 依赖写进运行时资产）
- **归属**：每个 SKILL.md 末尾标注来源与 MIT；FFmpeg 配方重写自 varghq cookbook
- **配套**：技能数 30 → 34；`projects/video` 装配单加入这四个
- 状态：有效
### D-20261107-02 · oil-ui 只收定方向的方法

- 场景：已有工艺约束，缺一套「新界面先认产品、锁主角、灰度先于配色、用真实画面验收」的方法
- **决定**：接入改写后的 `oil-ui`。默认一个方向；确认前仍停在 `project-spec-design`；已有产品沿用现有视觉；动效默认不加
- **不选**：整份上游技能（生图脚本、字体、风格对比页生成器、版本检查、完整版推销）；它默认的「确认一次就做到底」和「新页面必须三处动效」
- **配套**：技能数 29 → 30；两个 Vue 桌面项目的装配单启用
- 状态：有效

### D-20261107-01 · 界面工艺用证据和项目自己的样式，不换皮

- 场景：业务仓做界面时，只有「先定观感」和「只改样式」两条门禁，缺少间距、字体、抛光、无障碍、动效性能和探索画布
- **决定**：接入 9 个技能。底线与审计来自 ibelick/ui-skills；风格与样式用 `better-ui` / `better-layout` / `better-typography`（跟项目 token，不另起视觉系统）。定方向仍是 `project-spec-design`，只改样式仍是 `project-spec-style`
- **不选**：`frontend-design`、瑞士风、北欧风、`ui-ux-pro-max` 一类整套审美；`create-design-md`（另一套 DESIGN.md 工具链）；`ui-skills-root`（外部 CLI 路由）；`fixing-metadata`（发布信息）；`better-colors` / `better-writing`（色板跟项目，文案另说）
- **配套**：三平台各一份；`gitmove-v2`、`source-manager` 装配单启用；技能数 20 → 29
- 状态：有效

### D-20261106-12 · 接受「导出后不能反哺」，只记录限制

- 场景：`assemble.ps1` 是复制，导出后业务仓那份与本仓脱钩；无法在业务仓里改公共资产再回到本仓
- **决定**：保留单向导出，但把限制写成文档（`projects/README.md` 与 `project-assembly` Skill）；本次不改实现
- **不选**（现在不做）：引用式分发（submodule / 私有包）能根治，但会改变业务仓的构建方式，需要单独设计
- **判断依据**：先把限制显性化，等真的需要在业务仓修改公共资产时再评估
- 状态：有效（限制已知，行为不变）

### D-20261106-11 · 允许单向导出，仍然禁止生成 / 同步

- 场景：装配单只有名字，落地还得人按清单挑文件；希望在 `projects/<项目>/` 上一键导出
- **决定**：新增 `project-assembly` 技能，`assemble.ps1` 读装配单，把规则 / Agent / Skill 子集**单向**复制到外部业务仓；默认不覆盖内容不同的文件（`-Force` 才覆盖），不删目标文件，不动配置文件
- **不选**：回到「`shared/` → 平台目录」的生成器（仓内两份源，会被删第二遍）；双向同步（本仓会被业务仓反向污染）
- **与其他决定的关系**：D-20261106-01 / D-20261106-03 禁的是「仓内生成与同步」；本次允许的是「仓 → 外」的导出，方向相反、真源唯一
- **配套**：`spec-check` 已有装配单校验；技能数 19 → 20
- 状态：有效
### D-20261106-10 · 按项目装配单，只存清单不存副本

- 场景：不同业务仓需要的规则 / Skill 不同；全量拷贝是 117 个文件 243 KB，且本仓改动后无法定位影响面
- **决定**：`projects/<项目>/assembly.json` 记装配清单（规则支持 `*` 通配、`include`/`exclude`、`skills`、`agents`），边界写在 `projects/README.md`
- **不选**：物化一份项目目录（第 4 份副本，必然漂移，等同被 D-20261106-01 删掉的 `domains/`）；只在 docs 列表格（无法校验、无法按平台区分）
- **边界**：不生成、不同步、不跨目录引用；业务仓仍是「拷目录即用」，清单只是档案
- **配套**：`spec-check` 新增装配单校验（引用存在、include/exclude 不相交、platforms 合法），`selftest` 增至 6 条
- 状态：有效
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
