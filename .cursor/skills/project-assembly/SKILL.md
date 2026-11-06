---
name: project-assembly
description: >-
  按 projects/<项目>/assembly.json 把规则 / Agent / Skill 的子集单向导出到业务仓。
  导出工具，不是生成器：本仓平台目录是唯一真源，脚本只往目标目录写，从不回写本仓。
  触发：新项目开工、按装配单同步资产、导出某个项目的规则与技能、装配单落地。
---

# 项目装配导出

## 它是什么，不是什么

| 是 | 不是 |
|----|------|
| 单向导出：本仓 → 外部业务仓 | 生成器：不生产平台目录里的内容 |
| 按 `assembly.json` 选子集 | 同步器：不监听、不回写、不做双向 |
| 幂等：内容相同就跳过 | 配置合并器：不动 `opencode.json` / `mcp.json` |

被删过的 `generate.ps1` 是「`shared/` → 平台目录」，仓内两份源，必然漂移。这里方向相反，且本仓始终是唯一真源。

## 前置

- `projects/<项目>/assembly.json` 存在且通过校验（`spec-check` 会查引用与冲突）；
- 目标目录是**业务仓**，不是本仓内部（脚本会拒绝后者的路径）。

## 用法

```powershell
$s = 'skills/project-assembly/scripts/assemble.ps1'

& $s -Project source-manager -Target <业务仓> -DryRun    # 只看计划
& $s -Project source-manager -Target <业务仓>            # 执行
& $s -Project source-manager -Target <业务仓> -Force     # 覆盖内容不同的文件
& $s -Project source-manager -Target <业务仓> -Platforms cursor   # 只导出某平台
```

退出码：`0` 完成（或有跳过）；`1` 有缺失源文件或参数错误。

## 复制哪些

| 资产 | 来源 | 说明 |
|------|------|------|
| 规则 | `rules/<name>.mdc` 或 `.md` | `include` 展开后减掉 `exclude`；`dsh` 没有规则 |
| Agent | `agents/` 或 `agent/` | 按清单；`dsh` 没有 Agent |
| Skill | `skills/<name>/` 整个目录 | 含 `references/`、`scripts/` |
| 入口 | `assembly.entry` | 例如 `AGENTS.md`、`docs/` |

**不会做**：合并配置文件、删除目标多余文件、改写本仓。

## 冲突处理

- 目标已存在且内容**相同** → 计 `same`，跳过；
- 内容**不同** → 计 `diff`，默认跳过并提示，加 `-Force` 才覆盖；
- 源文件缺失 → 计 `missing`，逐条列出，退出码 1。

这条「默认不覆盖」是刻意的：业务仓可能有项目自己的改动，覆盖必须显式。

## 导出后还要手动做

1. `opencode.json`：把入口规则加进 `instructions`，合并 `mcp` 段（脚本不动配置）；
2. `constraints.md`：填 `{占位符}`；
3. `docs/product/`：按业务仓重写事实与决策；
4. 目标里多出来的旧资产：脚本不删，按需清理。

## 和校验的关系

- 导出**前**跑 `spec-check`：装配单引用失效会先报错，省得导到一半缺文件；
- 导出**后**：目标仓不在本仓校验范围内（它是外部仓），本仓只保证「清单有效、源文件齐全」。

## 已知限制（重要）

| 限制 | 后果 |
|---|---|
| 导出后是独立副本 | 业务仓的改动不会回到本仓，本仓改动也不会自动到业务仓 |
| 不自动合并 | 两边都改过 → 按 `diff` 跳过，冲突靠人工 |
| 不能跨项目反哺 | 在 A 项目里改的公共资产，必须先落本仓，再导出到 B |

只有单向顺序：本仓修改 → 校验 → 导出 → 业务仓提交。反向改动必须整理成本仓 PR，合并后重新导出。

## 边界

- 不生成内容、不双向同步、不自动提交业务仓；
- 不处理 `mcp.json` / `opencode.json` / `hooks.json` 这类配置合并；
- 不删除目标文件（要清理请人工确认后自己做）。
