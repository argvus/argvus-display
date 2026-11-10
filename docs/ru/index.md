---
title: Дисплеи
description: Настройте мониторы и макеты.
---
`argvus-display` предоставляет `argvus displayctl` и интегрирует сохранённые макеты с Hyprland. Проверьте состояние с помощью:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
Помощник также поддерживает `--set <monitor> <key> <value>` и `--apply-nwg`. Сгенерированные переопределения монитора являются частью состояния конфигурации ARGVUS; см. [configuration files](/docs/reference/configuration-files/).

В Центре управления откройте **Дисплеи** или выполните поиск монитора. Доступные настройки зависят от возможностей и могут включать разрешение, частоту обновления, масштаб, положение, ориентацию, основной дисплей, VRR и HDR. Настройка не отображается как поддерживаемая только потому, что модель монитора существует в общей списке; активный композитор и сервер монитора должны сообщать о её поддержке.

Применение макета дисплея изменяет текущую конфигурацию мониторов Hyprland и сохраняет состояние поддерживаемого макета для последующих сессий. Используйте последовательность применения/отмены на странице, когда она доступна. Если монитор становится непригодным, вернитесь на страницу дисплея или используйте `argvus displayctl --apply` с сохранённым состоянием, вместо редактирования сгенерированных файлов.

## Управление дисплеем через командную строку

Используйте `argvus displayctl` для запроса и изменения настроек дисплея без графического интерфейса:

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
Названия мониторов отображаются как `--status` (обычно `HDMI-1`, `DP-2`, `eDP-1` для ноутбуков и т.д.). После использования `--settings` для внесения изменений через графический интерфейс сеанс автоматически перезагружается для их применения.
