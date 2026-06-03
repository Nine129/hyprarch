#!/usr/bin/env python3
"""
Cursor Retool — Recolor Bibata cursor shapes.

Workflow:
  1. Extract cursor images from the installed Xcursor theme
  2. Recolor them according to a color map
  3. Save PNGs for xcursorgen to rebuild as Xcursor files

Usage:
  python3 retool.py                  # uses default color map
  python3 retool.py --colors map.json # uses custom color map
  python3 retool.py --list           # show current colors only
"""

import ctypes
import ctypes.util
import json
import os
import struct
import zlib
import argparse
from pathlib import Path
from collections import Counter

# ─── Xcursor struct definitions ────────────────────────────────
lib = ctypes.CDLL(ctypes.util.find_library('Xcursor'))

class XcursorImage(ctypes.Structure):
    _fields_ = [
        ('version', ctypes.c_uint),
        ('size',    ctypes.c_uint),
        ('width',   ctypes.c_uint),
        ('height',  ctypes.c_uint),
        ('xhot',    ctypes.c_uint),
        ('yhot',    ctypes.c_uint),
        ('delay',   ctypes.c_uint),
        ('pixels',  ctypes.POINTER(ctypes.c_uint)),
    ]

class XcursorImages(ctypes.Structure):
    _fields_ = [
        ('nimage', ctypes.c_int),
        ('images', ctypes.POINTER(ctypes.POINTER(XcursorImage))),
        ('name',   ctypes.c_char_p),
    ]

lib.XcursorLibraryLoadImages.restype = ctypes.POINTER(XcursorImages)
lib.XcursorLibraryLoadImages.argtypes = [
    ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int
]

# ─── Color map: cursor_name → desired RGB ─────────────────────
# Current Bibata-Modern-Ice diagonal colors:
#   top_left_corner  → #4faddf (cyan)
#   top_right_corner → #f1613a (orange)
#   bottom_left_corner → #96c865 (lime)
#   bottom_right_corner → #fdbe2a (yellow)
#
# Set to null to keep original, or set new hex to recolor.

DEFAULT_COLOR_MAP = {
    # Diagonal resize cursors (colored)
    "top_left_corner":     {"hex": "#4faddf", "note": "↖ cyan"},
    "top_right_corner":    {"hex": "#f1613a", "note": "↗ orange"},
    "bottom_left_corner":  {"hex": "#96c865", "note": "↙ lime"},
    "bottom_right_corner": {"hex": "#fdbe2a", "note": "↘ yellow"},

    # Side resize cursors (currently white)
    "left_side":  {"hex": None, "note": "← white"},
    "right_side": {"hex": None, "note": "→ white"},
    "top_side":   {"hex": None, "note": "↑ white"},
    "bottom_side": {"hex": None, "note": "↓ white"},

    # Double-arrow cursors (currently black)
    "sb_h_double_arrow": {"hex": None, "note": "↔ black"},
    "sb_v_double_arrow": {"hex": None, "note": "↕ black"},
    "bd_double_arrow":   {"hex": None, "note": "↘ NWSE black"},
    "fd_double_arrow":   {"hex": None, "note": "↗ NESW black"},

    # Default arrow (keep white)
    "arrow": {"hex": None, "note": "default white"},
}

# ─── PNG writer (no PIL needed) ───────────────────────────────
def write_png(path, width, height, rgba_pixels):
    """Write an RGBA image to PNG."""
    def chunk(chunk_type, data):
        c = chunk_type + data
        crc = struct.pack('>I', zlib.crc32(c) & 0xffffffff)
        return struct.pack('>I', len(data)) + c + crc

    # IHDR
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)

    # IDAT — filter each row (filter byte 0 = None)
    raw = b''
    for y in range(height):
        raw += b'\x00'  # filter: none
        row = rgba_pixels[y * width : (y + 1) * width]
        for r, g, b, a in row:
            raw += bytes([r, g, b, a])
    compressed = zlib.compress(raw)

    # Build file
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', ihdr)
    png += chunk(b'IDAT', compressed)
    png += chunk(b'IEND', b'')

    with open(path, 'wb') as f:
        f.write(png)


