---
title: Affiche
description: Configurer les moniteurs et les dispositions.
---
`argvus-display` fournit `argvus displayctl` et intègre les mises en page enregistrées avec Hyprland. Inspectez l'état avec :

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
L'assistant prend également en charge `--set <monitor> <key> <value>` et `--apply-nwg`. Les dépassements de moniteur générés font partie de l'état de configuration ARGVUS ; voir [fichiers de configuration](/docs/reference/configuration-files/).

Dans le Centre de contrôle, ouvrez **Affichages** ou recherchez un moniteur. Les paramètres disponibles dépendent des capacités et peuvent inclure la résolution, le taux de rafraîchissement, l'échelle, la position, l'orientation, l'affichage principal, le VRR et le HDR. Un paramètre n'est pas affiché comme pris en charge simplement parce que le modèle de moniteur figure dans une liste générique ; le compositeur actif et le backend du moniteur doivent le rapporter.

L'application d'une disposition d'affichage modifie la configuration du moniteur Hyprland en cours d'exécution et enregistre l'état de disposition pris en charge pour les sessions ultérieures. Utilisez le flux d'application / restauration de la page lorsque disponible. Si un moniteur devient inutilisable, revenez à la page d'affichage ou utilisez `argvus displayctl --apply` avec l'état enregistré plutôt que de modifier les fichiers générés.

## Gestion de l'affichage en ligne de commande

Utilisez `argvus displayctl` pour interroger et modifier les paramètres d'affichage sans l'interface graphique :

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
Les noms des moniteurs sont affichés par `--status` (généralement `HDMI-1`, `DP-2`, `eDP-1` pour les ordinateurs portables, etc.). Après avoir utilisé `--settings` pour apporter des modifications avec l'interface graphique, la session se recharge automatiquement pour les appliquer.
