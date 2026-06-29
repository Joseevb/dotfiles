-- Migrated from monitors.conf. Keep monitors.conf as the nwg-displays legacy source.

-- Legacy examples kept from hyprland.old.conf:
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "auto", scale = 1, mirror = "HDMI-A-2" })
-- hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "1920x0", scale = 1, transform = 1 })

hl.monitor({
  output = "desc:LG Electronics LG FHD 406TFEN15900",
  mode = "1920x1080@100.0",
  position = "1080x427",
  scale = 1.0,
})

hl.monitor({
  output = "desc:Hewlett Packard HP Z23i 3CQ3500RJZ",
  mode = "1920x1080@60.0",
  position = "0x0",
  scale = 1.0,
  transform = 3,
})

-- hl.exec_cmd("wl-mirror -o HDMI-A-1 HDMI-A-2")
