-- ── CGGX Rice — Curves & Animations ────────────────
-- Sourced via require("animations")

-- Custom bezier (snappy ease-out) ──
hl.curve("myBezier", {
  type   = "bezier",
  points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

-- Expressive fast spatial ─────────
hl.curve("expressiveFastSpatial", {
  type   = "bezier",
  points = { { 0.42, 1.67 }, { 0.21, 0.90 } },
})

-- Expressive slow spatial ─────────
hl.curve("expressiveSlowSpatial", {
  type   = "bezier",
  points = { { 0.39, 1.29 }, { 0.35, 0.98 } },
})

-- Expressive default spatial ──────
hl.curve("expressiveDefaultSpatial", {
  type   = "bezier",
  points = { { 0.38, 1.21 }, { 0.22, 1.00 } },
})

-- Emphasized decel ────────────────
hl.curve("emphasizedDecel", {
  type   = "bezier",
  points = { { 0.05, 0.7 }, { 0.1, 1 } },
})

-- Emphasized accel ────────────────
hl.curve("emphasizedAccel", {
  type   = "bezier",
  points = { { 0.3, 0 }, { 0.8, 0.15 } },
})

-- Standard decel ──────────────────
hl.curve("standardDecel", {
  type   = "bezier",
  points = { { 0, 0 }, { 0, 1 } },
})

-- Menu decel ──────────────────────
hl.curve("menu_decel", {
  type   = "bezier",
  points = { { 0.1, 1 }, { 0, 1 } },
})

-- Menu accel ──────────────────────
hl.curve("menu_accel", {
  type   = "bezier",
  points = { { 0.52, 0.03 }, { 0.72, 0.08 } },
})

-- Stall ───────────────────────────
hl.curve("stall", {
  type   = "bezier",
  points = { { 1, -0.1 }, { 0.7, 0.85 } },
})

-- Windows ────────────────────────────
--  Style:     popin 80% (scale from 0.8 → 1.0)
--  Curve:     emphasizedDecel — smooth ease-out
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3,  bezier = "emphasizedDecel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2,  bezier = "emphasizedDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3,  bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "emphasizedDecel" })

-- Fade ───────────────────────────────
--  Curve:     emphasizedDecel (smooth transitions)
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,   bezier = "emphasizedDecel" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "emphasizedDecel" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.5, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.7, bezier = "stall" })

-- Layers ──────────────────────────────
--  Style:     popin (scale from 93% → 100%)
hl.animation({ leaf = "layersIn",  enabled = true, speed = 2.7, bezier = "emphasizedDecel", style = "popin 93%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.4, bezier = "menu_accel",      style = "popin 94%" })

-- Workspaces ──────────────────────────
--  Direction: slide (left/right)
--  Curve:     myBezier — snappy ease-out, no overshoot
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "myBezier", style = "slide" })

-- Special workspace ────────────────────
--  Direction: slidevert (up/down)
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2.8, bezier = "emphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.2, bezier = "emphasizedAccel", style = "slidevert" })

-- Zoom ──────────────────────────────
--  Curve:     standardDecel
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3, bezier = "standardDecel" })
