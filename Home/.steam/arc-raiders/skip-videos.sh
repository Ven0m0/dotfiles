#!/usr/bin/env bash
# =============================================================================
#  Arc Raiders - Skip Videos Mod (Linux port)
#  Original mod by TinyStormCloud
#  Linux conversion: adjusted for Steam/Proton on Linux
#  Usage: Run from anywhere - script auto-detects the game install directory
# =============================================================================

# ANSI colors
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
RESET='\033[0m'

# Known quest video filenames (case-sensitive, must match exactly on disk)
QUEST_FILES=(
    "Quest_Intro_A_Bad_Feeling.bk2"
    "QUEST_INTRO_Dormant_Barons.bk2"
    "QUEST_INTRO_Finders_Keepers.bk2"
    "Quest_Intro_Finders_Keepers_V1.bk2"
    "QUEST_INTRO_The_Root_of_the_matter.bk2"
    "QUEST_OUTRO_A bad feeling.bk2"
    "QUEST_OUTRO_Communication_Hideout.bk2"
    "QUEST_OUTRO_Echoes_of_Victory_Ridge.bk2"
    "QUEST_OUTRO_Into_the_Fray.bk2"
    "QUEST_OUTRO_Switching_the_Supply.bk2"
    "QUEST_OUTRO_SymbolOfUnification.bk2"
)

