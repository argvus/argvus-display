---
title: Pantallas
description: Configurar monitores y diseños.
---
`argvus-display` proporciona `argvus displayctl` e integra los diseños guardados con Hyprland. Inspecciona el estado con:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
El asistente también es compatible con `--set <monitor> <key> <value>` y `--apply-nwg`. Las anulaciones de monitor generadas son parte del estado de configuración de ARGVUS; vea [archivos de configuración](/docs/reference/configuration-files/).

En el Centro de Control, abra **Pantallas** o busque un monitor. Los ajustes disponibles dependen de las capacidades y pueden incluir resolución, frecuencia de actualización, escala, posición, orientación, pantalla principal, VRR y HDR. Un ajuste no se muestra como compatible simplemente porque el modelo del monitor exista en una lista genérica; el compositor activo y el backend del monitor deben informarlo.

Aplicar un diseño de pantalla cambia la configuración del monitor de Hyprland en ejecución y guarda el estado del diseño compatible para sesiones posteriores. Use el flujo de aplicar/revertir de la página cuando esté disponible. Si un monitor se vuelve inutilizable, regrese a la página de pantalla o use `argvus displayctl --apply` con el estado guardado en lugar de editar archivos generados.

## Gestión de pantalla desde la línea de comandos

Usa `argvus displayctl` para consultar y cambiar la configuración de la pantalla sin la interfaz gráfica:

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
Los nombres de los monitores se muestran como `--status` (típicamente `HDMI-1`, `DP-2`, `eDP-1` para portátiles, etc.). Después de usar `--settings` para hacer cambios con la interfaz gráfica, la sesión se recarga automáticamente para aplicarlos.
