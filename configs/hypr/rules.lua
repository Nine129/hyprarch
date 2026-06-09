-- ── CGGX Rice — Window & Workspace Rules ─
-- Sourced via require("rules")

-- Float-only windows ──────────────
hl.window_rule({ match = { class = "pavucontrol" },        float = true, center = true })
hl.window_rule({ match = { class = "blueman-manager" },     float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "hyprpicker" },          float = true })
hl.window_rule({ match = { class = "imv" },                  float = true })
hl.window_rule({ match = { class = "mpv" },                  float = true })
hl.window_rule({ match = { class = "xdg-desktop-portal" },   float = true })

-- Browser PiP
hl.window_rule({
  match  = { class = "firefox", title = "Picture-in-Picture" },
  float  = true,
  size   = { 400, 300 },
})

-- Fixed workspace assignments ─────
hl.window_rule({ match = { class = "vivaldi" },       workspace = 1 })
hl.window_rule({ match = { class = "Vivaldi-stable" }, workspace = 1 })

-- Force Vivaldi fully opaque — hl.window_rule's `opaque` doesn't work in the Lua API,
-- so we use an event listener to fire setprop when Vivaldi opens.
hl.on("window.open", function(win)
  if win.class:match("[Vv]ivaldi") then
    hl.dispatch(hl.dsp.window.set_prop({ window = win, prop = "opaque", value = 1 }))
  end
end)
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = { top = 3, bottom = 12, left = 12, right = 12 }, gaps_in = 4 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = { top = 3, bottom = 12, left = 12, right = 12 }, gaps_in = 4 })
-- Ensure borders show on single-window workspaces
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 3 })

-- Enable blur on wlogout layer surface for acrylic glass effect
hl.layer_rule({
  match = { namespace = "logout_dialog" },
  blur  = true,
})
-- Obsidian higher opacity
hl.window_rule({ 
    match = { class = "obsidian" }, 
    opacity = "0.9 override 0.8 override",
    
})
 -- Zen opaque
 hl.window_rule(
   {
     match = { class = "zen" },
     opaque = true,
   }
 )
 -- blah blah
 hl.window_rule(
   {
     match = { class = "vesktop"},
     opaque = true,
     border_color = "rgba(c8ff00ee)",
   }
 )
 hl.window_rule(
   {
     match = { class = "kitty"},
   }
 )
 hl.window_rule(
   {
     match = { class = "vivaldi-stable" },
     
   }
 )
