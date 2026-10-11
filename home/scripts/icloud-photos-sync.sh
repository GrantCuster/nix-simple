#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/icloudpd-sync"
account_file="$config_dir/apple-id"
cookie_dir="${XDG_STATE_HOME:-$HOME/.local/state}/icloudpd-sync/cookies"
photo_dir="$HOME/Pictures/iCloud"
original_dir="$photo_dir/.originals"

mkdir -p "$config_dir" "$cookie_dir" "$photo_dir" "$original_dir"
chmod 700 "$config_dir" "$cookie_dir"

if [[ "${1:-}" == "--login" ]]; then
  apple_id="${2:-}"
  if [[ -z "$apple_id" ]]; then
    read -r -p "Apple ID email: " apple_id
  fi
  printf '%s\n' "$apple_id" > "$account_file"
  chmod 600 "$account_file"
  exec icloudpd \
    --username "$apple_id" \
    --cookie-directory "$cookie_dir" \
    --auth-only
fi

if [[ ! -s "$account_file" ]]; then
  echo "iCloud Photos is not authenticated." >&2
  echo "Run: icloud-photos-sync --login" >&2
  exit 2
fi

apple_id="$(<"$account_file")"

icloudpd \
  --username "$apple_id" \
  --directory "$original_dir" \
  --cookie-directory "$cookie_dir" \
  --skip-created-before 90d \
  --until-found 50 \
  --skip-live-photos \
  --folder-structure none \
  --no-progress-bar \
  "$@"

publish_copy() {
  local source="$1" target="$2"
  if [[ ! -e "$target" || "$source" -nt "$target" ]]; then
    cp --reflink=auto --preserve=timestamps "$source" "$target"
  fi
}

convert_image() {
  local input_path="$1" target="$2" temp orientation
  if [[ -e "$target" && ! "$input_path" -nt "$target" ]]; then
    orientation="$(exiftool -s3 -n -Orientation "$target" 2>/dev/null || true)"
    if [[ "$orientation" == "1" ]]; then
      return
    fi
  fi
  temp="${target%.jpg}.tmp.$$.jpg"
  rm -f "$temp"
  magick "${input_path}[0]" -auto-orient -quality 92 "$temp"
  exiftool -overwrite_original -TagsFromFile "$input_path" -all:all "$temp" >/dev/null || true
  exiftool -overwrite_original -n -Orientation=1 "$temp" >/dev/null
  touch -r "$input_path" "$temp"
  mv -f "$temp" "$target"
}

convert_video() {
  local source="$1" target="$2" temp
  if [[ -e "$target" && ! "$source" -nt "$target" ]]; then
    return
  fi
  temp="${target%.mp4}.tmp.$$.mp4"
  rm -f "$temp"
  ffmpeg -nostdin -hide_banner -loglevel warning -y \
    -i "$source" -map 0:v:0 -map 0:a:0? -map_metadata 0 \
    -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -movflags +faststart "$temp"
  exiftool -overwrite_original -TagsFromFile "$source" -all:all "$temp" >/dev/null || true
  touch -r "$source" "$temp"
  mv -f "$temp" "$target"
}

while IFS= read -r -d '' source; do
  filename="${source##*/}"
  stem="${filename%.*}"
  extension="${filename##*.}"
  extension="${extension,,}"

  case "$extension" in
    heic|heif)
      convert_image "$source" "$photo_dir/$stem.jpg"
      ;;
    mov)
      if [[ "$filename" == *_HEVC.MOV || "$filename" == *_HEVC.mov ]]; then
        continue
      fi
      convert_video "$source" "$photo_dir/$stem.mp4"
      ;;
    jpg|jpeg|png|gif|webp|tif|tiff|bmp|mp4|m4v)
      publish_copy "$source" "$photo_dir/$filename"
      ;;
    *)
      echo "Original retained without a converted copy: $filename" >&2
      ;;
  esac
done < <(find "$original_dir" -maxdepth 1 -type f -print0)
