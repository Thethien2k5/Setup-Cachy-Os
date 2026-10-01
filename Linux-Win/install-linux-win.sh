#!/usr/bin/env bash
# ==============================================================================
# Script cài đặt tính năng Khởi động nhanh từ Linux sang Windows
# (Dành cho máy Dual Boot cài đặt thêm khi cần)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>> Cài đặt tính năng Khởi động nhanh vào Windows..."

mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons

# 1. Cài đặt script thực thi
cp -f "$SCRIPT_DIR/bin/boot-to-windows" ~/.local/bin/
chmod +x ~/.local/bin/boot-to-windows

# 2. Cài đặt icon Windows
cp -f "$SCRIPT_DIR/icons/windows.svg" ~/.local/share/icons/

# 3. Cài đặt file shortcut ứng dụng
cp -f "$SCRIPT_DIR/desktop/boot-to-windows.desktop" ~/.local/share/applications/
chmod +x ~/.local/share/applications/boot-to-windows.desktop
update-desktop-database ~/.local/share/applications 2>/dev/null || true

# 4. Hướng dẫn cấp quyền NOPASSWD để không bị hỏi mật khẩu
echo "=================================================================="
echo ">>> Đã cài đặt xong shortcut 'Khởi động vào Windows'!"
echo ">>> Để máy tự động khởi động lại vào Windows mà KHÔNG cần hỏi mật khẩu,"
echo ">>> vui lòng chạy lệnh sau (chỉ 1 lần duy nhất):"
echo "    echo \"\$USER ALL=(ALL) NOPASSWD: /usr/bin/efibootmgr -n 0002\" | sudo tee /etc/sudoers.d/boot-to-windows"
echo "=================================================================="
