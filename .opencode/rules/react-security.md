# React 安全

- 默认文本插值。用户 HTML 须消毒后再渲染，否则不要用 `dangerouslySetInnerHTML`
- 跳转与资源地址先校验，再绑到 `href` / `src`
- 客户端只放项目公开的环境变量（Vite 为 `VITE_*`）。密钥与管理端令牌不进包
- 是否允许操作由服务端决定。前端隐藏按钮不是鉴权

