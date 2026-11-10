---
title: Anzeigen
description: Monitore und Layouts konfigurieren.
---
`argvus-display` bietet `argvus displayctl` und integriert gespeicherte Layouts mit Hyprland. Überprüfen Sie den Status mit:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
Der Helfer unterstützt auch `--set <monitor> <key> <value>` und `--apply-nwg`. Generierte Monitorüberschreibungen sind Teil des ARGVUS-Konfigurationszustands; siehe [configuration files](/docs/reference/configuration-files/).

Im Kontrollzentrum öffnen Sie **Displays** oder suchen Sie nach einem Monitor. Die verfügbaren Einstellungen hängen von den Fähigkeiten ab und können Auflösung, Bildwiederholrate, Skalierung, Position, Ausrichtung, primäres Display, VRR und HDR umfassen. Eine Einstellung wird nicht als unterstützt angezeigt, nur weil das Monitormodell in einer generischen Liste existiert; der aktive Kompositor und der Monitor-Backend müssen dies melden.

Die Anwendung eines Display-Layouts ändert die laufende Hyprland-Monitorkonfiguration und speichert den unterstützten Layout-Zustand für spätere Sitzungen. Verwenden Sie den Anwenden/Zurücksetzen-Flow der Seite, wenn verfügbar. Wenn ein Monitor unbrauchbar wird, kehren Sie zur Display-Seite zurück oder verwenden Sie `argvus displayctl --apply` mit dem gespeicherten Zustand, anstatt generierte Dateien zu bearbeiten.

## Kommandozeilen-Display-Verwaltung

Verwenden Sie `argvus displayctl`, um Anzeigeeinstellungen ohne die grafische Benutzeroberfläche abzufragen und zu ändern:

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
Monitor-Namen werden durch `--status` angezeigt (typischerweise `HDMI-1`, `DP-2`, `eDP-1` für Laptops usw.). Nach der Verwendung von `--settings`, um Änderungen mit der GUI vorzunehmen, wird die Sitzung automatisch neu geladen, um diese anzuwenden.
