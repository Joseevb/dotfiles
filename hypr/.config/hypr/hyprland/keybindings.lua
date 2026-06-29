return function(programs)
  local mainMod = "SUPER"

  hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
  hl.bind(mainMod .. " + b", hl.dsp.exec_cmd(programs.browser))
  hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + SHIFT + ALT + M", hl.dsp.exit())
  hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.file_manager))
  hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
  hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(programs.menu))
  hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
  hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("caelestia shell drawers toggle session"), { release = true })
  hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

  -- Clipboard manager
  hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/clipboard/history"))

  -- Lock screen and shell drawers
  hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
  hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("caelestia shell drawers toggle dashboard"))
  hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("caelestia shell drawers toggle sidebar"))
  hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("emote"))
  hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -swb"))

  -- Move focus
  hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
  hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
  hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
  hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))
  hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
  hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
  hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
  hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

  -- Move windows
  hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
  hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
  hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
  hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

  -- Resize submap
  hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
  hl.define_submap("resize", function()
    hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
    hl.bind("Return", hl.dsp.submap("reset"))
  end)

  -- Workspaces
  for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  end

  hl.bind(mainMod .. " + SHIFT + a", hl.dsp.workspace.move({ monitor = "l" }))
  hl.bind(mainMod .. " + SHIFT + f", hl.dsp.workspace.move({ monitor = "r" }))

  -- Screenshots
  -- hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
  -- hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
  -- hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --freeze --raw | satty --filename - --output-filename ~/Pictures/Screenshots/Screenshot_$(date +%Y%m%d%H%M%S).png --init-tool brush --copy-command wl-copy"))
  hl.bind("Print", hl.dsp.exec_cmd("quickshell -c HyprQuickFrame -n"))
  hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("HYPRQUICKFRAME_EDITOR=1 quickshell -c HyprQuickFrame -n"))

  -- Change keyboard layout (Native Wayland switch)
  -- hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

  -- Scroll through workspaces
  hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

  -- Move/resize windows
  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  -- Volume/Media
  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
  hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, repeating = true })
  hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, repeating = true })
  hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, repeating = true })
  hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true, repeating = true })
end
