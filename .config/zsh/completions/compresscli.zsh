#compdef compresscli

autoload -U is-at-least

_compresscli() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_compresscli_commands" \
"*::: :->compresscli" \
&& ret=0
    case $state in
    (compresscli)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:compresscli-command-$line[1]:"
        case $line[1] in
            (video)
_arguments "${_arguments_options[@]}" : \
'-p+[Compression preset]:PRESET:((fast\:"Fast compression, larger file size"
medium\:"Balanced compression and quality"
slow\:"Slow compression, smaller file size"
ultrafast\:"Ultra-fast compression"
veryslow\:"Very slow, maximum compression"
custom\:"Custom settings"))' \
'--preset=[Compression preset]:PRESET:((fast\:"Fast compression, larger file size"
medium\:"Balanced compression and quality"
slow\:"Slow compression, smaller file size"
ultrafast\:"Ultra-fast compression"
veryslow\:"Very slow, maximum compression"
custom\:"Custom settings"))' \
'--codec=[Video codec]:CODEC:((h264\:"H.264 (widely compatible)"
h265\:"H.265/HEVC (better compression)"
vp9\:"VP9 (open source)"
av1\:"AV1 (next-gen codec)"))' \
'--crf=[Constant Rate Factor (0-51, lower = better quality)]:CRF:_default' \
'--bitrate=[Target bitrate (e.g., "1M", "500K")]:BITRATE:_default' \
'--resolution=[Target resolution (e.g., "1920x1080", "720p")]:RESOLUTION:_default' \
'--fps=[Target framerate]:FPS:_default' \
'--audio-codec=[Audio codec]:AUDIO_CODEC:((aac\:"AAC (widely compatible)"
mp3\:"MP3 (legacy)"
opus\:"Opus (high quality)"
copy\:"Copy original"))' \
'--audio-bitrate=[Audio bitrate (e.g., "128K", "256K")]:AUDIO_BITRATE:_default' \
'--start=[Start time for trimming (e.g., "00\:01\:30")]:START:_default' \
'--end=[End time for trimming (e.g., "00\:05\:00")]:END:_default' \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'--no-audio[Remove audio track]' \
'--two-pass[Two-pass encoding for better quality]' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':input -- Input video file:_files' \
'::output -- Output file (optional, will auto-generate if not provided):_files' \
&& ret=0
;;
(image)
_arguments "${_arguments_options[@]}" : \
'-q+[Image quality (1-100)]:QUALITY:_default' \
'--quality=[Image quality (1-100)]:QUALITY:_default' \
'-f+[Output format]:FORMAT:((jpeg\:"JPEG format"
png\:"PNG format"
webp\:"WebP format"
avif\:"AVIF format (next-gen)"))' \
'--format=[Output format]:FORMAT:((jpeg\:"JPEG format"
png\:"PNG format"
webp\:"WebP format"
avif\:"AVIF format (next-gen)"))' \
'--resize=[Resize to specific dimensions (e.g., "800x600")]:RESIZE:_default' \
'--max-width=[Maximum width (maintains aspect ratio)]:MAX_WIDTH:_default' \
'--max-height=[Maximum height (maintains aspect ratio)]:MAX_HEIGHT:_default' \
'-p+[Image preset (web, high, lossless)]:PRESET:_default' \
'--preset=[Image preset (web, high, lossless)]:PRESET:_default' \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'--optimize[Enable optimization]' \
'--progressive[Progressive JPEG]' \
'--lossless[Lossless compression (where supported)]' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':input -- Input image file:_files' \
'::output -- Output file (optional, will auto-generate if not provided):_files' \
&& ret=0
;;
(batch)
_arguments "${_arguments_options[@]}" : \
'-p+[File pattern (e.g., "*.mp4", "*.jpg")]:PATTERN:_default' \
'--pattern=[File pattern (e.g., "*.mp4", "*.jpg")]:PATTERN:_default' \
'--video-preset=[Video preset for batch processing]:VIDEO_PRESET:((fast\:"Fast compression, larger file size"
medium\:"Balanced compression and quality"
slow\:"Slow compression, smaller file size"
ultrafast\:"Ultra-fast compression"
veryslow\:"Very slow, maximum compression"
custom\:"Custom settings"))' \
'--image-quality=[Image quality for batch processing]:IMAGE_QUALITY:_default' \
'-j+[Maximum parallel jobs]:JOBS:_default' \
'--jobs=[Maximum parallel jobs]:JOBS:_default' \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'--videos[Process videos]' \
'--images[Process images]' \
'-r[Recursive processing]' \
'--recursive[Recursive processing]' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':directory -- Input directory:_files' \
&& ret=0
;;
(presets)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
":: :_compresscli__presets_commands" \
"*::: :->presets" \
&& ret=0

    case $state in
    (presets)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:compresscli-presets-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
':name -- Preset name:_default' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
':name -- Preset name:_default' \
':config -- Preset configuration file:_files' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
':name -- Preset name:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_compresscli__presets__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:compresscli-presets-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(info)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" : \
'-o+[Output directory]:OUTPUT_DIR:_files' \
'--output-dir=[Output directory]:OUTPUT_DIR:_files' \
'--config=[Custom config file]:CONFIG:_files' \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'--dry-run[Dry run - show what would be done without executing]' \
'--overwrite[Overwrite existing files]' \
'-h[Print help]' \
'--help[Print help]' \
':shell -- Shell to generate completions for:(bash elvish fish powershell zsh)' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_compresscli__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:compresscli-help-command-$line[1]:"
        case $line[1] in
            (video)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(image)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(batch)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(presets)
