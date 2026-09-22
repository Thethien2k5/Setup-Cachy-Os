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
    fcitx5 \
    fcitx5-bamboo \
    fcitx5-gtk \
    fcitx5-qt \
    fcitx5-configtool \
    python-dbus \
    python-gobject

# 3. Cài đặt Cốc Cốc Browser từ AUR
echo ">>> [3/7] Cài đặt Cốc Cốc Browser từ AUR..."
AUR_HELPER=""
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
fi

if [ -n "$AUR_HELPER" ]; then
    $AUR_HELPER -S --needed --noconfirm coccoc-browser || true
else
    echo "Lưu ý: Chưa tìm thấy paru/yay để cài coccoc-browser."
fi

# 4. Sao chép và phân bổ các file cấu hình
echo ">>> [4/7] Đồng bộ các file cấu hình..."
mkdir -p ~/.config/hypr/config
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/.config/systemd/user

# Hyprland configs
cp -rf "$CONFIGS_DIR/hypr/"* ~/.config/hypr/config/

# Local scripts
cp -rf "$CONFIGS_DIR/bin/"* ~/.local/bin/
chmod +x ~/.local/bin/*

# Tạo symlink mission-center nếu cần
ln -sf /usr/bin/missioncenter ~/.local/bin/mission-center 2>/dev/null || true

# Desktop entries
cp -rf "$CONFIGS_DIR/desktop/"* ~/.local/share/applications/
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

# 6. Thiết lập và kích hoạt background service tự chuyển EN khi phụp màn hình
echo ">>> [6/7] Kích hoạt auto-en background service..."
cp -f "$CONFIGS_DIR/systemd/auto-en.service" ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now auto-en.service || true

# 7. Reload Hyprland
echo ">>> [7/7] Nạp lại cấu hình Hyprland..."
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
fi

echo "=================================================="
echo ">>> HOÀN TẤT THIẾT LẬP HỆ THỐNG THÀNH CÔNG!"
echo ">>> Mọi phần mềm, phím tắt và cấu hình đã sẵn sàng."
echo "=================================================="
