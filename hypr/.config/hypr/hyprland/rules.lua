-- Window and workspace rules migrated from hyprland.old.conf.

hl.window_rule {
  name = 'base',
  match = { class = '.*' },
  maximize = true,
}

hl.window_rule {
  name = 'pip',
  match = { title = '^(Picture-in-Picture)$' },
  float = true,
  pin = true,
  move = '69.5% 4%',
}

hl.window_rule {
  name = 'float-large',
  match = { class = '^(center-float-large|.*qimgv.*|.*mpv.*)$' },
  float = true,
  size = '70% 70%',
  center = true,
}

hl.window_rule {
  name = 'float-small',
  match = {
    title = [[^(Open Folder|Open File|Save File|Save Folder|Save Image|Save As|Open As|Extension: \(Bitwarden Password Manager\))$]],
  },
  float = true,
  size = '50% 50%',
  center = true,
}

hl.window_rule {
  name = 'float-mini',
  match = { class = '^(center-float-mini|galculator|ytdlp-gui|udiskie|Calculator)$' },
  float = true,
  size = '30% 40%',
  center = true,
}

hl.window_rule {
  match = { class = '^(xfce-polkit|wleave|nwg-look|nm-connection-editor|org.twosheds.iwgtk|overskride|satty)$' },
  float = true,
}
hl.window_rule { match = { class = '^zen$', title = [[^Extension: \(Bitwarden Password Manager\).*]] }, float = true }

-- Workspace assignment
hl.window_rule { match = { class = '^(virt-manager|PikaBackup|VirtualBox Manager|Vmware.*)$' }, workspace = '8' }
hl.window_rule { match = { class = '^(GParted|clamtk|gnome.Logs)$' }, workspace = '17' }
hl.window_rule { match = { class = '^(obsidian|Zotero)$' }, workspace = '9 silent' }
hl.window_rule { match = { class = '^(.*Code.*|codium|VSCodium|neovide|Ghostty|ghostty)$' }, workspace = '1' }

-- Animation/visuals
hl.window_rule { match = { title = '^.*cava.*$' }, animation = 'slide' }
hl.window_rule { match = { class = '^.*wleave.*$' }, animation = 'popin' }
hl.window_rule { match = { class = '^rofi$' }, opacity = '0.65 0.65' }

-- Opacity overrides
hl.window_rule { match = { class = '^(zen|edge)$' }, opacity = '0.95 0.6' }
hl.window_rule {
  match = { title = '^(.*YouTube.*|Picture-in-Picture|.*Mozilla.*|.*localhost.*|.*Edge.*|.*Cursor.*|.*Grayjay.*)$' },
  opacity = '1.0 override 1.0 override',
}

hl.window_rule {
  name = 'satty-float',
  match = { title = 'satty' },
  float = true,
  size = '1200 800',
  center = true,
}

hl.window_rule {
  name = 'game',
  match = { class = [[^steam_app_\d+$]] },
  monitor = 'HDMI-A-2',
  fullscreen = true,
  workspace = '10',
  immediate = true,
}

hl.window_rule {
  name = 'steam-no-idle',
  match = { class = '^(steam|gamescope)$' },
  idle_inhibit = 'always',
}

hl.workspace_rule {
  workspace = '10',
  monitor = 'HDMI-A-2',
  no_border = true,
  no_rounding = true,
}
