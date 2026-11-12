---
title: Menampilkan
description: Konfigurasi monitor dan tata letak.
---

`argvus-display` menyediakan `argvus displayctl` dan mengintegrasikan tata letak yang disimpan dengan Hyprland. Periksa status dengan:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

. Bantuan ini juga mendukung /docs/reference/configuration-files/ dan  `--set <monitor> <key> <value>` `--apply-nwg`. Override monitor yang dihasilkan adalah bagian dari status konfigurasi ARGVUS; lihat [file konfigurasi](/docs/reference/configuration-files/).

Di Pusat Kontrol, buka **Layar** atau cari monitor. Pengaturan yang tersedia bergantung pada kemampuan dan dapat mencakup resolusi, kecepatan refresh, skala, posisi, orientasi, layar utama, VRR, dan HDR. Suatu pengaturan tidak ditampilkan sebagai didukung hanya karena model monitor ada dalam daftar umum; compositor aktif dan backend monitor harus melaporkannya.

Menerapkan tata letak tampilan mengubah konfigurasi monitor Hyprland yang sedang berjalan dan menyimpan status tata letak yang didukung untuk sesi berikutnya. Gunakan alur terapkan/batalkan pada halaman ini jika tersedia. Jika sebuah monitor menjadi tidak dapat digunakan, kembali ke halaman tampilan atau gunakan `argvus displayctl --apply` dengan status yang disimpan daripada mengedit file yang dihasilkan.

## Manajemen tampilan lewat baris perintah

Gunakan `argvus displayctl` untuk menanyakan dan mengubah pengaturan tampilan tanpa antarmuka grafis:

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

Nama monitor ditampilkan oleh  eDP-1  DP-2  HDMI-1  `--status`  `HDMI-1`  `DP-2`  `eDP-1` `--settings` (biasanya --settings, --settings, --settings untuk laptop, dll.). Setelah menggunakan --settings untuk melakukan perubahan dengan GUI, sesi secara otomatis memuat ulang untuk menerapkannya.
