# 𝕔𝕒𝕖𝕝𝕖𝕤𝕥𝕚𝕒-𝕤𝕙𝕖𝕝𝕝 & Hyprland UI Setup (CachyOS / Arch Linux)

Bộ giao diện hoàn chỉnh được tối ưu và tùy biến sẵn, bao gồm thanh điều khiển thông minh Caelestia Shell (Quickshell), Material You dynamic theme, hình nền động Anime 4K, bộ phím tắt tiện ích và cửa sổ nổi.

---

## ⚡ Cài đặt nhanh trong 1 dòng lệnh

Sau khi tải repo về máy, chỉ cần chạy:

```bash
bash install.sh
```

Hoặc chạy trực tiếp từ thư mục gốc của dự án:

```bash
bash "/home/nttdz/Dự án/SetupCachyOSCoban/giaodien/install.sh"
```

---

## 📦 Bộ giao diện bao gồm những gì?

1. **Caelestia Shell & Quickshell (`configs/caelestia`, `configs/quickshell`)**:
   - Thanh taskbar cạnh trái ẩn hiện linh hoạt khi bấm nhả phím `Win`.
   - Dashboard & Performance Bar cạnh trên: click trực tiếp vào từng thẻ CPU, GPU, RAM, Disk, Network để mở Mission Center.
   - Dynamic Material You theming tự đổi màu toàn bộ hệ thống theo hình nền video/ảnh.

2. **Hình nền động Anime 4K & Bộ đổi màu (`configs/bin/livewall-ctl`, `wallpapers/`)**:
   - Hỗ trợ phát video MP4 4K mượt mà qua `mpvpaper`.
   - Phím tắt chuyển video nhanh: `Win + Alt + W`.
   - Phím tắt đổi phong cách bảng màu: `Win + Alt + C` (Dynamic, Catppuccin, Tokyo Night, Dracula, Nord,...).
   - Phím tắt bật / tắt video: `Win + Alt + B`.

3. **Chụp & Quay màn hình chuyên nghiệp (`satty`, `kooha`)**:
   - `Win + Shift + S` hoặc `Print`: Chụp vùng chọn và mở bảng vẽ chú thích Satty.
   - `Win + Alt + R` hoặc `Ctrl + Alt + R`: Mở trình quay màn hình Kooha.

4. **Lịch sử Clipboard trực quan (`clipse`)**:
   - `Win + V`: Mở cửa sổ Clipboard hỗ trợ xem trước hình ảnh Thumbnail và văn bản.

5. **Bộ gõ Fcitx5 Bamboo & Tự động chuyển EN**:
   - Tự động chuyển về tiếng Anh khi gập màn hình laptop, khóa máy hoặc sleep (`auto-en-daemon.py`).

6. **Tối ưu Game & Màn hình tần số quét cao**:
   - Tự động điều hướng các game (Steam, Genshin, Minecraft, Emulators,...) về **Workspace 5** trên màn hình 144Hz.
