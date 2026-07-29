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
cmd="/usr/bin/yazi"
# "wezterm start --always-new-process" if you use wezterm
if [ "$save" = "1" ]; then
  TITLE="Save File:"
elif [ "$directory" = "1" ]; then
  TITLE="Select Directory:"
else
  TITLE="Select File:"
fi

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

quote_string() {
  local input="$1"
  echo "'${input//\'/\'\\\'\'}'"
}

# Use filepicker class so Hyprland rules (floating, etc.) match
FP_CLASS="${YAZI_FP_CLASS:-filepicker}"
termcmd="${TERMCMD:-/usr/bin/kitty  --class $FP_CLASS --title $(quote_string "$TITLE")}"

# Disable autosession.yazi restore for transient portal picker windows
export YAZI_NO_SESSION=1

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
  tmpfile=$(/usr/bin/mktemp)

  # Save/download file
  # Sanitize the suggested filename so URL-encoded names (e.g. %3A from
  # Twitter/X) are decoded before the browser tries to save.
  suggested_dir=$(/usr/bin/dirname "$path")
  suggested_name=$(/usr/bin/basename "$path")
  suggested_name=$(sanitize_filename "$suggested_name")
  if [ -z "$suggested_name" ]; then
    suggested_name=".untitled"
  fi
  path="${suggested_dir}/${suggested_name}"

  # Ensure we don't overwrite an existing file
  base="$path"
  i=1
  while [ -e "$path" ]; do
    path="${base}${i}"
    i=$((i + 1))
  done

  /usr/bin/printf '%s' 'xdg-desktop-portal-termfilechooser saving files tutorial

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!                 === WARNING! ===                 !!!
!!! The contents of *whatever* file you open last in !!!
!!! yazi will be *overwritten*!                    !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Instructions:
1) Move this file wherever you want.
2) Rename the file if needed.
3) Confirm your selection by opening the file, for
   example by pressing <Enter>.

Notes:
1) This file is provided for your convenience. You can
	 only choose this placeholder file otherwise the save operation aborted.
2) If you quit yazi without opening a file, this file
   will be removed and the save operation aborted.
' >"$path"
  set -- --chooser-file="$(quote_string "$tmpfile")" "$(quote_string "$path")"
elif [ "$directory" = "1" ]; then
  # upload files from a directory
  set -- --cwd-file="$(quote_string "$out")" "$(quote_string "$path")"
elif [ "$multiple" = "1" ]; then
  # upload multiple files
  set -- --chooser-file="$(quote_string "$out")" "$(quote_string "$path")"
else
  # upload only 1 file
  set -- --chooser-file="$(quote_string "$out")" "$(quote_string "$path")"
fi

eval "$termcmd -- $cmd $@"

# case save file
if [ "$save" = "1" ] && [ -s "$tmpfile" ]; then
  selected_file=$(/usr/bin/head -n 1 "$tmpfile")
  # Check if selected file is placeholder file
  if [ -f "$selected_file" ] && /usr/bin/grep -qi "^xdg-desktop-portal-termfilechooser saving files tutorial" "$selected_file"; then
    /usr/bin/echo "$selected_file" >"$out"
    path="$selected_file"
  fi
fi
