# Capability Eval 示例

> 复制为 `evals/<your-feature>.md` 并按功能填写

## [CAPABILITY EVAL: your-feature-name]

**Task**: （一句话）

**Scope**: 对照 OpenSpec change 或已定稿需求 — IN SCOPE / OUT OF SCOPE

### Success Criteria

- [ ] 范围与规划一致
- [ ] 复杂需求：`设计.md` 已确认（含模型/交互/模块）；组合式含切片契约
- [ ] `docs/design/03-API设计.md` 已更新（若改 API）
- [ ] `docs/design/02-数据模型.md` 已更新（若改实体）
- [ ] 算法切片测试 PASS（若采用组合式）
- [ ] 组合根主路径可走通（只合算法不算交付）
- [ ] 构建命令 PASS
- [ ] 若改 backend：重启 + 冒烟 → PASS
- [ ] reviewers 无 BLOCKER（建议）

### Regression

- [ ] （按项目填写）
- [ ] （按项目填写）

### Grader Commands

```powershell
# 按 tests.md：算法单测、功能用例、页面主路径
cd frontend && npm run build
.\mvnw.cmd test
# 冒烟：见 docs/product/dev-accounts.md（若存在）
```

### Expected Output

（用户可见结果）

### EVAL REPORT

```
Capability: _/_ 
Regression: _/_ 
Status: NOT STARTED
```
