#!/usr/bin/env bash
# ── CGGX Lens Search ──────────────────────────
# Captures a region, injects into Google Lens via local HTML form
# so the browser owns the session. Based on QuickSnip's approach.
# Bound to SUPER+ALT+Print in binds.lua
set -euo pipefail

MESSAGE="Searching with Google Lens..."
BGCOLOR="#111"
TEXTCOLOR="#fff"

TS=$(date +%s)
PNG="/tmp/lens-${TS}.png"
JPG="/tmp/lens-${TS}.jpg"
HTML="/tmp/lens-${TS}.html"

# Capture region — bail if cancelled (Escape)
if ! grimblast save area "$PNG"; then
    exit 1
fi

notify-send "🔍 Lens" "$MESSAGE"

# Resize and convert to JPEG
magick "$PNG" -resize '1000x1000>' -strip -quality 85 "$JPG"

# Build HTML with auto-submitting form (QuickSnip's form injection trick)
B64=$(base64 -w0 "$JPG" 2>/dev/null || base64 -b0 "$JPG")
cat > "$HTML" << EOF
<html><body style="margin:0;display:flex;justify-content:center;align-items:center;height:100vh;background:${BGCOLOR};color:${TEXTCOLOR};font-family:system-ui">
<p>${MESSAGE}</p>
<form id="f" method="POST" enctype="multipart/form-data" action="https://lens.google.com/v3/upload"></form>
<script>
var b=atob('$B64');
var a=new Uint8Array(b.length);
for(var i=0;i<b.length;i++) a[i]=b.charCodeAt(i);
var d=new DataTransfer();
d.items.add(new File([a],"i.jpg",{type:"image/jpeg"}));
var inp=document.createElement("input");inp.type="file";inp.name="encoded_image";inp.files=d.files;inp.style.cssText="position:fixed;top:-100px;left:0;opacity:0;width:0;height:0";
document.getElementById("f").appendChild(inp);
document.getElementById("f").submit();
</script></body></html>
EOF

xdg-open "$HTML" &

# Clean up after 30 seconds
(sleep 30 && rm -f "$PNG" "$JPG" "$HTML") &
