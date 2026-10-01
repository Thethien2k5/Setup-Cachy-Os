# Khởi động nhanh từ Linux sang Windows (Linux -> Windows)

Module tùy chọn dành cho máy Dual Boot chạy song song CachyOS Linux và Windows.

## Chức năng
- Cho phép người dùng bấm `Alt + Space`, gõ `win` và nhấn `Enter` để máy tính tự động thiết lập BIOS/UEFI boot một lần vào Windows và khởi động lại ngay lập tức.
- Không cần phải ngồi canh phím F12/ESC hay can thiệp menu GRUB thủ công.

## Cấu trúc module
- `bin/boot-to-windows`: Script đặt `efibootmgr -n 0002` và gọi `systemctl reboot`.
- `desktop/boot-to-windows.desktop`: Shortcut ứng dụng hiển thị trong launcher tìm kiếm.
- `icons/windows.svg`: Logo Windows hiển thị cho ứng dụng.
- `install-linux-win.sh`: Script cài đặt 1-chạm cho module này.

## Cách cài đặt khi cần
Chạy lệnh:
```bash
bash "/home/nttdz/Dự án/SetupCachyOSCoban/Linux-Win/install-linux-win.sh"
```
Và chạy 1 lệnh cấp quyền không hỏi mật khẩu:
```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/efibootmgr -n 0002" | sudo tee /etc/sudoers.d/boot-to-windows
```