# ---------------------------------------------------------------------------
# Locate the Arc Raiders install directory
# ---------------------------------------------------------------------------
find_game_dir() {
    local candidates=(
        "$HOME/.local/share/Steam/steamapps/common/Arc Raiders"
        "$HOME/.steam/steam/steamapps/common/Arc Raiders"
        "/opt/steam/steamapps/common/Arc Raiders"
        "/usr/local/steam/steamapps/common/Arc Raiders"
    )

    # Also parse Steam libraryfolders.vdf for non-default library locations
    local vdf="$HOME/.local/share/Steam/config/libraryfolders.vdf"
    if [[ -f "$vdf" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ \"path\"[[:space:]]+\"([^\"]+)\" ]]; then
                candidates+=("${BASH_REMATCH[1]}/steamapps/common/Arc Raiders")
            fi
        done < "$vdf"
    fi

    for dir in "${candidates[@]}"; do
        if [[ -d "$dir/PioneerGame" ]]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

GAME_DIR=""

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
press_any_key() {
    echo ""
    read -n 1 -s -r -p "   Press any key to continue..."
    echo ""
}

print_header() {
    echo ""
    echo "   +===============================================================+"
    echo -e "   | ${CYAN})${GREEN}\\\\${YELLOW}\\\\${RED}\\\\${RESET} ARC RAIDERS - SKIP VIDEOS MOD by TinyStormCloud        |"
    echo "   +===============================================================+"
}

print_divider() {
    echo "   +===============================================================+"
}

# ---------------------------------------------------------------------------
skip_intro() {
    clear
    echo ""
    print_divider
    echo -e "   | ${CYAN})${GREEN}\\\\${YELLOW}\\\\${RED}\\\\${RESET} APPLYING SKIP INTRO VIDEO MOD                          |"
    print_divider
    echo ""

    local target_dir="$GAME_DIR/PioneerGame/Content/Movies/FTUE"
    local target_file="$target_dir/GAME_INTRO_SPERANZA_DESCEND_V5.bk2"

    if [[ ! -d "$target_dir" ]]; then
        echo -e "   ${RED}[X]${RESET} Directory not found: Movies/FTUE"
        echo ""
        echo "       Verify your game installation."
        print_divider
        press_any_key
        return
    fi
    echo -e "   ${GREEN}[v]${RESET} Found directory"

    if [[ ! -f "$target_file" ]]; then
        echo -e "   ${YELLOW}[!]${RESET} Already applied (file not present)"
        print_divider
        press_any_key
        return
    fi
    echo -e "   ${GREEN}[v]${RESET} Found file"

    rm -f "$target_file" 2>/dev/null
    if [[ ! -f "$target_file" ]]; then
        echo -e "   ${GREEN}[v]${RESET} Successfully applied"
    else
        echo -e "   ${RED}[X]${RESET} Failed to delete file"
        echo "       The file may be in use. Close the game and try again."
    fi

    echo ""
    print_divider
    press_any_key
}

# ---------------------------------------------------------------------------
skip_match() {
    clear
    echo ""
    print_divider
    echo -e "   | ${CYAN})${GREEN}\\\\${YELLOW}\\\\${RED}\\\\${RESET} APPLYING SKIP MATCH VIDEO MOD                          |"
    print_divider
    echo ""

    local target_dir="$GAME_DIR/PioneerGame/Content/Movies/Frontend"
    local target_file="$target_dir/LaunchSequence_ToBlack_4k.bk2"

    if [[ ! -d "$target_dir" ]]; then
        echo -e "   ${RED}[X]${RESET} Directory not found: Movies/Frontend"
        echo ""
        echo "       Verify your game installation."
        print_divider
        press_any_key
        return
    fi
    echo -e "   ${GREEN}[v]${RESET} Found directory"

    if [[ ! -f "$target_file" ]]; then
        echo -e "   ${YELLOW}[!]${RESET} Already applied (file not present)"
        print_divider
        press_any_key
        return
    fi
    echo -e "   ${GREEN}[v]${RESET} Found file"

    rm -f "$target_file" 2>/dev/null
    if [[ ! -f "$target_file" ]]; then
        echo -e "   ${GREEN}[v]${RESET} Successfully applied"
    else
        echo -e "   ${RED}[X]${RESET} Failed to delete file"
        echo "       The file may be in use. Close the game and try again."
    fi

    echo ""
    print_divider
    press_any_key
}

# ---------------------------------------------------------------------------
skip_quest() {
    clear
    echo ""
    print_divider
    echo -e "   | ${YELLOW}[!]${RESET} WARNING                                                 |"
    print_divider
    echo ""
    echo "       This mod is intended for players who have finished their"
    echo "       first playthrough and have done the expedition, and"
    echo "       don't want to rewatch quest videos."
    echo ""
    print_divider
    echo ""

    local confirm
    while true; do
        read -r -p "   Do you want to continue? (y/n): " confirm
        case "${confirm,,}" in
            y) break ;;
            n) return ;;
            *) echo -e "   ${RED}[X]${RESET} Invalid input. Please enter y or n." ;;
        esac
    done

    clear
    echo ""
    print_divider
    echo -e "   | ${CYAN})${GREEN}\\\\${YELLOW}\\\\${RED}\\\\${RESET} APPLYING SKIP QUEST VIDEOS MOD                         |"
    print_divider
    echo ""

    local target_dir="$GAME_DIR/PioneerGame/Content/Movies/Quests"

    if [[ ! -d "$target_dir" ]]; then
        echo -e "   ${RED}[X]${RESET} Directory not found: Movies/Quests"
        echo ""
        echo "       Verify your game installation or run Troubleshoot."
        print_divider
        press_any_key
        return
    fi
    echo -e "   ${GREEN}[v]${RESET} Found directory"

    local files_found=0
    for f in "${QUEST_FILES[@]}"; do
        [[ -f "$target_dir/$f" ]] && (( files_found++ ))
    done

    if (( files_found == 0 )); then
        echo -e "   ${YELLOW}[!]${RESET} Already applied (no files present)"
        print_divider
        press_any_key
        return
    fi
    echo -e "   ${GREEN}[v]${RESET} Found $files_found of ${#QUEST_FILES[@]} files"

    local files_deleted=0
    for f in "${QUEST_FILES[@]}"; do
        if [[ -f "$target_dir/$f" ]]; then
            rm -f "$target_dir/$f" 2>/dev/null
            [[ ! -f "$target_dir/$f" ]] && (( files_deleted++ ))
        fi
    done

    if (( files_deleted == files_found )); then
        echo -e "   ${GREEN}[v]${RESET} Successfully applied ($files_deleted files removed)"
    else
        echo -e "   ${RED}[X]${RESET} Partial failure: removed $files_deleted of $files_found files"
        echo "       The remaining files may be in use. Close the game and try again."
    fi

    echo ""
    print_divider
    press_any_key
}

