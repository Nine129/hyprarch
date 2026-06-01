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
hl.window_rule({ match = { class = "firefox" },   workspace = 1 })
hl.window_rule({ match = { class = "zen" },       workspace = 1 })
hl.window_rule({ match = { class = "chromium" },  workspace = 1 })

-- Smart gaps (no gaps when single) ─
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding   = 0 })