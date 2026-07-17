#!/usr/bin/env bash

if [[ "$6" == "1" ]]; then
  set -x
fi

# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# Inputs:
# 1. "1" if multiple files can be chosen, "0" otherwise.
# 2. "1" if a directory should be chosen, "0" otherwise.
# 3. "0" if opening files was requested, "1" if writing to a file was
#    requested. For example, when uploading files in Firefox, this will be "0".
#    When saving a web page in Firefox, this will be "1".
# 4. If writing to a file, this is recommended path provided by the caller. For
#    example, when saving a web page in Firefox, this will be the recommended
#    path Firefox provided, such as "~/Downloads/webpage_title.html".
#    Note that if the path already exists, we keep appending "_" to it until we
#    get a path that does not exist.
# 5. The output path, to which results should be written.
# 6. "1" if log level >= DEBUG, "0" otherwise.
#
# Output:
# The script should print the selected paths to the output path (argument #5),
# one path per line.
# If nothing is printed, then the operation is assumed to have been canceled.

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

# URL-decode the suggested filename and strip query/fragment noise.
# Some apps (e.g. Twitter/X image downloads) hand the portal a URL-encoded
# basename like "HNWP9FowwAAlVd5.jpg%3Alarge". If the placeholder keeps the
# raw "%3A" the browser may save elsewhere or silently fail.
url_decode() {
	local s="$1"
	local decoded=""
	local i=0
	local len=${#s}
	while (( i < len )); do
		local c="${s:i:1}"
		if [[ "$c" == "%" && $((i + 2)) -lt $len ]]; then
			local hex="${s:i+1:2}"
			if [[ "$hex" =~ ^[0-9A-Fa-f]{2}$ ]]; then
				decoded+="$(printf "\\x$hex")"
				((i += 3))
				continue
			fi
		fi
		decoded+="$c"
		((i++))
	done
	echo "$decoded"
}

sanitize_filename() {
	local s="$1"
	s="${s%%#*}"   # strip fragment
	s="${s%%\?*}"  # strip query string
	s="$(url_decode "$s")"
	# Strip X/Twitter image size suffixes (:large, :small, :medium, :orig)
	s="${s%:large}"
	s="${s%:small}"
	s="${s%:medium}"
	s="${s%:orig}"
	echo "$s"
}

cleanup() {
  if [ -f "$tmpfile" ]; then
    /usr/bin/rm "$tmpfile" || :
  fi
  if [ "$save" = "1" ] && [ ! -s "$out" ]; then
    /usr/bin/rm "$path" || :
  fi
}

trap cleanup EXIT HUP INT QUIT ABRT TERM

if [ "$save" = "1" ]; then
  # ── Save As workflow ──────────────────────
  tmpfile=$(/usr/bin/mktemp)

  # If the app provided a suggested filename, create placeholder with that name
  # in ~/Downloads. Otherwise fall back to .untitled (hidden → organizer ignores).
  if [ -n "$path" ] && [ ! -d "$path" ]; then
    suggested_name=$(/usr/bin/basename "$path")
    suggested_name=$(sanitize_filename "$suggested_name")
    if [ -z "$suggested_name" ]; then
      suggested_name=".untitled"
    fi
    base="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}/${suggested_name}"
    path="$base"
    i=1
    while [ -e "$path" ]; do
      path="${base}${i}"
      i=$((i + 1))
    done
  else
    base="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}/.untitled"
    path="$base"
    i=1
    while [ -e "$path" ]; do
      path="${base}${i}"
      i=$((i + 1))
    done
  fi

  # Create the placeholder file
  /usr/bin/printf '%s' 'xdg-desktop-portal-termfilechooser saving files tutorial

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!                 === WARNING! ===                 !!!
!!! The contents of *whatever* file you open last in !!!
!!! yazi will be *overwritten*!                    !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Instructions:
1) Press Enter to save with the suggested name, or rename first (r key).
2) Navigate to a different directory if needed (tab key).
3) Press Enter on the file to confirm.

Notes:
1) This file is provided for your convenience. You can
   only choose this placeholder file otherwise the save operation aborted.
2) If you quit yazi without opening a file, this file
   will be removed and the save operation aborted.
' >"$path"

  YAZI_NO_SESSION=1 kitty --class filepicker -e yazi --chooser-file="$tmpfile" "${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"

elif [ "$directory" = "1" ]; then
  # ── Directory picker ──────────────────────
  YAZI_NO_SESSION=1 kitty --class filepicker -e yazi --cwd-file="$out" "$path"

elif [ "$multiple" = "1" ]; then
  # ── Multi-file open ───────────────────────
  YAZI_NO_SESSION=1 kitty --class filepicker -e yazi --chooser-file="$out" "$path"

else
  # ── Single-file open ──────────────────────
  YAZI_NO_SESSION=1 kitty --class filepicker -e yazi --chooser-file="$out" "$path"
fi

# Write the selected path back to the portal
if [ "$save" = "1" ] && [ -s "$tmpfile" ]; then
  selected_file=$(/usr/bin/head -n 1 "$tmpfile")
  if [ -n "$selected_file" ]; then
    /usr/bin/echo "$selected_file" >"$out"
  fi
fi



