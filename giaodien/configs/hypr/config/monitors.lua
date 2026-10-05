-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = MONITOR1,
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

-- External monitor (LG) on the LEFT
hl.monitor({
    output    = "HDMI-A-1",
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = "1",
})

-- Laptop screen on the RIGHT
hl.monitor({
    output    = "eDP-2",
    mode      = "1920x1080@144",
    position  = "1920x0",
    scale     = "1",
})

-- Fallback for any disconnected/other monitor
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "auto",
})
