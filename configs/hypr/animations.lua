-- ── CGGX Rice — Curves & Animations ────────────────
-- Sourced via require("animations")
-- Fix: Replaced invalid 'curve' parameter with explicit 'bezier' key required by the wrapper schema

-- Custom bezier (snappy ease-out) ──
hl.curve("myBezier", {
  type   = "bezier",
  points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

-- Spring curve (bouncy) ───────────
hl.curve("bouncy", {
  type   = "bezier",
  points = { { 0.13, 1.56 }, { 0.64, 1.0 } },
})

-- Smooth bezier (fade layers) ─────
hl.curve("smooth", {
  type   = "bezier",
  points = { { 0.25, 0.1 }, { 0.25, 1.0 } },
})

-- Global ────────────────────────────
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "myBezier" })

-- Workspaces ──────────────────────────
--  Direction: slide (left/right)
--  Curve:     bouncy spring → overshoot + settle
hl.animation({ leaf = "workspaces",       enabled = true, speed = 8, bezier = "bouncy", style = "slide" })
hl.animation({ leaf = "workspacesIn",     enabled = true, speed = 8, bezier = "bouncy", style = "slide" })
hl.animation({ leaf = "workspacesOut",    enabled = true, speed = 8, bezier = "bouncy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 8, bezier = "bouncy", style = "slide" })

-- Windows ────────────────────────────
--  Style:     popin 80% (scale from 0.8 → 1.0)
--  Curve:     bouncy spring → snappy open
hl.animation({ leaf = "windows",    enabled = true, speed = 8,  bezier = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 8,  bezier = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 8,  bezier = "bouncy", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 10, bezier = "myBezier" })

-- Fade ───────────────────────────────
--  Curve:     myBezier (snappy ease-out)
hl.animation({ leaf = "fade",        enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fadeShadow",  enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fadeLayers",  enabled = true, speed = 5, bezier = "myBezier" })

-- Border ────────────────────────────
--  Curve:     myBezier (smooth accent transitions)
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "myBezier" })
