---
title: Displays
description: Cấu hình các màn hình và bố cục.
---

`argvus-display` cung cấp `argvus displayctl` và tích hợp các bố cục đã lưu với Hyprland. Kiểm tra trạng thái bằng:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

. Trợ lý cũng hỗ trợ /docs/reference/configuration-files/ và  `--set <monitor> <key> <value>` `--apply-nwg`. Các ghi đè màn hình được tạo ra là một phần của trạng thái cấu hình ARGVUS; xem [các tệp cấu hình](/docs/reference/configuration-files/).

Trong Trung tâm Kiểm soát, mở **Màn hình** hoặc tìm kiếm một màn hình. Các cài đặt có sẵn phụ thuộc vào khả năng và có thể bao gồm độ phân giải, tần số làm mới, tỷ lệ, vị trí, hướng, màn hình chính, VRR và HDR. Một cài đặt không được hiển thị là được hỗ trợ chỉ vì mô hình màn hình xuất hiện trong danh sách chung; bộ tổng hợp hoạt động và phần mềm điều khiển màn hình phải báo cáo nó.

Áp dụng một bố cục hiển thị sẽ thay đổi cấu hình màn hình Hyprland đang chạy và lưu trạng thái bố cục được hỗ trợ cho các phiên sau. Sử dụng quy trình áp dụng/khôi phục của trang khi có sẵn. Nếu một màn hình trở nên không sử dụng được, hãy quay lại trang hiển thị hoặc sử dụng `argvus displayctl --apply` với trạng thái đã lưu thay vì chỉnh sửa các tệp được tạo.

## Quản lý hiển thị bằng dòng lệnh

Sử dụng `argvus displayctl` để truy vấn và thay đổi cài đặt hiển thị mà không cần giao diện đồ họa:

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

Tên màn hình được hiển thị bởi  eDP-1  DP-2  HDMI-1  `--status`  `HDMI-1`  `DP-2`  `eDP-1` `--settings` (thường là --settings, --settings, --settings cho máy tính xách tay, v.v.). Sau khi sử dụng --settings để thực hiện thay đổi với GUI, phiên làm việc sẽ tự động tải lại để áp dụng chúng.
