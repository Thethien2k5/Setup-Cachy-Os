#!/usr/bin/env bash
# ==============================================================================
# 𝕔𝕒𝕖𝕝𝕖𝕤𝕥𝕚𝕒-𝕤𝕙𝕖𝕝𝕝 & Hyprland - Script cài đặt & áp dụng giao diện 1-Click
# Tự động hóa toàn bộ cấu hình UI, Wallpaper 4K, Phím tắt & Widget
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"
WALLPAPERS_DIR="$SCRIPT_DIR/wallpapers"

echo "================================================================"
echo ">>> Bắt đầu áp dụng giao diện Caelestia Shell & Hyprland..."
echo "================================================================"

# 1. Cài đặt các gói phụ thuộc giao diện
echo ">>> [1/6] Kiểm tra và cài đặt các thành phần UI cần thiết..."
DEPENDENCIES=(
    hyprland
    quickshell
    caelestia-shell
    caelestia-cli
    kitty
    fuzzel
    cava
    mpvpaper
    mpv
    ffmpeg
    satty
    kooha
    slurp
    grim
    wl-clipboard
    fcitx5
    fcitx5-bamboo
    fcitx5-gtk
    fcitx5-qt
    fcitx5-configtool
    python-dbus
    python-gobject
    python-materialyoucolor
    papirus-icon-theme
)

sudo pacman -S --needed --noconfirm "${DEPENDENCIES[@]}" 2>/dev/null || true

# 2. Tạo các thư mục cấu hình đích
echo ">>> [2/6] Khởi tạo các thư mục cấu hình hệ thống..."
mkdir -p ~/.config/caelestia
mkdir -p ~/.config/quickshell
mkdir -p ~/.config/hypr
mkdir -p ~/.config/kitty
mkdir -p ~/.config/fuzzel
mkdir -p ~/.config/cava
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0
mkdir -p ~/.config/clipse
mkdir -p ~/.config/systemd/user
mkdir -p ~/.config/uwsm
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p "$HOME/Ảnh động/Wallpapers"

# 3. Sao chép các tệp cấu hình giao diện
echo ">>> [3/6] Đồng bộ các tệp cấu hình UI..."
cp -rf "$CONFIGS_DIR/caelestia/"* ~/.config/caelestia/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/quickshell/"* ~/.config/quickshell/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/hypr/"* ~/.config/hypr/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/kitty/"* ~/.config/kitty/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/fuzzel/"* ~/.config/fuzzel/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/cava/"* ~/.config/cava/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/gtk-3.0/"* ~/.config/gtk-3.0/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/gtk-4.0/"* ~/.config/gtk-4.0/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/clipse/"* ~/.config/clipse/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/bin/"* ~/.local/bin/ 2>/dev/null || true
chmod +x ~/.local/bin/*

cp -rf "$CONFIGS_DIR/systemd/"* ~/.config/systemd/user/ 2>/dev/null || true
cp -rf "$CONFIGS_DIR/desktop/"* ~/.local/share/applications/ 2>/dev/null || true
update-desktop-database ~/.local/share/applications 2>/dev/null || true

# 4. Sao chép hình nền động & Avatar
echo ">>> [4/6] Cài đặt hình nền động & Avatar người dùng..."
if [ -d "$WALLPAPERS_DIR" ]; then
    cp -rf "$WALLPAPERS_DIR/"*.mp4 "$HOME/Ảnh động/Wallpapers/" 2>/dev/null || true
    if [ -f "$WALLPAPERS_DIR/.face" ]; then
        cp -f "$WALLPAPERS_DIR/.face" "$HOME/.face"
    fi
fi

# Biến môi trường bộ gõ Fcitx5
touch ~/.config/uwsm/env
if ! grep -q "XMODIFIERS=@im=fcitx" ~/.config/uwsm/env; then
    echo "export XMODIFIERS=@im=fcitx" >> ~/.config/uwsm/env
fi
if ! grep -q "QT_IM_MODULE=fcitx" ~/.config/uwsm/env; then
    echo "export QT_IM_MODULE=fcitx" >> ~/.config/uwsm/env
fi

# 5. Kích hoạt dịch vụ ngầm (Systemd Services)
echo ">>> [5/6] Kích hoạt các dịch vụ nền (Auto-EN, Clipboard-Daemon)..."
systemctl --user daemon-reload
systemctl --user enable --now auto-en.service 2>/dev/null || true
systemctl --user enable --now clipboard-daemon.service 2>/dev/null || true

# 6. Khởi động hình nền và nạp lại giao diện
echo ">>> [6/6] Khởi chạy hình nền và nạp lại Hyprland..."
if command -v livewall-ctl >/dev/null 2>&1; then
    ~/.local/bin/livewall-ctl init 2>/dev/null || true
fi

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload 2>/dev/null || true
fi

echo "================================================================"
echo ">>> HOÀN TẤT CÀI ĐẶT GIAO DIỆN CAELESTIA SHELL & HYPRLAND!"
echo ">>> Giao diện, thanh điều khiển, hình nền động và phím tắt đã sẵn sàng."
echo "================================================================"
