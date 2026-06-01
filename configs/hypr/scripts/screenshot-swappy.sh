#!/usr/bin/env bash
# ── CGGX Screenshot → Swappy ──────────────────────────
# Captures a region and opens it in Swappy for markup/annotations.
# Bound to SUPER+Print in binds.lua
grimblast copy area && wl-paste | swappy -f -
