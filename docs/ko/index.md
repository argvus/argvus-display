---
title: 디스플레이
description: 모니터와 레이아웃을 구성합니다.
---
`argvus-display`는 `argvus displayctl`를 제공하고 저장된 레이아웃을 Hyprland와 통합합니다. 상태를 확인하려면:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
도우미는 또한 `--set <monitor> <key> <value>` 및 `--apply-nwg`를 지원합니다. 생성된 모니터 재정의는 ARGVUS 구성 상태의 일부입니다; [configuration files](/docs/reference/configuration-files/)을 참조하십시오.

제어 센터에서 **디스플레이**를 열거나 모니터를 검색하십시오. 사용 가능한 설정은 기능에 따라 다르며 해상도, 새로 고침 빈도, 배율, 위치, 방향, 기본 디스플레이, VRR 및 HDR을 포함할 수 있습니다. 모니터 모델이 일반 목록에 있다고 해서 설정이 지원되는 것으로 표시되지는 않습니다; 활성 합성기와 모니터 백엔드가 이를 보고해야 합니다.

디스플레이 레이아웃을 적용하면 실행 중인 Hyprland 모니터 구성이 변경되고 나중 세션을 위해 지원되는 레이아웃 상태가 저장됩니다. 페이지에서 적용/되돌리기 흐름을 사용할 수 있을 때 사용하십시오. 모니터를 사용할 수 없게 되면 디스플레이 페이지로 돌아가거나 생성된 파일을 편집하는 대신 저장된 상태와 함께 `argvus displayctl --apply`를 사용하십시오.

## 명령줄 디스플레이 관리

그래픽 인터페이스 없이 `argvus displayctl`를 사용하여 디스플레이 설정을 쿼리하고 변경하세요:

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
모니터 이름은 `--status`(보통 노트북의 경우 `HDMI-1`, `DP-2`, `eDP-1` 등)으로 표시됩니다. GUI를 사용하여 `--settings`로 변경한 후에는 세션이 변경 사항을 적용하기 위해 자동으로 다시로드됩니다.
