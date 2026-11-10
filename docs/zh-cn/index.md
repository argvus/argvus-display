---
title: 显示器
description: 配置显示器和布局。
---
`argvus-display` 提供 `argvus displayctl` 并将保存的布局与 Hyprland 集成。通过以下方式检查状态：

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
该助手还支持 `--set <monitor> <key> <value>` 和 `--apply-nwg`。生成的监视器覆盖是 ARGVUS 配置状态的一部分；请参见 [configuration files](/docs/reference/configuration-files/)]。

在控制中心中，打开 **显示器** 或搜索监视器。可用的设置取决于功能，可能包括分辨率、刷新率、比例、位置、方向、主显示器、VRR 和 HDR。某个设置仅因监视器型号出现在通用列表中并不意味着被支持；必须由活动合成器和监视器后端报告。

应用显示布局会更改正在运行的 Hyprland 监视器配置，并保存受支持的布局状态以供将来会话使用。在可用时使用页面的应用/恢复流程。如果监视器变得不可用，请返回显示页面或使用 `argvus displayctl --apply` 以及保存的状态，而不是编辑生成的文件。

## 命令行显示管理

使用 `argvus displayctl` 查询和更改显示设置，而无需图形界面：

```sh
# Show monitor status and names
argvus displayctl --status

# List available modes for a monitor
argvus displayctl --list-modes <monitor>

# Set a specific property
argvus displayctl --set <monitor> scale 1.25
argvus displayctl --set <monitor> dpi 120
argvus displayctl --set <monitor> power off
argvus displayctl --set <monitor> power on

# Apply saved layout
argvus displayctl --apply

# Open the graphical display settings
argvus displayctl --settings
```
显示的监视器名称为 `--status`（通常笔记本电脑为 `HDMI-1`、`DP-2`、`eDP-1` 等）。在使用 `--settings` 通过 GUI 进行更改后，系统会自动重新加载会话以应用这些更改。
