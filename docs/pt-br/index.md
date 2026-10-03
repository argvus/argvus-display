---
title: Displays
description: Configure monitores e layouts.
slug: pt/0.4.0/docs/user-guide/hardware/displays
---

`argvus-display` fornece `argvus-displayctl` e integra layouts salvos ao Hyprland:

```sh
argvus-displayctl --status
argvus-displayctl --list-modes <monitor>
argvus-displayctl --apply
argvus-displayctl --settings
```

Também há `--set <monitor> <key> <value>` e `--apply-nwg`. Consulte [arquivos de configuração](/pt/docs/reference/configuration-files/).

No Control Center, abra **Displays** ou busque por um monitor. As configurações disponíveis dependem das capacidades e podem incluir resolução, taxa de atualização, escala, posição, orientação, display principal, VRR e HDR. Um controle só aparece quando a sessão ativa e o backend do monitor informam que ele pode ser aplicado.

Aplicar um layout de displays altera a configuração de monitores do Hyprland em execução e salva o estado suportado para as próximas sessões. Use o fluxo de aplicar/reverter da página quando disponível. Se um monitor ficar inutilizável, retorne à página de displays ou use `argvus-displayctl --apply` com o estado salvo, em vez de editar arquivos gerados.

## Gerenciamento de displays pela linha de comando

Use `argvus-displayctl` para consultar e alterar configurações de display sem a interface gráfica:

```sh
# Mostrar status do monitor e nomes
argvus-displayctl --status

# Listar modos disponíveis para um monitor
argvus-displayctl --list-modes <monitor>

# Definir uma propriedade específica
argvus-displayctl --set <monitor> scale 1.25
argvus-displayctl --set <monitor> dpi 120
argvus-displayctl --set <monitor> power off
argvus-displayctl --set <monitor> power on

# Aplicar layout salvo
argvus-displayctl --apply

# Abrir as configurações de display gráficas
argvus-displayctl --settings
```

Os nomes dos monitores são mostrados por `--status` (tipicamente `HDMI-1`, `DP-2`, `eDP-1` para laptops, etc.). Depois de usar `--settings` para fazer mudanças com a GUI, a sessão automaticamente recarrega para aplicá-las.
