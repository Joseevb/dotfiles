return function(colors)
  hl.config {
    debug = {
      disable_logs = false,
      enable_stdout_logs = true,
    },

    general = {
      gaps_in = 5,
      gaps_out = 10,
      border_size = 2,
      col = {
        active_border = colors.mauve,
        inactive_border = colors.overlay0,
      },
      resize_on_border = true,
      allow_tearing = true,
      layout = 'dwindle',
    },

    decoration = {
      rounding = 10,
      rounding_power = 2.0,
      active_opacity = 0.90,
      inactive_opacity = 0.6,

      shadow = {
        enabled = true,
        range = 9,
        render_power = 3,
        color = 'rgba(1a1a1aee)',
      },

      blur = {
        enabled = true,
        size = 10,
        passes = 3,
        vibrancy = 0.2,
        ignore_opacity = true,
        new_optimizations = true,
      },
    },

    animations = {
      enabled = true,
    },

    dwindle = {
      preserve_split = true,
    },

    master = {
      new_status = 'master',
    },

    misc = {
      force_default_wallpaper = 0,
      disable_hyprland_logo = true,
      disable_splash_rendering = true,
    },
  }

  hl.curve('easeOutQuint', { type = 'bezier', points = { { 0.23, 1 }, { 0.32, 1 } } })
  hl.curve('easeInOutCubic', { type = 'bezier', points = { { 0.65, 0.05 }, { 0.36, 1 } } })
  hl.curve('linear', { type = 'bezier', points = { { 0, 0 }, { 1, 1 } } })
  hl.curve('almostLinear', { type = 'bezier', points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
  hl.curve('quick', { type = 'bezier', points = { { 0.15, 0 }, { 0.1, 1 } } })

  hl.animation { leaf = 'global', enabled = true, speed = 10, bezier = 'default' }
  hl.animation { leaf = 'border', enabled = true, speed = 5.39, bezier = 'easeOutQuint' }
  hl.animation { leaf = 'windows', enabled = true, speed = 4.79, bezier = 'easeOutQuint' }
  hl.animation { leaf = 'windowsIn', enabled = true, speed = 4.1, bezier = 'easeOutQuint', style = 'popin 87%' }
  hl.animation { leaf = 'windowsOut', enabled = true, speed = 1.49, bezier = 'linear', style = 'popin 87%' }
  hl.animation { leaf = 'fadeIn', enabled = true, speed = 1.73, bezier = 'almostLinear' }
  hl.animation { leaf = 'fadeOut', enabled = true, speed = 1.46, bezier = 'almostLinear' }
  hl.animation { leaf = 'fade', enabled = true, speed = 3.03, bezier = 'quick' }
  hl.animation { leaf = 'layers', enabled = true, speed = 3.81, bezier = 'easeOutQuint' }
  hl.animation { leaf = 'layersIn', enabled = true, speed = 4, bezier = 'easeOutQuint', style = 'fade' }
  hl.animation { leaf = 'layersOut', enabled = true, speed = 1.5, bezier = 'linear', style = 'fade' }
  hl.animation { leaf = 'workspaces', enabled = true, speed = 6, bezier = 'default', style = 'slide' }
end
