---
name: project-spec-fix
description: >-
  缺陷修复特化：先复现再最小 diff，回归测试锁住，不扩成新功能。
  触发：修 bug、缺陷、报错、复现、regression、崩了、不对、修一下。
origin: 项目规范
---

# 项目规范 · 修缺陷

现有行为错了才用本 Skill。要加能力、改契约、改交互流程 → 改走 `project-spec` 全量 propose。

## 升级条件（命中任一则 STOP，转全量 OpenSpec）

- 新 API / 新表 / 新页面主流程
- 修复方式会改变对外可观察契约（不只是「以前坏了」）
- 用户其实在要新功能，只是口吻像修 bug

## 步骤

1. **G0** 读基线。声明 `场景: 修缺陷`。
2. **复现**：命令、请求、页面路径、期望 vs 实际。复现不了 → STOP 问用户，禁止盲改。
3. **定位**：只读检索相关路径；记下根因一句话。
4. **回归锁**：先写失败检查（单测优先；否则 `tests.md` 里可重复步骤）。未红就改代码 → 不允许。
5. **OpenSpec 轻量 change**（有 `openspec/` 时）：

```bash
openspec new change "fix-<short-name>"
```

`.openspec.yaml` 设 `skip_specs: true`（纯修复、需求文本不变）。  
产物用 [templates/fix.md](../project-spec/templates/fix.md) 写入 `proposal.md`（为何坏、根因、改哪些文件）。  
`tests.md` 只保留复现 + 回归；`handoff.md` 照常。  
**不要**为了过校验编造 ADDED Requirement。

6. 用户说「直接修」且变更面 <3 文件：可跳过 new change，但仍必须有复现记录 + 回归检查（写在回复和 `handoff` 或 `evals/`）。
7. **最小 diff**：只改根因；禁止顺手重构、改无关样式、加功能。
8. 绿了 → `verification-gate`。改 backend → `backend-verify`。
9. 会话未结束：更新 `handoff.md`。

## 门禁（本场景）

| 适用 | 说明 |
|------|------|
| G0 G4 G8 G9 | 必守 |
| G1 G2 | 仅当你创建了 change：proposal 写完再改代码，或用户明确「直接修」 |
| G3 | 至少 1 条回归检查，不要求全量 spec 场景 |
| G5 | 用户要求归档才 archive |

## 反模式

- 修不好就扩大范围「重写模块」
- 没有复现就猜
- 把缺陷当新需求写一堆 spec
