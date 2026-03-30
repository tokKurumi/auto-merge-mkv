#!/bin/bash

set -o pipefail

usage() {
    cat <<'EOF'
Usage:
  auto-merge.sh \
    --root-folder <path> \
    --sounds-folder <path> \
    --sounds-region <code> \
    --subtitles-folder <path> \
    --subtitles-region <code> \
        --output-folder <path> \
        [--fonts-folder <path>] \
        [--parallel <N>]

Paths may be absolute or relative. Tracks are matched by exact filename (e.g., S01E01-Jobless Reincarnation.mkv ↔ S01E01-Jobless Reincarnation.mka/.ass). Track names come from the immediate parent folder (e.g., Sounds/AniLibria → AniLibria).
EOF
}

die() {
    echo "$*" >&2
    exit 1
}

root="."
sounds_folder=""
sounds_region=""
subs_folder=""
subs_region=""
fonts_folder=""
output_folder=""
parallel_jobs=1
single_file=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --root-folder=*) root="${1#*=}"; shift ;;
        --root-folder) root="$2"; shift 2 ;;
        --sounds-folder=*) sounds_folder="${1#*=}"; shift ;;
        --sounds-folder) sounds_folder="$2"; shift 2 ;;
        --sounds-region=*) sounds_region="${1#*=}"; shift ;;
        --sounds-region) sounds_region="$2"; shift 2 ;;
        --subtitles-folder=*) subs_folder="${1#*=}"; shift ;;
        --subtitles-folder) subs_folder="$2"; shift 2 ;;
        --subtitles-region=*) subs_region="${1#*=}"; shift ;;
        --subtitles-region) subs_region="$2"; shift 2 ;;
        --fonts-folder=*) fonts_folder="${1#*=}"; shift ;;
        --fonts-folder) fonts_folder="$2"; shift 2 ;;
        --output-folder=*) output_folder="${1#*=}"; shift ;;
        --output-folder) output_folder="$2"; shift 2 ;;
        --parallel=*) parallel_jobs="${1#*=}"; shift ;;
        --parallel) parallel_jobs="$2"; shift 2 ;;
        --single-file=*) single_file="${1#*=}"; shift ;;
        --single-file) single_file="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown argument: $1" ;;
    esac
done

[[ -n "$sounds_folder" && -n "$subs_folder" && -n "$output_folder" && -n "$sounds_region" && -n "$subs_region" ]] || {
    usage
    die "Missing required arguments"
}

[[ "$parallel_jobs" =~ ^[0-9]+$ && "$parallel_jobs" -ge 1 ]] || die "--parallel must be a positive integer"

command -v mkvmerge >/dev/null 2>&1 || die "mkvmerge is required but not found in PATH"
command -v parallel >/dev/null 2>&1 || { [[ "$parallel_jobs" -eq 1 ]] || die "gnu parallel is required for --parallel"; }

resolve_path() {
    local base="$1" path="$2"
    if [[ "$path" = /* ]]; then
        printf "%s\n" "$path"
    else
        printf "%s/%s\n" "$base" "$path"
    fi
}

root=$(realpath "$root")
sounds_folder=$(realpath "$(resolve_path "$root" "$sounds_folder")")
subs_folder=$(realpath "$(resolve_path "$root" "$subs_folder")")
output_folder="$(resolve_path "$root" "$output_folder")"
if [[ -n "$fonts_folder" ]]; then
    fonts_folder=$(realpath "$(resolve_path "$root" "$fonts_folder")")
fi

if [[ -n "$single_file" && "$single_file" != /* ]]; then
    single_file="$(resolve_path "$root" "$single_file")"
fi

[[ -d "$root" ]] || die "Root folder not found: $root"
[[ -d "$sounds_folder" ]] || die "Sounds folder not found: $sounds_folder"
[[ -d "$subs_folder" ]] || die "Subtitles folder not found: $subs_folder"
[[ -d "$output_folder" ]] || mkdir -p "$output_folder" || die "Cannot create output folder: $output_folder"
output_folder=$(realpath "$output_folder")
if [[ -n "$fonts_folder" ]]; then
    [[ -d "$fonts_folder" ]] || die "Fonts folder not found: $fonts_folder"
fi
if [[ -n "$single_file" ]]; then
    [[ -f "$single_file" ]] || die "Single file not found: $single_file"
fi

declare -A seen_fonts
font_files=()

add_fonts_from_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || return
    while IFS= read -r -d '' font; do
        local real
        real=$(realpath "$font")
        [[ -n ${seen_fonts[$real]:-} ]] && continue
        seen_fonts[$real]=1
        font_files+=("$font")
    done < <(find "$dir" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0)
}

add_fonts_from_dir "$subs_folder"
if [[ -n "$fonts_folder" ]]; then
    add_fonts_from_dir "$fonts_folder"
fi

attachment_options=()
for font in "${font_files[@]}"; do
    attachment_options+=("--attach-file" "$font")
done

process_video() {
    local video="$1"
    basename="$(basename "${video%.mkv}")"

    audio_options=()
    for studio in "$sounds_folder"/*; do
        [[ -d "$studio" ]] || continue
        audio_file="$studio/$basename.mka"
        if [[ -f "$audio_file" ]]; then
            studio_name=$(basename "$studio")
            audio_options+=("--language" "0:$sounds_region" "--track-name" "0:$studio_name" "$audio_file")
        fi
    done

    sub_options=()
    for studio in "$subs_folder"/*; do
        [[ -d "$studio" ]] || continue
        sub_file="$studio/$basename.ass"
        if [[ -f "$sub_file" ]]; then
            studio_name=$(basename "$studio")
            sub_options+=("--language" "0:$subs_region" "--track-name" "0:$studio_name" "$sub_file")
        fi
    done

    if [[ ${#audio_options[@]} -eq 0 && ${#sub_options[@]} -eq 0 ]]; then
        echo "Skipping $video: no matching audio or subtitles" >&2
        return 0
    fi

    output_file="$output_folder/$(basename "$video")"
    if mkvmerge -o "$output_file" "$video" "${audio_options[@]}" "${sub_options[@]}" "${attachment_options[@]}"; then
        echo "Processed: $output_file"
    else
        echo "Failed: $video" >&2
        return 1
    fi
}

if [[ -n "$single_file" ]]; then
    process_video "$single_file"
    exit $?
fi

mapfile -d '' -t videos < <(find "$root" -maxdepth 1 -type f -name '*.mkv' -print0 | sort -z)

if [[ ${#videos[@]} -eq 0 ]]; then
    die "No mkv files found in $root"
fi

if [[ "$parallel_jobs" -gt 1 ]]; then
    script_path=$(realpath "$0")
    fonts_arg=()
    [[ -n "$fonts_folder" ]] && fonts_arg=(--fonts-folder "$fonts_folder")
    parallel --halt now,fail=1 --jobs "$parallel_jobs" -q "$script_path" \
        --root-folder "$root" \
        --sounds-folder "$sounds_folder" \
        --sounds-region "$sounds_region" \
        --subtitles-folder "$subs_folder" \
        --subtitles-region "$subs_region" \
        "${fonts_arg[@]}" \
        --output-folder "$output_folder" \
        --single-file {} ::: "${videos[@]}"
    exit $?
fi

for video in "${videos[@]}"; do
    process_video "$video"
done
