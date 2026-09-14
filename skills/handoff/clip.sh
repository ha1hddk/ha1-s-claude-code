#!/usr/bin/env bash
# Copy a file (or stdin) to the system clipboard. Handles Wayland (wl-copy) and
# X11/XWayland (xclip), and derives WAYLAND_DISPLAY from the runtime socket if
# the env var is unset (the tool shell often doesn't export it). Exits 0 on
# success (prints which tool), 1 if no clipboard is reachable.
set -uo pipefail
SRC="${1:--}"
if [ "$SRC" != "-" ] && [ ! -f "$SRC" ]; then
  echo "clip: file not found: $SRC" >&2; exit 1
fi
read_src() { if [ "$SRC" = "-" ]; then cat; else cat "$SRC"; fi; }

# If a Wayland socket exists but WAYLAND_DISPLAY is unset, point at it.
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  s=$(ls "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/wayland-* 2>/dev/null | grep -v '\.lock' | head -1 || true)
  [ -n "${s:-}" ] && export WAYLAND_DISPLAY="$(basename "$s")"
fi

if command -v wl-copy >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  if read_src | wl-copy 2>/dev/null; then echo "clip: copied via wl-copy ($WAYLAND_DISPLAY)"; exit 0; fi
fi
if command -v xclip >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  if read_src | xclip -selection clipboard 2>/dev/null; then echo "clip: copied via xclip ($DISPLAY)"; exit 0; fi
fi

echo "clip: no reachable clipboard (need wl-copy+WAYLAND_DISPLAY or xclip+DISPLAY). Copy manually." >&2
exit 1
