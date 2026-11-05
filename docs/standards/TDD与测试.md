# TDD 与测试

> 状态：**已定稿** · {DATE}  
> 来源：Cursor Skill `/tdd-workflow` · 项目 Rules `common-testing.mdc`  
> 关联：[工作流索引.md](./工作流索引.md) · [代码审查.md](./代码审查.md)

## 1. 何时必须 TDD

| 场景 | TDD |
|------|-----|
| 新功能、新 API、新 domain 函数 | **必须** |
| 修 bug（可复现） | **必须**（先写失败用例） |
| 重构（行为不变） | 先有测试再改 |
| 纯文档 / 注释 | 可跳过 |
| 紧急 one-liner（无逻辑变更） | 可跳过，须在 PR 说明 |

## 2. 覆盖率要求

| 类型 | 要求 |
|------|------|
| **Unit** | 函数、组件逻辑、domain 纯函数 |
| **Integration** | IPC handler、repository、savePatch 事务 |
| **E2E** | 关键用户流（新建 → 编辑 → 重启） |
| **合计** | **≥ 80%**（domain 包重点；见 `common-testing.mdc`） |

本项目命令：

```bash
{TEST_CMD}                    # Vitest（跑前停 dev；必要时 pnpm rebuild:native:node）
pnpm exec vitest run packages/domain   # domain 单测
pnpm exec vitest run electron/main/__tests__   # IPC 冒烟（需 native 与 Electron ABI 一致）
```

## 3. RED → GREEN → REFACTOR

### 3.1 RED（先写测试，禁止先改生产代码）

1. 写用例（描述用户可见行为或 domain 不变量）
2. 运行测试，**必须失败**
3. 失败原因须为「缺实现 / 业务 bug」，而非语法错误或无关 setup

**有效 RED：**

- 运行时 RED：测试编译通过、执行失败、原因正确
- 编译期 RED：新测试引用尚未存在的 API（仅当该 API 为待实现部分）

**无效 RED：** 仅写测试未运行；或失败因 mock 错误、无关回归。

### 3.2 GREEN（最小实现）

- 只写让测试通过的最小代码
- 再跑同一测试目标，确认 GREEN

### 3.3 REFACTOR

- 测试仍绿的前提下改善命名、去重、提取函数
- 遵循不可变数据与项目编码风格

### 3.4 Git 检查点（仓库可用时）

| 阶段 | 建议 commit message |
|------|---------------------|
| RED 已验证 | `test: add reproducer for <feature or bug>` |
| GREEN 已验证 | `fix: <feature or bug>` |
| REFACTOR 完成 | `refactor: clean up after <feature>` |

- 检查点须在当前功能分支、当前任务序列上
- 用户未要求时不主动 commit（见用户规则）

## 4. 测试分层（本项目）

```
packages/domain/src/__tests__/     # buildPmDoc, diffPmDoc, orderBlockPatch, …
electron/main/__tests__/           # IPC smoke（savePatch 往返）
src/**/__tests__/                  # 前端 util / store（待补充）
e2e/                               # Playwright 冒烟（v1.0 验收）
```

### 4.1 Domain 必测场景

- [ ] `buildPmDoc` ↔ `flattenPmDoc` 往返
- [ ] `diffPmDoc`：增删改块、codeBlock attrs
- [ ] `orderBlockPatch`：嵌套 list FK 顺序、reparent delete 顺序
- [ ] `validateBlockPatchParentRefs`：无效 parent、自引用

### 4.2 IPC / 主进程建议场景

- [ ] create doc → savePatch → get 单段落
- [ ] **建议**：`bulletList > listItem > paragraph` 多块 upsert
- [ ] savePatch 校验失败返回明确错误码（非裸 `DB_ERROR`）

### 4.3 前端建议场景

- [ ] `reconcileEditorPm` 后 snapshot 与 pmDoc 一致
- [ ] `load()` loading 期间不丢失 `onEditorUpdate`（待 HIGH 修复后）

## 5. 测试编写约定

### 5.1 命名

```typescript
describe('orderBlockPatch', () => {
  it('upsert 父块先于子块', () => { … })
})
```

### 5.2 结构：Arrange → Act → Assert

### 5.3 禁止

- 测实现细节（内部 state）而非行为
- 测试间依赖顺序
- 为覆盖率写无断言的「空测试」

### 5.4 边界与错误路径

每个公共函数至少覆盖：正常路径、空输入、非法输入、边界（空 patch、环状 parent 等）。

## 6. 与审查 / 交付的关系

```
TDD (RED→GREEN→REFACTOR) → code-review-gate → Bugbot → verification-gate
```

| 环节 | TDD 相关检查 |
|------|----------------|
| code-review-gate | 新逻辑是否有测试；domain ≥ 80% |
| Bugbot | 测试是否覆盖本次 diff 的回归点 |
| verification-gate | `{TEST_CMD}` 全绿 |

## 7. Agent 触发

| 信号 | 动作 |
|------|------|
| `/tdd-workflow` | 读本规范 → RED → GREEN → REFACTOR |
| 新功能 / 修 bug | 主动 `@tdd-guide` 或按 §3 执行 |
| 构建失败 | `@build-error-resolver` / `@java-build-resolver` 等 |

Skill 路径（Cursor）：`tdd-workflow` · 项目 Agent `tdd-guide`。
