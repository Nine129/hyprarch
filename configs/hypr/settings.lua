-- ── CGGX Rice — Settings ─────────────────
-- Sourced via require("settings")

hl.config({
  general = {
    gaps_in              = 4,
    gaps_out             = 12,
    border_size          = 2,
    col.active_border    = "rgba(ff2d55ff) rgba(ff6b00ff) 30deg",
    col.inactive_border  = "rgba(2a2a3580)",
    layout               = "dwindle",
    resize_on_border     = true,
  },

  decoration = {
    rounding            = 0,
    rounding_power      = 2.0,
    active_opacity      = 1.0,
    inactive_opacity    = 0.85,
    fullscreen_opacity  = 1.0,
    dim_inactive        = true,
    dim_strength        = 0.5,

    blur = {
      enabled            = true,
      size               = 8,
      passes             = 2,
      vibrancy           = 0.18,
      new_optimizations   = true,
      xray               = false,
      noise              = 0.0117,
      contrast           = 0.8916,
      brightness         = 0.8172,
    },

    shadow = {
      enabled            = true,
      range              = 12,
      render_power       = 3,
      color              = "rgba(ff2d5540)",
      scale              = 1.0,
    },
  },

  dwindle = {
    force_split                  = 0,
    preserve_split               = false,
    smart_split                  = false,
    smart_resizing               = true,
    default_split_ratio          = 1.0,
    use_active_for_splits        = true,
  },

  misc = {
    vfr                  = true,
    vrr                  = 1,
    disable_hyprland_logo = true,
  },
})