---
title: Displays
description:                                               ۔ﮟﯾﺩ ﻞﯿﮑﺸﺗ ﻮﮐ ﭦﺅﺁ ﮯﻟ ﺭﻭﺍ ﺯﺮﭩﯿﻧﺎﻣ
---

`argvus-display` `argvus displayctl` ﺭﻭﺍ ﮯﮨ ﺎﺗﺮﮐ ﻢﮨﺍﺮﻓ Hyprland ﮟﯾﺮﮐ ﮧﻨﺋﺎﻌﻣ ﺎﮐ 

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

                                         ۔ﮯﯿﻟ ﮯﮐ ﮞﻮﺘﺳﺍﺭ ﮯﮐ ﻑﺭﺎﺻ ﺭﻭﺍ ﮦﺪﺷ ﻝﺎﭩﺴﻧﺍ for the installed and user paths.(/docs/reference/configuration-files/).



۔ﮟﯾﺮﮐ ﻝﺎﻤﻌﺘﺳﺍ ZXQMAS

## ﭧﻨﻤﺠﻨﯿﻣ ﮯﻠﭙﺳﮈ ﻦﺋﻻ﻿ ﮉﻧﺎﻤﮐ

:ﮟﯾﺮﮐ ﻝﺎﻤﻌﺘﺳﺍ   `--set <monitor> <key> <value>`  `--apply-nwg` `argvus displayctl --apply` `argvus displayctl` ﮯﯿﻟ ﮯﮐ ﮯﻧﺮﮐ ﻞﯾﺪﺒﺗ ﺭﻭﺍ ﮯﻨﮭﭼﻮﭘ ﻮﮐ ﺕﺎﺒﯿﺗﺮﺗ ﯽﮐ ﮯﻠﭙ

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

                                                  ﮟﯿﮨ ﮯﺌﮔ ﮯﺋﺎﮭﮐﺩ ﻡﺎﻧ ﮯﮐ ﺮﭩﯿﻧﺎﻣ`--status` (typically `HDMI-1`, `DP-2`, `eDP-1`                                   ﺪﻌﺑ ﮯﮐ ﮯﻧﺮﮐ ﻝﺎﻤﻌﺘﺳﺍ .(ﮯﯿﻟ ﮯﮐ ﮦﺮﯿﻏﻭ ﺲﭘﺎﭨ ﭗﯿﻟ`--settings`GUI ۔ﮯﮨ ﺎﺗﺎﺟ ﻮﮨ ﮈﻮﻟ ﮦﺭﺎﺑﻭﺩ ﮯﯿﻟ ﮯﮐ ﮯﻧﺮﮐ ﻮﮔﻻ﻿ ﻮﮐ ﻥﺍ ﺩﻮﺨﺑ ﺩﻮﺧ ﻦﺸﯿﺳ ،ﮯﯿﻟ ﮯﮐ ﮯﻧﺮﮐ ﮞﺎ

The helper also supports --set <monitor> <key> <value> and --apply-nwg. Generated monitor overrides are part of the ARGVUS configuration state; see [configuration files](/docs/reference/configuration-files/).
