-- Caelestia Hyprland User Configuration
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-2", mode = "1920x1080@144", position = "1920x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GL_GSYNC_ALLOWED", "1")

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service || /usr/lib/hyprpolkitagent")
    hl.exec_cmd("pgrep -f xdg-desktop-portal-hyprland || /usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("pgrep -f 'clipse.*listen' || clipse -listen")
    hl.exec_cmd("livewall-ctl init")
end)

-- Chuyển đổi bộ gõ Fcitx5 (Tiếng Việt / Tiếng Anh) bằng phím Win + Space
hl.bind("SUPER + Space", hl.dsp.exec_cmd("fcitx5-remote -t"))

-- 📋 Trình quản lý Clipboard Clipse (Win + V)
hl.window_rule({
    match = { class = "com.cachyos.clipboardviewer" },
    float = true,
    size = "480 650",
    center = true,
})
hl.bind("SUPER + V", hl.dsp.exec_cmd("bash -c 'pgrep -f \"clipse.*listen\" || clipse -listen; kitty --class com.cachyos.clipboardviewer -e clipse'"))

-- ✂️ Trình chụp & chú thích ảnh Satty (Print / Win + Shift + S)
hl.bind("Print", hl.dsp.exec_cmd("/home/nttdz/.local/bin/satty-shot.sh"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("/home/nttdz/.local/bin/satty-shot.sh"))

-- 📹 Trình quay màn hình Kooha (Win + Alt + R / Ctrl + Alt + R)
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("kooha"))
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("kooha"))

-- Phím tắt bật/tắt thanh taskbar dọc bên trái bằng phím Win (Super_L) khi nhả phím
hl.bind("SUPER + Super_L", hl.dsp.exec_cmd("caelestia shell drawers toggle bar"), { release = true })

-- === ĐIỀU KHIỂN HÌNH NỀN ĐỘNG & ĐỔI STYLE NHANH (Mở rộng linh hoạt, không phá vỡ layout) ===
-- Win + Alt + W : Chuyển video anime 4K tiếp theo trong ~/Ảnh động/Wallpapers
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("livewall-ctl next"))

-- Win + Alt + C : Đổi nhanh phong cách màu (Dynamic / Catppuccin / Tokyo Night / Dracula / Nord...)
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("livewall-ctl style-next"))

-- Win + Alt + B : Bật / Tạm dừng hình nền động (chuyển đổi linh hoạt giữa video và ảnh tĩnh)
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("livewall-ctl toggle"))

-- === TỰ ĐỘNG ĐƯA GAME (Genshin, Steam, Minecraft, v.v.) VÀO WORKSPACE 5 (Màn 144Hz) ===
hl.workspace_rule({ workspace = "5", monitor = "eDP-2" })

local gameClasses = "^(steam_app_.*|gamescope|[Mm]inecraft.*|net\\.minecraft\\.client.*|org\\.lwjgl.*|osu!|ryujinx|yuzu|rpcs3)$"

hl.window_rule({
    match = { class = gameClasses },
    workspace = "5",
})

hl.window_rule({
    match = { title = "^([Mm]inecraft.*)$" },
    workspace = "5",
})


