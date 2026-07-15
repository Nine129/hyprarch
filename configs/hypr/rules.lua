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
  match  = { class = "vivaldi-stable", title = "Picture-in-Picture" },
  float  = true,
  size   = { 400, 300 },
})


-- Ensure borders show on single-window workspaces
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 3 })

-- Enable blur on wlogout layer surface for acrylic glass effect
hl.layer_rule({
  match = { title = "logout_dialog" },
  blur  = true,
})
-- Obsidian higher opacity
hl.window_rule({ 
    match = { class = "obsidian" }, 
    opacity = "0.9 override 0.8 override",
})

 -- blah blah
 hl.window_rule(
   {
     match = { class = "vesktop"},
     border_color = "rgba(c8ff00ee)",
     opaque = true,
     no_shadow= true  
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
     opaque = true
   }
 )


 hl.window_rule(
   {
    match={ class = "kitty-float"},
    float= true,
    center=true,
    size={770,450},

   }
 )

 hl.window_rule(
   {
    match={ class = "otter-launcher"},
    float= true,
    center=true,
    size={500,370},
    border_color = "rgba(ff6b00ff)",
    opaque = true,
  }
 )
 hl.window_rule(
   {
     match = { class = "imv"},
     opaque = true,
   }
 )
 hl.window_rule(
   {
     match = { class = "mpv"},
     opaque = true,
     size = {1280,720}
   }
 )
 hl.window_rule(
   {
     match = { title = "ghgrab"},
     border_color = "rgba(c8ff00ee)",
   }
 )
hl.layer_rule({
  match = { title = "fuzzel" },
  no_anim = true,
})   
 hl.window_rule(
   {
    match={ class = "filepicker"},
    float= true,
    center=true,
    size={800,650},
    opaque = true,
   }
 )
 hl.window_rule(
   {
     match = { title = "ilgwg_desktop_gremlins.py"},
     border_color = "rgba(00000000) rgba(00000000)",
     opacity = "1.0 override",
    border_size = 0,
    no_shadow = true,  
  }
 )

hl.layer_rule({
  match = { title = "waybar" },
  blur  = false,
})
 hl.window_rule(
   {
     match = { class = "yazi"},
     opaque = false,

   }
 )
