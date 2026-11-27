# Codex 个人配置（原创脱敏版）

更新日期：2026-11-27。

## 文件

- `AGENTS.md`：模型优劣势认知校准（反过度防御/过度工程化）、通俗沟通风格、一次白盒 + 一次真实环境黑盒验收及交付边界原则。
- `sol-worker.config.toml`：`gpt-6.2-sol` 子任务执行角色配置（跨文件实现与复杂调用链定位）。
- `luna-worker.config.toml`：`gpt-6-luna` 子任务执行角色配置（明确有界的局部/重复性任务）。
- `config.example.toml`：模型、指令文件挂载与 `sol_worker` / `luna_worker` 角色的最小配置示例（已剔除官方内置基础系统提示词副本）。

## 使用

将提示词与角色配置文件放入自己的 `$CODEX_HOME`（通常为 `~/.codex`），把 `config.example.toml` 中的路径替换为本机实际路径后合并至 `config.toml`。本机私有 MCP 服务、设备标识与内部环境地址留在各自机器配置中，不入公开仓。
