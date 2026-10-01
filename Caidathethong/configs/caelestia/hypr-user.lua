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
    hl.exec_cmd("pgrep -f 'clipse.*listen' || clipse -listen")
end)

-- Chuyển đổi bộ gõ Fcitx5 (Tiếng Việt / Tiếng Anh) bằng phím Win + Space
hl.bind("SUPER + Space", hl.dsp.exec_cmd("fcitx5-remote -t"))

-- Phím tắt ẩn/hiện cửa sổ Scratchpad (Special workspace) bằng Alt + Shift
hl.bind("ALT + Shift_L",   hl.dsp.workspace.toggle_special())
hl.bind("ALT + Shift_R",   hl.dsp.workspace.toggle_special())
hl.bind("SHIFT + Alt_L",   hl.dsp.workspace.toggle_special())
hl.bind("SHIFT + Alt_R",   hl.dsp.workspace.toggle_special())

-- Trình quản lý Clipboard Clipse (có xem trước ảnh thumbnail, text, tìm kiếm)
hl.window_rule({
    match = { class = "clipse" },
    float = true,
    size = "760 560",
    center = true,
})
hl.bind("SUPER + V", hl.dsp.exec_cmd("toggle-clipse"))

