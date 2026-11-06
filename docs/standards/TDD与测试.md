# TDD 与测试

> 状态：**样板** —— 复制到业务仓后，按 `{...}` 填本项目的真实命令与目录
> 关联：`skills/tdd-workflow`（平台提供时）· `rules/common-testing` · [工作流索引.md](./工作流索引.md) · [代码审查.md](./代码审查.md)

## 1. 何时必须 TDD

| 场景 | TDD |
|------|-----|
| 新功能、新 API、新核心函数 | **必须** |
| 修 bug（可复现） | **必须**（先写失败用例） |
| 重构（行为不变） | 先有测试再改 |
| 纯文档 / 注释 | 可跳过 |
| 紧急 one-liner（无逻辑变更） | 可跳过，须在 PR 说明 |

## 2. 覆盖率要求

| 类型 | 要求 |
|------|------|
| **Unit** | 函数、组件逻辑、核心纯函数 |
| **Integration** | 接口 handler、repository、事务 |
| **E2E** | 关键用户流（{E2E_FLOW}） |
| **合计** | **≥ 80%**（核心模块重点；见 `rules/common-testing`） |

本项目命令：

```bash
{TEST_CMD}                 # 全量单测
{TEST_CMD} {UNIT_DIR}      # 只跑核心模块
{TEST_CMD} {INTEGRATION_DIR}   # 集成 / 冒烟
```

## 3. RED → GREEN → REFACTOR

### 3.1 RED（先写测试，禁止先改生产代码）

1. 写用例（描述用户可见行为或核心不变量）
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
- 遵循不可变数据与项目编码风格（见 [coding-conventions.md](./coding-conventions.md)）

### 3.4 Git 检查点（仓库可用时）

| 阶段 | 建议 commit message |
|------|---------------------|
| RED 已验证 | `test: add reproducer for <feature or bug>` |
| GREEN 已验证 | `fix: <feature or bug>` |
| REFACTOR 完成 | `refactor: clean up after <feature>` |

- 检查点须在当前功能分支、当前任务序列上
- 用户未要求时不主动 commit

## 4. 测试分层（本项目）

```
{UNIT_DIR}/            # 核心函数与不变量
{INTEGRATION_DIR}/     # 接口 / 事务 / IPC 冒烟
{FRONTEND_TEST_DIR}/   # 前端 util / store / 组件
{E2E_DIR}/             # 端到端冒烟
```

### 4.1 核心层必测场景

- [ ] `{CORE_FN_1}` 的往返 / 幂等
- [ ] `{CORE_FN_2}`：增删改、边界输入
- [ ] `{CORE_FN_3}`：顺序与引用一致性
- [ ] 无效引用的拒绝路径

### 4.2 接口 / 主流程建议场景

- [ ] 创建 → 修改 → 读取 的完整往返
- [ ] 批量写入（多层级嵌套）的 upsert
- [ ] 校验失败返回明确错误码（非裸 `DB_ERROR`）

### 4.3 前端建议场景

- [ ] 状态重建后与源数据一致
- [ ] loading 期间不丢弃用户输入

## 5. 测试编写约定

### 5.1 命名

```typescript
describe('formatDate', () => {
  it('空值返回空串', () => { … })
})
```

### 5.2 结构：Arrange → Act → Assert

### 5.3 禁止

- 测实现细节（内部 state）而非行为
- 测试间依赖顺序
- 为覆盖率写无断言的「空测试」

### 5.4 边界与错误路径

每个公共函数至少覆盖：正常路径、空输入、非法输入、边界（空集合、环状引用等）。

## 6. 与审查 / 交付的关系

```
TDD (RED→GREEN→REFACTOR) → code-review-gate → Bugbot → verification-gate
```

| 环节 | TDD 相关检查 |
|------|----------------|
| code-review-gate | 新逻辑是否有测试；核心模块 ≥ 80% |
| Bugbot | 测试是否覆盖本次 diff 的回归点 |
| verification-gate | `{TEST_CMD}` 全绿 |

## 7. Agent 触发

| 信号 | 动作 |
|------|------|
| 新功能 / 修 bug | 按 §3 执行；测试设计可交给 `qa-engineer` |
| 构建 / 测试失败 | `build-fix` Skill |
| 交付前 | `verification-gate` Skill |

Skill 路径：`tdd-workflow`（平台提供时）· `qa-engineer`（本库 Agent）· `build-fix`
