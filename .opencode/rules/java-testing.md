# Java 测试

对照 `tests.md` 与 `common/testing`。覆盖率以 `constraints.md` 为准。

- 领域规则、服务编排优先单测或切片测试
- 算法切片测纯输入输出；不要在 Controller 测试里重写业务规则
- 改 `backend/**` 后：`mvnw test`（或 `mvn test`）→ 重启 → 冒烟。见 `backend-verify`
- 失败时改实现。测试与已确认 spec 不符时才改测试

