-- ── CGGX Rice — Settings ─────────────────
-- Sourced via require("settings")
hl.env("GTK_USE_PORTAL", "1")
-- Make brew binaries (yazi, ya, ...) resolvable for Hyprland-spawned processes.
-- hl.env re-applies on every reload, so guard against double-prepending.
-- The io.open check keeps a pacman-only yazi setup free of a dead PATH entry.
local cggx_path = os.getenv("PATH") or ""
if not cggx_path:find("/home/linuxbrew/.linuxbrew/bin", 1, true)
    and io.open("/home/linuxbrew/.linuxbrew/bin/yazi", "r") then
  hl.env("PATH", "/home/linuxbrew/.linuxbrew/bin:" .. cggx_path)
end

hl.config({
  general = {
    gaps_in              = 3,
    gaps_out             = { top = 4, bottom = 10, left = 10, right = 10 },
    border_size          =3,
    col = {
           active_border = "rgba(ff2d55ff)",
	   inactive_border = { colors = { "rgba(00000040)", "rgba(00000000)" }, angle = 45 },
   },
     layout               = "dwindle", -- "scrolling" to enable globally (see scrolling={} below)
     resize_on_border     = true,
    
  },

  decoration = {
    rounding            = 0,
    rounding_power      = 2.0,
    active_opacity      = 1.0,
    inactive_opacity    = 1.0,
    fullscreen_opacity  = 1.0,
    dim_inactive        = false,
    dim_strength        = 0.15,
    
    blur = {
      enabled            = false,
      size               = 0,
      passes             = 0,
      vibrancy           = 0.25,
      new_optimizations   = true,
      xray               = false,
      contrast           = 1.2,
      brightness         = 1.0,
    },

    shadow = {
      enabled            = true,
      range              = 14,
      render_power       = 2,
      color              = "rgba(00000066)",
      scale              = 1.0,
    },
  },

  dwindle = {
    force_split                  = 0,
    preserve_split               = true,
    smart_split                  = false,
    smart_resizing               = true,
    default_split_ratio          = 1.0,
    use_active_for_splits        = true,
  },

  -- ── Scrolling layout (Hyprland 0.54+) ──────────────
  -- Enable globally: set general.layout = "scrolling"
  -- Or per-workspace: hl.workspace_rule({ workspace = "2", layout_opts = { direction = "right" } }) in rules.lua
  -- Wiki: https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
  scrolling = {
    fullscreen_on_one_column = true,              -- single window fills screen (true = no dead tape)
    column_width             = 0.60,                -- default column width (0.1-1.0) — 0.6 = 60% of monitor, good for 1920x1080
    explicit_column_widths   = "0.333, 0.5, 0.667, 1.0", -- cycle via hl.dsp.layout("colresize +conf/-conf")
    focus_fit_method         = 1,                  -- 0=center, 1=fit visible
    follow_focus             = true,               -- auto-scroll to focused column
    follow_min_visible       = 0.4,                -- need 40% visible before auto-follow
    wrap_focus               = true,               -- focus l/r wraps at tape ends
    wrap_swapcol             = true,               -- swapcol l/r wraps
    direction                = "right",            -- new windows appear to the "right" (also: left/up/down)
  },

  misc = {
    vrr                  = 1,
    disable_hyprland_logo = true,
    animate_manual_resizes = false,  
  },
})


