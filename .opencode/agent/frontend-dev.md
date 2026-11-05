---
description: "前端工程师。改 frontend/、React 页面与组件时使用。"
mode: subagent
---

# 前端开发 Agent

## 职责

- `frontend/**`：pages、components、api、types
- 目录与约定：`rules/frontend-react`（React）或 `rules/frontend-vue`（Vue）

## 执行前

1. `constraints.md`
2. `docs/design/03-API设计.md`（若消费新 API）
3. 禁止调用已废弃 API 路径（按项目维护清单）

## 交付

- `cd frontend && npm run build` 通过
- types + api 与后端 DTO 一致

## 项目约束（按项目填写）

- （按项目填写）

