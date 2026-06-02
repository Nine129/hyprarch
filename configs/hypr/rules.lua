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

-- Force Vivaldi fully opaque — override global decoration opacity
hl.window_rule({ match = { class = "vivaldi" },       opaque = true })
hl.window_rule({ match = { class = "Vivaldi-stable" }, opaque = true })
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 12, gaps_in = 4 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 12, gaps_in = 4 })
-- Ensure borders show on single-window workspaces
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 3 })