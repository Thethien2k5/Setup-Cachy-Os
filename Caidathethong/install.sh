#!/usr/bin/env bash
# ==============================================================================
# Script tự động cài đặt & đồng bộ cấu hình CachyOS / Hyprland
# Được tạo cho Antigravity / Người dùng triển khai máy mới
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

echo "=================================================="
echo ">>> Bắt đầu thiết lập hệ thống CachyOS / Hyprland"
echo "=================================================="

# 1. Gỡ bỏ các ứng dụng không cần thiết
echo ">>> [1/7] Gỡ bỏ các ứng dụng cũ/không cần thiết..."
sudo pacman -Rns --noconfirm dolphin firefox vim kcalc qview 2>/dev/null || true

# 2. Cài đặt các gói chính thức qua pacman
echo ">>> [2/7] Cài đặt các phần mềm chuẩn từ repo chính thức..."
sudo pacman -S --needed --noconfirm \
    code \
    nemo \
    mission-center \
    loupe \
    git \
    wtype \
    satty \
    kooha \
    slurp \
    grim \
    wl-clipboard \
    mpv \
    mpvpaper \
    ffmpeg \
    pavucontrol \
    normcap \
    fcitx5 \
    fcitx5-bamboo \
    fcitx5-gtk \
    fcitx5-qt \
    fcitx5-configtool \
    python-dbus \
    python-gobject \
    python-materialyoucolor \
    papirus-icon-theme

# 3. Cài đặt Cốc Cốc Browser & OnlyOffice từ AUR
echo ">>> [3/7] Cài đặt Cốc Cốc Browser & OnlyOffice từ AUR..."
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
fi

if [ -n "$AUR_HELPER" ]; then
    $AUR_HELPER -S --needed --noconfirm coccoc-browser onlyoffice-bin || true
else
    echo "Lưu ý: Chưa tìm thấy paru/yay để cài coccoc-browser & onlyoffice-bin."
fi

# 4. Sao chép và phân bổ các file cấu hình
echo ">>> [4/7] Đồng bộ các file cấu hình..."
mkdir -p ~/.config/hypr/config
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/.config/systemd/user
mkdir -p "$HOME/Ảnh động/Wallpapers"

# Kitty configs
mkdir -p ~/.config/kitty
cp -rf "$CONFIGS_DIR/kitty/"* ~/.config/kitty/ 2>/dev/null || true

# Clipse configs (quản lý clipboard có preview ảnh)
mkdir -p ~/.config/clipse
cp -rf "$CONFIGS_DIR/clipse/"* ~/.config/clipse/ 2>/dev/null || true

# Caelestia user configs
mkdir -p ~/.config/caelestia
cp -rf "$CONFIGS_DIR/caelestia/"* ~/.config/caelestia/ 2>/dev/null || true

# Caelestia Quickshell dashboard configs
mkdir -p ~/.config/quickshell
cp -rf "$CONFIGS_DIR/quickshell/"* ~/.config/quickshell/ 2>/dev/null || true

# Hyprland configs
cp -rf "$CONFIGS_DIR/hypr/"* ~/.config/hypr/config/ 2>/dev/null || true

# Local scripts & binaries
cp -rf "$CONFIGS_DIR/bin/"* ~/.local/bin/ 2>/dev/null || true
chmod +x ~/.local/bin/*

# Tạo symlink mission-center nếu cần
ln -sf /usr/bin/missioncenter ~/.local/bin/mission-center 2>/dev/null || true

# Desktop entries
cp -rf "$CONFIGS_DIR/desktop/"* ~/.local/share/applications/ 2>/dev/null || true
update-desktop-database ~/.local/share/applications 2>/dev/null || true

# MIME apps associations
if [ -f "$CONFIGS_DIR/mimeapps.list" ]; then
    cp -f "$CONFIGS_DIR/mimeapps.list" ~/.config/mimeapps.list
fi

# 5. Cấu hình biến môi trường UWSM / Fcitx5
echo ">>> [5/7] Thiết lập biến môi trường bộ gõ..."
mkdir -p ~/.config/uwsm
touch ~/.config/uwsm/env
if ! grep -q "XMODIFIERS=@im=fcitx" ~/.config/uwsm/env; then
    echo "export XMODIFIERS=@im=fcitx" >> ~/.config/uwsm/env
fi
if ! grep -q "QT_IM_MODULE=fcitx" ~/.config/uwsm/env; then
    echo "export QT_IM_MODULE=fcitx" >> ~/.config/uwsm/env
fi

# 6. Thiết lập và kích hoạt background services
echo ">>> [6/7] Kích hoạt auto-en & clipboard-daemon services..."
cp -f "$CONFIGS_DIR/systemd/auto-en.service" ~/.config/systemd/user/ 2>/dev/null || true
cp -f "$CONFIGS_DIR/systemd/clipboard-daemon.service" ~/.config/systemd/user/ 2>/dev/null || true
systemctl --user daemon-reload
systemctl --user enable --now auto-en.service || true
systemctl --user enable --now clipboard-daemon.service || true

# 7. Reload Hyprland & Livewall
echo ">>> [7/7] Nạp lại cấu hình Hyprland..."
if command -v livewall-ctl >/dev/null 2>&1; then
    ~/.local/bin/livewall-ctl init 2>/dev/null || true
fi

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
fi

echo "=================================================="
echo ">>> HOÀN TẤT THIẾT LẬP HỆ THỐNG THÀNH CÔNG!"
echo ">>> Mọi phần mềm, phím tắt và cấu hình đã sẵn sàng."
echo "=================================================="
