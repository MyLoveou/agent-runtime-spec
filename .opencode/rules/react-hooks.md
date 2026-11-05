# React Hooks

指组件里的 Hooks，不是编辑器的 hooks 运行时。

- 只在函数组件或自定义 hook 的顶层调用，不放在条件、循环里
- 能由 props/state 算出来的值用渲染期计算，不用 `useEffect` 再抄一份
- `useEffect` 用于与外部系统同步，并在清理函数里取消订阅或请求
- 自定义 hook 复用状态与请求，不把领域规则藏进 hook

