# 项目事实基线

> 本仓库（cursor-project-spec）的实现与方向。只写已确认项。

**最后核对**：2026-09-23（栈规则收短；规则不全局安装；MCP 说明合一）

---

## 一、项目实现（现状）

### 做什么

- 产品一句话：维护 **Cursor** 用的规则、Agent、Skill、工作流、MCP、域包，供业务仓 bootstrap。
- 已交付：`project-spec` 家族（含 L1/L2/L3、组合式拆实现）、需求/规划/验收 Skill、`mermaid-diagrams`、Vue+React 短规则、enterprise-cert 域包、`mcp/`（codegraph/git/ssh；知识图谱可选且不进默认配置）。
- **尚未实现**：OpenCode/Hermes 适配；MCP 默认占位未接真实主机；本库无业务前后端代码。

### 怎么做的

| 层 | 技术 | 目录 |
|----|------|------|
| 规则源 | Markdown + YAML | `rules/` → `generate.ps1` → `.cursor/rules/` |
| Skill | `SKILL.md` | `shared/skills/` |
| 部署 | PowerShell | `scripts/bootstrap-project.ps1`、`install-global-skills.ps1` |

验收：改 Skill/规则后跑 `sync-domain-bundle.ps1`（若动域包）和 `install-global-skills.ps1`（若要全局）。

### 实现边界

- 本仓负责：Agent 行为约定与模板，不负责具体业务功能实现。
- 本仓不负责：业务数据、生产主机密钥、官方 OpenSpec 插件 Skill 名。

---

## 二、项目方向（已确认）

- 近端：规范驱动（事实基线、决策记忆、复杂需求先设计、UI/功能/算法可组合）。
- 明确不做：再灌网上 ECC Skill、默认只留一种前端、把算法/规则写进控件还称组合式。
- 原则：Cursor only；Skill 用自己的名 `project-spec`；CLI 仍叫 `openspec`。
- 规则随业务仓 bootstrap 生成到该仓 `.cursor/rules/`，不装进用户全局。
- MCP 说明只在 `mcp/`：codegraph / git / ssh 为默认；知识图谱仅企业认证可选。

## 未确认

（无）
