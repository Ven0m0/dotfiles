function fish_greeting
    if command -q hyfetch
        LC_CTYPE=C LC_COLLATE=C hyfetch -m 8bit
    else if command -q fastfetch
        LC_CTYPE=C LC_COLLATE=C fastfetch --thread true --detect-version false --logo-type kitty
    end
end