def load_cursor(name, theme, size=24):
    """Load a cursor and return list of (width, height, xhot, yhot, delay, pixels_list)."""
    imgs = lib.XcursorLibraryLoadImages(name.encode(), theme.encode(), size)
    if not imgs or imgs.contents.nimage == 0:
        return []

    result = []
    for i in range(imgs.contents.nimage):
        img = imgs.contents.images[i].contents
        w, h = img.width, img.height
        pixels = []
        for y in range(h):
            for x in range(w):
                p = img.pixels[y * w + x]
                a = (p >> 24) & 0xff
                r = (p >> 16) & 0xff
                g = (p >> 8) & 0xff
                b = p & 0xff
                pixels.append((r, g, b, a))
        result.append({
            'width': w, 'height': h,
            'xhot': img.xhot, 'yhot': img.yhot,
            'delay': img.delay,
            'pixels': pixels,
        })

    # Don't destroy — segfaults. Let OS reclaim.
    return result


def get_dominant_color(pixels):
    """Get the most common opaque color from pixel list."""
    colors = Counter()
    for r, g, b, a in pixels:
        if a > 200:
            colors[(r, g, b)] += 1
    if colors:
        return colors.most_common(1)[0][0]
    return (255, 255, 255)


def recolor_pixels(pixels, target_rgb, preserve_alpha=True):
    """Recolor colored fill pixels, preserving black outline and white tip.
    
    Structure of cursor images (from analysis):
      - Dark pixels (lum < 50): black outline → keep as-is
      - Light pixels (lum > 220, opaque): white corner tip → keep as-is
      - Colored pixels (lum 50-220, opaque): fill → recolor to target
      - Semi-transparent: anti-aliasing → blend based on luminance
    """
    tr, tg, tb = target_rgb
    result = []
    for r, g, b, a in pixels:
        if a == 0:
            result.append((0, 0, 0, 0))
            continue
        
        lum = 0.299 * r + 0.587 * g + 0.114 * b
        
        # Dark pixels (outline) — keep as-is regardless of alpha
        if lum < 50:
            result.append((r, g, b, a))
            continue
        
        # White/light pixels (corner tip) — keep if mostly opaque
        if lum > 220 and a > 180:
            result.append((r, g, b, a))
            continue
        
        # Semi-transparent anti-aliasing — blend based on luminance
        if a < 200:
            if lum < 80:
                # Dark anti-aliasing (near outline) — keep dark
                result.append((r, g, b, a))
            else:
                # Light anti-aliasing (near fill or white) — tint with target
                alpha_factor = a / 255.0
                # Blend target color with transparency
                nr = int(tr * (1 - alpha_factor) + r * alpha_factor)
                ng = int(tg * (1 - alpha_factor) + g * alpha_factor)
                nb = int(tb * (1 - alpha_factor) + b * alpha_factor)
                result.append((min(255, max(0, nr)), min(255, max(0, ng)), min(255, max(0, nb)), a))
            continue
        
        # Fully opaque colored pixel — recolor to target
        result.append((tr, tg, tb, a))

    return result