# ---------------------------------------------------------------------------
apply_all() {
    clear
    echo ""
    print_divider
    echo -e "   | ${YELLOW}[!]${RESET} WARNING                                                 |"
    print_divider
    echo ""
    echo "       This will apply all mods. Skip Quest Videos is intended"
    echo "       for players who have finished their first playthrough and"
    echo "       have done their expedition."
    echo ""
    print_divider
    echo ""

    local confirm
    while true; do
        read -r -p "   Do you want to continue? (y/n): " confirm
        case "${confirm,,}" in
            y) break ;;
            n) return ;;
            *) echo -e "   ${RED}[X]${RESET} Invalid input. Please enter y or n." ;;
        esac
    done

    clear
    echo ""
    print_divider
    echo -e "   | ${CYAN})${GREEN}\\\\${YELLOW}\\\\${RED}\\\\${RESET} APPLYING ALL MODS                                      |"
    print_divider
    echo ""

    # --- Intro ---
    local intro_file="$GAME_DIR/PioneerGame/Content/Movies/FTUE/GAME_INTRO_SPERANZA_DESCEND_V5.bk2"
    if [[ ! -d "$GAME_DIR/PioneerGame/Content/Movies/FTUE" ]]; then
        echo -e "   ${RED}[X]${RESET} Skip Intro Video - Directory not found"
    elif [[ ! -f "$intro_file" ]]; then
        echo -e "   ${YELLOW}[!]${RESET} Skip Intro Video - Already applied"
    else
        rm -f "$intro_file" 2>/dev/null
        if [[ ! -f "$intro_file" ]]; then
            echo -e "   ${GREEN}[v]${RESET} Skip Intro Video - Successfully applied"
        else
            echo -e "   ${RED}[X]${RESET} Skip Intro Video - Failed to apply"
        fi
    fi

    # --- Match ---
    local match_file="$GAME_DIR/PioneerGame/Content/Movies/Frontend/LaunchSequence_ToBlack_4k.bk2"
    if [[ ! -d "$GAME_DIR/PioneerGame/Content/Movies/Frontend" ]]; then
        echo -e "   ${RED}[X]${RESET} Skip Match Video - Directory not found"
    elif [[ ! -f "$match_file" ]]; then
        echo -e "   ${YELLOW}[!]${RESET} Skip Match Video - Already applied"
    else
        rm -f "$match_file" 2>/dev/null
        if [[ ! -f "$match_file" ]]; then
            echo -e "   ${GREEN}[v]${RESET} Skip Match Video - Successfully applied"
        else
            echo -e "   ${RED}[X]${RESET} Skip Match Video - Failed to apply"
        fi
    fi

    # --- Quest ---
    local quest_dir="$GAME_DIR/PioneerGame/Content/Movies/Quests"
    if [[ ! -d "$quest_dir" ]]; then
        echo -e "   ${RED}[X]${RESET} Skip Quest Videos - Directory not found"
    else
        local files_found=0 files_deleted=0
        for f in "${QUEST_FILES[@]}"; do
            [[ -f "$quest_dir/$f" ]] && (( files_found++ ))
        done

        if (( files_found == 0 )); then
            echo -e "   ${YELLOW}[!]${RESET} Skip Quest Videos - Already applied"
        else
            for f in "${QUEST_FILES[@]}"; do
                if [[ -f "$quest_dir/$f" ]]; then
                    rm -f "$quest_dir/$f" 2>/dev/null
                    [[ ! -f "$quest_dir/$f" ]] && (( files_deleted++ ))
                fi
            done
            if (( files_deleted == files_found )); then
                echo -e "   ${GREEN}[v]${RESET} Skip Quest Videos - Successfully applied ($files_deleted files)"
            else
                echo -e "   ${RED}[X]${RESET} Skip Quest Videos - Partial failure ($files_deleted/$files_found)"
            fi
        fi
    fi

    echo ""
    print_divider
    press_any_key
}

