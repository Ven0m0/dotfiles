# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_compresscli_global_optspecs
	string join \n v/verbose dry-run overwrite o/output-dir= config= h/help V/version
end

function __fish_compresscli_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_compresscli_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_compresscli_using_subcommand
	set -l cmd (__fish_compresscli_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c compresscli -n "__fish_compresscli_needs_command" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_needs_command" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_needs_command" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_needs_command" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_needs_command" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_needs_command" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_needs_command" -s V -l version -d 'Print version'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "video" -d 'Compress video files'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "image" -d 'Compress image files'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "batch" -d 'Batch process files in a directory'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "presets" -d 'Manage compression presets'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "info" -d 'Show system information and dependencies'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "completions" -d 'Generate shell completion scripts'
complete -c compresscli -n "__fish_compresscli_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -s p -l preset -d 'Compression preset' -r -f -a "fast\t'Fast compression, larger file size'
medium\t'Balanced compression and quality'
slow\t'Slow compression, smaller file size'
ultrafast\t'Ultra-fast compression'
veryslow\t'Very slow, maximum compression'
custom\t'Custom settings'"
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l codec -d 'Video codec' -r -f -a "h264\t'H.264 (widely compatible)'
h265\t'H.265/HEVC (better compression)'
vp9\t'VP9 (open source)'
av1\t'AV1 (next-gen codec)'"
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l crf -d 'Constant Rate Factor (0-51, lower = better quality)' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l bitrate -d 'Target bitrate (e.g., "1M", "500K")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l resolution -d 'Target resolution (e.g., "1920x1080", "720p")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l fps -d 'Target framerate' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l audio-codec -d 'Audio codec' -r -f -a "aac\t'AAC (widely compatible)'
mp3\t'MP3 (legacy)'
opus\t'Opus (high quality)'
copy\t'Copy original'"
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l audio-bitrate -d 'Audio bitrate (e.g., "128K", "256K")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l start -d 'Start time for trimming (e.g., "00:01:30")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l end -d 'End time for trimming (e.g., "00:05:00")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l no-audio -d 'Remove audio track'
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l two-pass -d 'Two-pass encoding for better quality'
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand video" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -s q -l quality -d 'Image quality (1-100)' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -s f -l format -d 'Output format' -r -f -a "jpeg\t'JPEG format'
png\t'PNG format'
webp\t'WebP format'
avif\t'AVIF format (next-gen)'"
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l resize -d 'Resize to specific dimensions (e.g., "800x600")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l max-width -d 'Maximum width (maintains aspect ratio)' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l max-height -d 'Maximum height (maintains aspect ratio)' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -s p -l preset -d 'Image preset (web, high, lossless)' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l optimize -d 'Enable optimization'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l progressive -d 'Progressive JPEG'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l lossless -d 'Lossless compression (where supported)'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand image" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -s p -l pattern -d 'File pattern (e.g., "*.mp4", "*.jpg")' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l video-preset -d 'Video preset for batch processing' -r -f -a "fast\t'Fast compression, larger file size'
medium\t'Balanced compression and quality'
slow\t'Slow compression, smaller file size'
ultrafast\t'Ultra-fast compression'
veryslow\t'Very slow, maximum compression'
custom\t'Custom settings'"
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l image-quality -d 'Image quality for batch processing' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -s j -l jobs -d 'Maximum parallel jobs' -r
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l videos -d 'Process videos'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l images -d 'Process images'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -s r -l recursive -d 'Recursive processing'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand batch" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -f -a "list" -d 'List all available presets'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -f -a "show" -d 'Show details of a specific preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -f -a "create" -d 'Create a custom preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -f -a "delete" -d 'Delete a custom preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and not __fish_seen_subcommand_from list show create delete help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from list" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from list" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from list" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from list" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from list" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from show" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from show" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from show" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from show" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from show" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from show" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from create" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from create" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from create" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from create" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from create" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from delete" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from delete" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from delete" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from delete" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from delete" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from delete" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from help" -f -a "list" -d 'List all available presets'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from help" -f -a "show" -d 'Show details of a specific preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from help" -f -a "create" -d 'Create a custom preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from help" -f -a "delete" -d 'Delete a custom preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand presets; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c compresscli -n "__fish_compresscli_using_subcommand info" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand info" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand info" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand info" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand info" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand info" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand completions" -s o -l output-dir -d 'Output directory' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand completions" -l config -d 'Custom config file' -r -F
complete -c compresscli -n "__fish_compresscli_using_subcommand completions" -s v -l verbose -d 'Enable verbose output'
complete -c compresscli -n "__fish_compresscli_using_subcommand completions" -l dry-run -d 'Dry run - show what would be done without executing'
complete -c compresscli -n "__fish_compresscli_using_subcommand completions" -l overwrite -d 'Overwrite existing files'
complete -c compresscli -n "__fish_compresscli_using_subcommand completions" -s h -l help -d 'Print help'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "video" -d 'Compress video files'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "image" -d 'Compress image files'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "batch" -d 'Batch process files in a directory'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "presets" -d 'Manage compression presets'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "info" -d 'Show system information and dependencies'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "completions" -d 'Generate shell completion scripts'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and not __fish_seen_subcommand_from video image batch presets info completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and __fish_seen_subcommand_from presets" -f -a "list" -d 'List all available presets'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and __fish_seen_subcommand_from presets" -f -a "show" -d 'Show details of a specific preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and __fish_seen_subcommand_from presets" -f -a "create" -d 'Create a custom preset'
complete -c compresscli -n "__fish_compresscli_using_subcommand help; and __fish_seen_subcommand_from presets" -f -a "delete" -d 'Delete a custom preset'
