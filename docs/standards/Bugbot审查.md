# Bugbot 审查

> 状态：**已定稿** · {DATE}  
> 来源：Cursor Skill `/review-bugbot`  
> 关联：[代码审查.md](./代码审查.md) · [工作流索引.md](./工作流索引.md)

Bugbot 是对 **本地 diff** 的自动化缺陷扫描，侧重回归、静默失败、边界条件。与 `code-reviewer`（架构 / 规格）**互补**，不替代人工审查清单。

## 1. 何时触发

| 场景 | 命令 / 信号 |
|------|-------------|
| 用户显式要求 | `/review-bugbot` |
| PR / 合并前 | 与 `code-review-gate` 串联 |
| 修完 HIGH 项后 | 可选二次 Bugbot（`uncommitted changes`） |

**默认不自动改代码** — Bugbot 只输出发现；修复须另开任务或用户明确要求。

## 2.  invocation 规范（Agent）

启动 **恰好一个** `bugbot` subagent：

| 参数 | 值 |
|------|-----|
| `subagent_type` | `bugbot` |
| `readonly` | `true` |
| `run_in_background` | `false`（除非用户要求后台） |
| `description` | `Bugbot` |

### 2.1 Prompt 模板

```text
Full Repository Path: <绝对路径，如 {PROJECT_ROOT}>
Diff: branch changes | uncommitted changes | natural language
Base Branch: <仅当 Diff 为 branch changes 且基线不是默认 main 时填写>
Change Description: <Diff 为 natural language 时必填；按文件分块>
Custom Instructions: <用户专项指令，可选>
```

### 2.2 Diff 模式选择

| 模式 | 何时用 |
|------|--------|
| `branch changes` | **默认** — 相对默认基线分支的 merge-base，含已提交 + 暂存 + 未暂存 |
| `uncommitted changes` | 仅审查工作区脏改动 |
| `natural language` | git 不可用或 Bugbot 报「无法计算 diff」时的**最后手段** |

`Change Description` 格式（natural language）：

```text
path/to/file.ts (modified):
- 变更要点（可选 L40-58）
path/other.ts (added):
- …
```

### 2.3 失败重试

1. 调用格式错误 → 修正后**立即重试一次**
2. 无法计算 diff → 改用 `Diff: natural language` + `Change Description`，**重试一次**
3. 仍失败 → 停止，向用户说明 blocker（如 git 仓库不可用）

### 2.4 PR / 指定分支

用户指定 PR 或分支时：**先 checkout 目标分支**（冲突则询问是否 stash），再启动 Bugbot。

## 3. 输出格式（Agent 汇总给用户）

### 3.1 无 diff

> 没有可审查的 diff。

### 3.2 无问题

> Bugbot found no bugs.

### 3.3 有问题

按严重度降序，**仅此三列**：

| Severity | Location (file:line) | Finding |
|----------|----------------------|---------|
| HIGH | `documents.ts:145` | loading 时丢弃 onEditorUpdate |

## 4. 与 code-review-gate 分工

| Bugbot | code-reviewer / 代码审查.md |
|--------|----------------------------|
| diff 驱动、回归、静默 bug | 规格、架构、可维护性 |
| 短表格式输出 | 审查记录归档到领域规范 |
| 不修复（除非用户要求） | 可委派修复 |

**推荐顺序：** TDD GREEN 后 → `code-reviewer` → `/review-bugbot` → `verification-gate`

## 5. 本项目 Bugbot 自定义指令（编辑器 Phase B）

审查编辑器相关 diff 时，在 `Custom Instructions` 中默认包含：

- loading 态是否导致输入丢失（`documents.ts` · `EditorPane.vue`）
- savePatch FK / parent 校验 / 环检测
- 纸面 CSS：padding 是否在 `.editor-pane__body`（非 `.block-editor`）
- Slash 空列表键盘、菜单定位
- 对照 [{DOMAIN_SPEC}.md](./{DOMAIN_SPEC}.md) §6 已知 HIGH

## 6. 审查记录归档

Bugbot 发现与 code-review 合并去重后：

- **HIGH+** → 写入 [{DOMAIN_SPEC}.md](./{DOMAIN_SPEC}.md) §6 或对应能力交接文档
- 已修复项标注 **已修复** 与日期

## 7. 限制

- 依赖本地 git；仓库不完整时改用 `natural language`
- 不替代 `{TEST_CMD}` / 手测
- Skill 路径（Cursor）：`review-bugbot`