# ---------------------------------------------------------------------------
troubleshoot() {
    clear
    echo ""
    print_divider
    echo "   | DIAGNOSTICS                                                 |"
    print_divider
    echo ""

    # Check 1: Game directory found
    if [[ -n "$GAME_DIR" ]]; then
        echo -e "   ${GREEN}[v]${RESET} Game directory found:"
        echo "       $GAME_DIR"
    else
        echo -e "   ${RED}[X]${RESET} Game directory NOT found"
        echo "       Could not locate 'Arc Raiders' in any Steam library."
    fi
    echo ""

    # Check 2: Movies subdirectories
    local movies_path="$GAME_DIR/PioneerGame/Content/Movies"
    if [[ -d "$movies_path" ]]; then
        echo -e "   ${GREEN}[v]${RESET} Found PioneerGame/Content/Movies"
    else
        echo -e "   ${RED}[X]${RESET} Missing PioneerGame/Content/Movies"
    fi

    for subdir in FTUE Frontend Quests; do
        if [[ -d "$movies_path/$subdir" ]]; then
            echo -e "   ${GREEN}[v]${RESET} Found Movies/$subdir"
        else
            echo -e "   ${RED}[X]${RESET} Missing Movies/$subdir"
        fi
    done
    echo ""

    # Check 3: Write permissions
    if [[ -d "$movies_path" ]]; then
        local test_file="$movies_path/_write_test.tmp"
        if touch "$test_file" 2>/dev/null; then
            rm -f "$test_file"
            echo -e "   ${GREEN}[v]${RESET} Write permissions OK"
        else
            echo -e "   ${RED}[X]${RESET} No write permissions on Movies directory"
        fi
    else
        echo -e "   ${RED}[X]${RESET} Cannot check write permissions - path missing"
    fi
    echo ""

    # Check 4: Current video file status
    echo "   Current mod status:"
    local intro="$GAME_DIR/PioneerGame/Content/Movies/FTUE/GAME_INTRO_SPERANZA_DESCEND_V5.bk2"
    local match="$GAME_DIR/PioneerGame/Content/Movies/Frontend/LaunchSequence_ToBlack_4k.bk2"
    if [[ -f "$intro" ]]; then
        echo -e "   ${YELLOW}[!]${RESET} Intro video: NOT applied (file exists)"
    else
        echo -e "   ${GREEN}[v]${RESET} Intro video: Applied (file removed)"
    fi
    if [[ -f "$match" ]]; then
        echo -e "   ${YELLOW}[!]${RESET} Match video: NOT applied (file exists)"
    else
        echo -e "   ${GREEN}[v]${RESET} Match video: Applied (file removed)"
    fi

    local quest_dir="$GAME_DIR/PioneerGame/Content/Movies/Quests"
    local quest_remaining=0
    for f in "${QUEST_FILES[@]}"; do
        [[ -f "$quest_dir/$f" ]] && (( quest_remaining++ ))
    done
    if (( quest_remaining == 0 )); then
        echo -e "   ${GREEN}[v]${RESET} Quest videos: Applied (all files removed)"
    else
        echo -e "   ${YELLOW}[!]${RESET} Quest videos: NOT applied ($quest_remaining files remain)"
    fi

    echo ""
    print_divider
    echo "   | NOTES                                                       |"
    print_divider
    echo "   |                                                             |"
    echo "   |  Game path is auto-detected from your Steam libraries.     |"
    echo "   |  If detection fails, set GAME_DIR manually at the top      |"
    echo "   |  of this script.                                            |"
    echo "   |                                                             |"
    echo "   |  If delete fails, make sure Arc Raiders is not running.    |"
    echo "   |  Steam game files are owned by your user - no sudo needed. |"
    echo "   |                                                             |"
    print_divider
    echo ""
    press_any_key
}

# ---------------------------------------------------------------------------
show_menu() {
    clear
    print_header
    echo "   |                                                               |"
    echo "   |   1. Skip Intro Video                                         |"
    echo "   |   2. Skip Match Video                                         |"
    echo "   |   3. Skip Quest Videos                                        |"
    echo "   |   4. Apply all                                                |"
    echo "   |                                                               |"
    echo "   |   5. Troubleshoot                                             |"
    echo "   |                                                               |"
    echo "   |   0. Exit                                                     |"
    echo "   |                                                               |"
    print_divider
    echo "   |                                                      v1.15.0  |"
    print_divider
    if [[ -n "$GAME_DIR" ]]; then
        echo -e "   ${GREEN}[v]${RESET} Game dir: $GAME_DIR"
    else
        echo -e "   ${RED}[X]${RESET} Game directory not found - run Troubleshoot (5)"
    fi
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
GAME_DIR="$(find_game_dir)"

while true; do
    show_menu
    read -r -p "   Select an option: " choice

    # Reject multi-character input
    if [[ ${#choice} -gt 1 ]]; then
        echo -e "   ${RED}[X]${RESET} Invalid option. Please try again."
        sleep 1
        continue
    fi

    case "$choice" in
        1) skip_intro ;;
        2) skip_match ;;
        3) skip_quest ;;
        4) apply_all ;;
        5) troubleshoot ;;
        0) echo ""; echo "   See you in Speranza, Raider."; echo ""; exit 0 ;;
        *) echo -e "   ${RED}[X]${RESET} Invalid option. Please try again."; sleep 1 ;;
    esac
done
