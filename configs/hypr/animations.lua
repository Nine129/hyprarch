-- ── CGGX Rice — Curves & Animations ────────────────
-- Sourced via require("animations")
--
-- Design philosophy:
--   • Workspaces slide with bouncy springs (high-visibility)
--   • Windows pop in at 80% scale with bouncy springs
--   • Fades use the smooth myBezier curve (subtle)
--   • Border uses myBezier for color transitions

-- Custom bezier (snappy ease-out) ──
--   p0=(0,0)  p1=(0.05,0.9)  p2=(0.1,1.05)  p3=(1,1)
--   Fast start, subtle overshoot → smooth settle
hl.curve("myBezier", {
  type   = "bezier",
  points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

-- Spring curve (bouncy) ───────────
hl.curve("bouncy", {
  type       = "spring",
  mass       = 1,
  stiffness  = 70,
  dampening  = 10,
})

-- Smooth bezier (fade layers) ─────
hl.curve("smooth", {
  type   = "bezier",
  points = { { 0.25, 0.1 }, { 0.25, 1.0 } },
})

-- Global ────────────────────────────
hl.animation({ leaf = "global",    enabled = true, speed = 8 })

-- Workspaces ──────────────────────────
--  Direction: slide (left/right)
--  Curve:     bouncy spring → overshoot + settle
hl.animation({ leaf = "workspaces",        enabled = true, speed = 8, curve = "bouncy", style = "slide" })
hl.animation({ leaf = "workspacesIn",      enabled = true, speed = 8, curve = "bouncy", style = "slide" })
hl.animation({ leaf = "workspacesOut",     enabled = true, speed = 8, curve = "bouncy", style = "slide" })
hl.animation({ leaf = "specialWorkspace",  enabled = true, speed = 8, curve = "bouncy", style = "slide" })

-- Windows ────────────────────────────
--  Style:    popin 80% (scale from 0.8 → 1.0)
--  Curve:    bouncy spring → snappy open
hl.animation({ leaf = "windows",     enabled = true, speed = 8,  curve = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 8,  curve = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 8,  curve = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 10, curve = "myBezier" })

-- Fade ───────────────────────────────
--  Curve:    myBezier (snappy ease-out)
hl.animation({ leaf = "fade",       enabled = true, speed = 5, curve = "myBezier" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 5, curve = "myBezier" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 5, curve = "myBezier" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 5, curve = "myBezier" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 5, curve = "myBezier" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 5, curve = "myBezier" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, curve = "myBezier" })

-- Border ────────────────────────────
--  Curve:    myBezier (smooth accent transitions)
hl.animation({ leaf = "border", enabled = true, speed = 8, curve = "myBezier" })