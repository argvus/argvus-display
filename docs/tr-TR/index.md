---
title: Ekranlar
description: Monitörleri ve düzenleri yapılandırın.
---

`argvus-display` sunar ve kaydedilmiş düzenleri Hyprland ile entegre eder. Durumu inceleyin:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

. Yardımcı ayrıca /docs/reference/configuration-files/ ve  --set <monitor> <key> <value>  `argvus displayctl`  `--set <monitor> <key> <value>` `--apply-nwg`'yi destekler. Oluşturulan monitör geçersiz kılmaları ARGVUS yapılandırma durumunun bir parçasıdır; bkz. [yapılandırma dosyaları](/docs/reference/configuration-files/).

Denetim Merkezi'nde **Ekranlar**ı açın veya bir monitör arayın. Mevcut ayarlar, donanım özelliklerine bağlıdır ve çözünürlük, yenileme hızı, ölçek, konum, yönelim, birincil ekran, VRR ve HDR'i içerebilir. Bir ayar, yalnızca monitör modeli genel bir listede bulunduğu için destekleniyormuş gibi gösterilmez; aktif bileşimleyici ve monitör altyapısı bunu rapor etmelidir.

Bir ekran düzeni uygulamak, çalışan Hyprland monitör yapılandırmasını değiştirir ve desteklenen düzen durumunu daha sonraki oturumlar için kaydeder. Mevcut olduğunda sayfanın uygula/geri al akışını kullanın. Bir monitör kullanılamaz hale gelirse, oluşturulan dosyaları düzenlemek yerine ekran sayfasına geri dönün veya kaydedilmiş durumu `argvus displayctl --apply` ile kullanın.

## Komut satırı ekran yönetimi

`argvus displayctl` adlı kodu grafik arayüz olmadan görüntü ayarlarını sorgulamak ve değiştirmek için kullanın:

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

Monitör isimleri  eDP-1  DP-2  HDMI-1  `--status`  `HDMI-1`  `DP-2`  `eDP-1` `--settings` tarafından gösterilir (genellikle dizüstü bilgisayarlar için --settings, --settings, --settings vb.). GUI ile değişiklik yapmak için --settings kullanıldıktan sonra, değişikliklerin uygulanması için oturum otomatik olarak yeniden yüklenir.