_arguments "${_arguments_options[@]}" : \
":: :_compresscli__help__presets_commands" \
"*::: :->presets" \
&& ret=0

    case $state in
    (presets)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:compresscli-help-presets-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(show)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_compresscli_commands] )) ||
_compresscli_commands() {
    local commands; commands=(
'video:Compress video files' \
'image:Compress image files' \
'batch:Batch process files in a directory' \
'presets:Manage compression presets' \
'info:Show system information and dependencies' \
'completions:Generate shell completion scripts' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'compresscli commands' commands "$@"
}
(( $+functions[_compresscli__batch_commands] )) ||
_compresscli__batch_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli batch commands' commands "$@"
}
(( $+functions[_compresscli__completions_commands] )) ||
_compresscli__completions_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli completions commands' commands "$@"
}
(( $+functions[_compresscli__help_commands] )) ||
_compresscli__help_commands() {
    local commands; commands=(
'video:Compress video files' \
'image:Compress image files' \
'batch:Batch process files in a directory' \
'presets:Manage compression presets' \
'info:Show system information and dependencies' \
'completions:Generate shell completion scripts' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'compresscli help commands' commands "$@"
}
(( $+functions[_compresscli__help__batch_commands] )) ||
_compresscli__help__batch_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help batch commands' commands "$@"
}
(( $+functions[_compresscli__help__completions_commands] )) ||
_compresscli__help__completions_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help completions commands' commands "$@"
}
(( $+functions[_compresscli__help__help_commands] )) ||
_compresscli__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help help commands' commands "$@"
}
(( $+functions[_compresscli__help__image_commands] )) ||
_compresscli__help__image_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help image commands' commands "$@"
}
(( $+functions[_compresscli__help__info_commands] )) ||
_compresscli__help__info_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help info commands' commands "$@"
}
(( $+functions[_compresscli__help__presets_commands] )) ||
_compresscli__help__presets_commands() {
    local commands; commands=(
'list:List all available presets' \
'show:Show details of a specific preset' \
'create:Create a custom preset' \
'delete:Delete a custom preset' \
    )
    _describe -t commands 'compresscli help presets commands' commands "$@"
}
(( $+functions[_compresscli__help__presets__create_commands] )) ||
_compresscli__help__presets__create_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help presets create commands' commands "$@"
}
(( $+functions[_compresscli__help__presets__delete_commands] )) ||
_compresscli__help__presets__delete_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help presets delete commands' commands "$@"
}
(( $+functions[_compresscli__help__presets__list_commands] )) ||
_compresscli__help__presets__list_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help presets list commands' commands "$@"
}
(( $+functions[_compresscli__help__presets__show_commands] )) ||
_compresscli__help__presets__show_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help presets show commands' commands "$@"
}
(( $+functions[_compresscli__help__video_commands] )) ||
_compresscli__help__video_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli help video commands' commands "$@"
}
(( $+functions[_compresscli__image_commands] )) ||
_compresscli__image_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli image commands' commands "$@"
}
(( $+functions[_compresscli__info_commands] )) ||
_compresscli__info_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli info commands' commands "$@"
}
(( $+functions[_compresscli__presets_commands] )) ||
_compresscli__presets_commands() {
    local commands; commands=(
'list:List all available presets' \
'show:Show details of a specific preset' \
'create:Create a custom preset' \
'delete:Delete a custom preset' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'compresscli presets commands' commands "$@"
}
(( $+functions[_compresscli__presets__create_commands] )) ||
_compresscli__presets__create_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets create commands' commands "$@"
}
(( $+functions[_compresscli__presets__delete_commands] )) ||
_compresscli__presets__delete_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets delete commands' commands "$@"
}
(( $+functions[_compresscli__presets__help_commands] )) ||
_compresscli__presets__help_commands() {
    local commands; commands=(
'list:List all available presets' \
'show:Show details of a specific preset' \
'create:Create a custom preset' \
'delete:Delete a custom preset' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'compresscli presets help commands' commands "$@"
}
(( $+functions[_compresscli__presets__help__create_commands] )) ||
_compresscli__presets__help__create_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets help create commands' commands "$@"
}
(( $+functions[_compresscli__presets__help__delete_commands] )) ||
_compresscli__presets__help__delete_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets help delete commands' commands "$@"
}
(( $+functions[_compresscli__presets__help__help_commands] )) ||
_compresscli__presets__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets help help commands' commands "$@"
}
(( $+functions[_compresscli__presets__help__list_commands] )) ||
_compresscli__presets__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets help list commands' commands "$@"
}
(( $+functions[_compresscli__presets__help__show_commands] )) ||
_compresscli__presets__help__show_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets help show commands' commands "$@"
}
(( $+functions[_compresscli__presets__list_commands] )) ||
_compresscli__presets__list_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets list commands' commands "$@"
}
(( $+functions[_compresscli__presets__show_commands] )) ||
_compresscli__presets__show_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli presets show commands' commands "$@"
}
(( $+functions[_compresscli__video_commands] )) ||
_compresscli__video_commands() {
    local commands; commands=()
    _describe -t commands 'compresscli video commands' commands "$@"
}

if [ "$funcstack[1]" = "_compresscli" ]; then
    _compresscli "$@"
else
    compdef _compresscli compresscli
fi
