---
title: Schermi
description: Configura monitor e layout.
---
`argvus-display` fornisce `argvus displayctl` e integra i layout salvati con Hyprland. Ispeziona lo stato con:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```
L'assistente supporta anche `--set <monitor> <key> <value>` e `--apply-nwg`. Le sovrascritture del monitor generate fanno parte dello stato di configurazione ARGVUS; vedi [configuration files](/docs/reference/configuration-files/).

Nel Centro di Controllo, apri **Display** o cerca un monitor. Le impostazioni disponibili dipendono dalle capacità e possono includere risoluzione, frequenza di aggiornamento, scala, posizione, orientamento, display principale, VRR e HDR. Un'impostazione non viene mostrata come supportata solo perché il modello di monitor esiste in un elenco generico; il compositore attivo e il backend del monitor devono segnalarla.

Applicare un layout del display modifica la configurazione del monitor di Hyprland in esecuzione e salva lo stato del layout supportato per sessioni successive. Usa il flusso di applicazione/revert quando disponibile. Se un monitor diventa inutilizzabile, torna alla pagina dei display o usa `argvus displayctl --apply` con lo stato salvato invece di modificare i file generati.

## Gestione del display da riga di comando

Usa `argvus displayctl` per interrogare e modificare le impostazioni del display senza l'interfaccia grafica:

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
I nomi dei monitor vengono mostrati da `--status` (tipicamente `HDMI-1`, `DP-2`, `eDP-1` per i laptop, ecc.). Dopo aver utilizzato `--settings` per apportare modifiche tramite l'interfaccia grafica, la sessione si ricarica automaticamente per applicarle.
