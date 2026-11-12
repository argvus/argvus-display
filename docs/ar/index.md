---
title: يعرض
description:                                                      .ﺕﺎﻄﻴﻄﺨﺘﻟﺍﻭ ﺕﺎﺷﺎﺸﻟﺍ ﺔﺌﻴﻬﺗ
---

`argvus-display` provides `argvus displayctl`                   :ﻡﺍﺪﺨﺘﺳﺎﺑ ﺔﻟﺎﺤﻟﺍ ﺺﺤﻓﺍ .ﺪﻧﻻ﻿ﺮﺒﻳﺎﻫ ﻊﻣ ﺔﻇﻮﻔﺤﻤﻟﺍ ﺕﺎﻄﻴﻄﺨﺘﻟﺍ ﺞﻣﺪُﻳﻭ

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

 for the installed and user paths.                                            .ﻡﺪﺨﺘﺴﻤﻟﺍ ﺕﺍﺭﺎﺴﻣﻭ ﺔﺘﺒﺜﻤﻟﺍ ﺕﺍﺭﺎﺴﻤﻠﻟ(/docs/reference/configuration-files/).



.ﺓﺄﺸﻨُﻤﻟﺍ ﺕﺎﻔﻠﻤﻟﺍ

## ﺮﻣﺍﻭﻷ﻿ﺍ ﺮﻄﺳ ﺮﺒﻋ ﺽﺮﻌﻟﺍ ﺓﺭﺍﺩﺇ

    :ﺕﺎﻴﻣﻮﺳﺮﻟﺍ ﺔﻬﺟﺍﻭ ﻥﻭﺪﺑ ﺽﺮﻌﻟﺍ ﺕﺍﺩﺍﺪﻋﺇ ﺮﻴﻴﻐﺗﻭ ﻡﻼ﻿ﻌﺘﺳﻻ﻿   `--set <monitor> <key> <value>`  `--apply-nwg` `argvus displayctl --apply` `argvus displayctl` ﻡﺪﺨﺘﺳﺍ

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

                                                  ﺔﻄﺳﺍﻮﺑ ﺕﺎﺷﺎﺸﻟﺍ ءﺎﻤﺳﺃ ﺽﺮﻋ ﻢﺘﻳ`--status` (typically `HDMI-1`, `DP-2`, `eDP-1`                                     ﻡﺍﺪﺨﺘﺳﻻ﻿ﺍ ﺪﻌﺑ .(ﻚﻟﺫ ﻰﻟﺇ ﺎﻣﻭ ،ﺏﻮﺘﺑﻼ﻿ﻟﺍ ﺓﺰﻬﺟﻷ﻿`--settings`.ﺎﻬﻘﻴﺒﻄﺘﻟ ﺎًﻴﺋﺎﻘﻠﺗ ﺔﺴﻠﺠﻟﺍ ﻞﻴﻤﺤﺗ ﺓﺩﺎﻋﺇ ﻢﺘﻳ ،ﺔﻴﻣﻮﺳﺮﻟﺍ ﻡﺪﺨﺘﺴﻤﻟﺍ ﺔﻬﺟﺍﻭ ﻡﺍﺪﺨﺘﺳﺎﺑ ﺕﺍﺮ

يدعم المساعد أيضًا --set <monitor> <key> <value> و--apply-nwg. تعد تجاوزات الشاشة التي تم إنشاؤها جزءًا من حالة التكوين ARGVUS؛ راجع [ملفات التكوين](/docs/reference/configuration-files/).
