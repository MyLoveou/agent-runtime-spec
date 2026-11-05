# 交付工作流

> **目标**：可重复的 DoD。每次声称完成或 stop hook 时执行。

## 入口口令

- 「交付工作流」「验收」「DoD」「准备 PR」

## 流程图

```mermaid
flowchart TD
  A[声称完成] --> B[verification-gate]
  B --> C{eval 存在?}
  C -->|是| D[eval-harness]
  C -->|否| E[标准 DoD]
  D --> E
  E --> F[code-review-gate]
  F --> G[用户确认 commit/PR]
  G --> H{OpenSpec change?}
  H -->|是且用户要求| I[openspec archive]
```

## 阶段

| 阶段 | Skill / Agent | 产出 |
|------|----------------|------|
| 1 验证 | `verification-gate`；改 backend 则 `backend-verify` | DoD |
| 2 审查 | `code-review-gate` · `@code-reviewer` | 审查意见 |
| 3 归档 | `project-spec` archive（用户确认后） | 主 spec 更新 |