def main():
    parser = argparse.ArgumentParser(description='Cursor Retool')
    parser.add_argument('--theme', default='Bibata-Modern-Ice',
                        help='Source cursor theme name')
    parser.add_argument('--size', type=int, default=24,
                        help='Cursor size to extract')
    parser.add_argument('--colors', type=str, default=None,
                        help='JSON file with color map')
    parser.add_argument('--list', action='store_true',
                        help='List current cursor colors and exit')
    parser.add_argument('--output', type=str, default='output',
                        help='Output directory for PNGs')
    args = parser.parse_args()

    # Load color map
    if args.colors:
        with open(args.colors) as f:
            color_map = json.load(f)
    else:
        color_map = DEFAULT_COLOR_MAP

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Theme: {args.theme}")
    print(f"Size:  {args.size}")
    print(f"Output: {output_dir}\n")

    # List mode — just show current colors
    if args.list:
        print("Current cursor colors:")
        print(f"{'Cursor':<25s} {'Color':<12s} {'Hex'}")
        print("-" * 55)
        for name in color_map:
            frames = load_cursor(name, args.theme, args.size)
            if frames:
                dom = get_dominant_color(frames[0]['pixels'])
                hex_str = f"#{dom[0]:02x}{dom[1]:02x}{dom[2]:02x}"
                print(f"{name:<25s} {hex_str:<12s} {color_map[name].get('note','')}")
        return

    # Recolor mode
    print("Recoloring cursors:")
    print(f"{'Cursor':<25s} {'Original':<12s} → {'New':<12s}")
    print("-" * 55)

    for name, info in color_map.items():
        target_hex = info.get('hex') if isinstance(info, dict) else info
        note = info.get('note', '') if isinstance(info, dict) else ''

        frames = load_cursor(name, args.theme, args.size)
        if not frames:
            print(f"{name:<25s} FAILED TO LOAD")
            continue

        for frame_idx, frame in enumerate(frames):
            orig_color = get_dominant_color(frame['pixels'])
            orig_hex = f"#{orig_color[0]:02x}{orig_color[1]:02x}{orig_color[2]:02x}"

            if target_hex:
                # Parse target color
                target_hex_clean = target_hex.lstrip('#')
                tr = int(target_hex_clean[0:2], 16)
                tg = int(target_hex_clean[2:4], 16)
                tb = int(target_hex_clean[4:6], 16)
                new_pixels = recolor_pixels(frame['pixels'], (tr, tg, tb))
                new_hex = target_hex
            else:
                new_pixels = frame['pixels']
                new_hex = orig_hex

            # Write PNG
            suffix = f"_{frame_idx}" if len(frames) > 1 else ""
            png_path = output_dir / f"{name}{suffix}.png"
            write_png(str(png_path), frame['width'], frame['height'], new_pixels)

            # Write xcursor conf line
            conf_line = f"{name}{suffix}.png {frame['width']} {frame['xhot']} {frame['yhot']} {frame['delay']}"

            print(f"{name:<25s} {orig_hex:<12s} → {new_hex:<12s}  ({frame['width']}x{frame['height']})")

    # Write xcursorgen config
    conf_path = output_dir / "cursors.conf"
    with open(conf_path, 'w') as f:
        f.write("# Xcursor config — used by xcursorgen to rebuild cursor files\n")
        f.write("# Format: image.png width xhot yhot delay\n\n")
        for name in color_map:
            frames = load_cursor(name, args.theme, args.size)
            for frame_idx in range(len(frames)):
                suffix = f"_{frame_idx}" if len(frames) > 1 else ""
                frame = frames[frame_idx]
                f.write(f"{name}{suffix}.png {frame['width']} {frame['xhot']} {frame['yhot']} {frame['delay']}\n")

    print(f"\n✓ PNGs saved to: {output_dir}")
    print(f"✓ Config saved to: {conf_path}")
    print(f"\nNext steps:")
    print(f"  1. Edit {conf_path} to add/remove cursor entries")
    print(f"  2. Run:  cd {output_dir} && bash build.sh")
    print(f"  3. Test: cp -r cursors/* /usr/share/icons/Bibata-Modern-Ice/cursors/")

    # Also write a build script
    build_path = output_dir / "build.sh"
    with open(build_path, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("# Rebuild Xcursor files from PNGs\n")
        f.write("set -e\n\n")
        f.write("SCRIPT_DIR=\"$(cd \"$(dirname \"$0\")\" && pwd)\"\n")
        f.write("OUTPUT_DIR=\"$SCRIPT_DIR/cursors\"\nmkdir -p \"$OUTPUT_DIR\"\n\n")
        f.write("cd \"$SCRIPT_DIR\"\n")
        f.write("echo \"Building cursor files...\"\n\n")
        # For each cursor entry, generate the Xcursor file
        for name in color_map:
            frames = load_cursor(name, args.theme, args.size)
            if len(frames) == 1:
                png = f"{name}.png"
                frame = frames[0]
                f.write(f"xcursorgen --no-shadows <<< \"{png} {frame['width']} {frame['xhot']} {frame['yhot']} {frame['delay']}\" > \"$OUTPUT_DIR/{name}\" 2>/dev/null\n")
                f.write(f"echo \"  {name}\"\n")
            else:
                # Multiple frames — concat xcursorgen outputs
                lines = []
                for fi in range(len(frames)):
                    frame = frames[fi]
                    lines.append(f"{name}_{fi}.png {frame['width']} {frame['xhot']} {frame['yhot']} {frame['delay']}")
                stdin_data = "\n".join(lines)
                f.write(f"echo '{stdin_data}' | xcursorgen --no-shadows > \"$OUTPUT_DIR/{name}\"\n")
                f.write(f"echo \"  {name} ({len(frames)} frames)\"\n")

        f.write(f'\necho "\\n✓ Done! {len(color_map)} cursor files built in $OUTPUT_DIR"\n')
        f.write(f'echo "  To install: sudo cp -r $OUTPUT_DIR/* /usr/share/icons/Bibata-Modern-Ice/cursors/"\n')

    os.chmod(str(build_path), 0o755)
    print(f"✓ Build script: {build_path}")


if __name__ == '__main__':
    main()
