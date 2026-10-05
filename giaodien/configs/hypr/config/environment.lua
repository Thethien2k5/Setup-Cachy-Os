-- Environmental variables (for reference https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/)
-- if you use UWSM, define your variables in ~/.config/uwsm/env
-- if you don't use UWSM, define your variables here (e.g. hl.env("QT_QPA_PLATFORM", "wayland"))

-- if you have an NVIDIA GPU uncomment the following lines:

-- NVIDIA GPU settings
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GL_GSYNC_ALLOWED", "1")
-- AQ_DRM_DEVICES: Aquamarine tự động nhận diện cả card rời NVIDIA (card1) và Intel (card2).
-- Tuyệt đối không dùng đường dẫn /dev/dri/by-path/ chứa dấu hai chấm ':' vì Aquamarine dùng ':' làm delimiter phân tách các card.
-- Nếu cần chỉ định thủ công: hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2")
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2")
