-- ── CGGX Rice — Settings ─────────────────
-- Sourced via require("settings")

hl.config({
  general = {
    gaps_in              = 4,
    gaps_out             = 12,
    border_size          = 2,
    col = {
           active_border = { colors = {"rgba(ff2d55ee)", "rgba(ff6b00ee)"}, angle = 30 },
	   inactive_border = "rgba(2a2a3580)",
   },
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
      size               = 6,
      passes             = 2,
      vibrancy           = 0.05,
      new_optimizations   = true,
      xray               = false,
      noise              = 0.005,
      contrast           = 0.7,
      brightness         = 0.8,
    },

    shadow = {
      enabled            = true,
      range              = 6,
      render_power       = 3,
      color              = "rgba(0a0a0caa)",
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
    vrr                  = 1,
    disable_hyprland_logo = true,
  },
})
