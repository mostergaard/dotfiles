#!/usr/bin/env bash
# git-overview.sh - report uncommitted/unpushed work across all git checkouts below a folder,
# and optionally delete local branches that are already merged on the remote.
#
# Portable: Bash 3.2+ (macOS default, Git Bash on Windows). Needs only git + coreutils.
#
# Usage: git-overview.sh [options] [root-dir]
#
#   root-dir            Folder to scan (default: the current directory)
#   -d, --depth N       How many levels deep to look for repos (default: 2)
#   -n, --no-fetch      Skip 'git fetch --prune' (faster, but ahead/behind info is only as fresh as the last fetch)
#   -a, --all           Show every repo, including clean ones (default: only repos needing attention)
#   -c, --clean         Clean mode: list local branches that are merged into the remote default branch.
#                       If the checked-out branch qualifies and the working tree is clean, the default
#                       branch is checked out first so it can be deleted too.
#       --gone          In clean mode, also include branches whose upstream branch no longer exists
#                       (typical after a squash merge + remote branch deletion). Requires fetching.
#   -y, --yes           In clean mode, actually delete the branches (default is a dry run)
#   -h, --help          Show this help
#
# Exit status: 0 if every repo is clean, 1 if anything needs attention, 2 on usage error.

set -u

depth=2
do_fetch=1
show_all=0
clean_mode=0
include_gone=0
confirm=0
root=""

usage() { sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--depth) depth="$2"; shift ;;
        -n|--no-fetch) do_fetch=0 ;;
        -a|--all)   show_all=1 ;;
        -c|--clean) clean_mode=1 ;;
        --gone)     include_gone=1 ;;
        -y|--yes)   confirm=1 ;;
        -h|--help)  usage; exit 0 ;;
        -*)         echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)          root="$1" ;;
    esac
    shift
done

root="${root:-$PWD}"
if [ ! -d "$root" ]; then
    echo "Not a directory: $root" >&2
    exit 2
fi
root="$(cd "$root" && pwd)"

if [ "$include_gone" = 1 ] && [ "$do_fetch" = 0 ]; then
    echo "--gone needs fresh remote info; do not combine it with --no-fetch" >&2
    exit 2
fi

if [ -t 1 ]; then
    RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; CYA=$'\033[36m'; DIM=$'\033[2m'; BOLD=$'\033[1m'; RST=$'\033[0m'
else
    RED=""; YEL=""; GRN=""; CYA=""; DIM=""; BOLD=""; RST=""
fi

problems=0
repos=0

# Remote default branch (e.g. origin/main). Falls back to origin/main or origin/master if origin/HEAD is unset.
default_branch() {
    local ref
    ref="$(git -C "$1" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)"
    if [ -z "$ref" ]; then
        for cand in origin/main origin/master origin/develop; do
            if git -C "$1" show-ref -q --verify "refs/remotes/$cand"; then ref="$cand"; break; fi
        done
    fi
    echo "$ref"
}

report_repo() {
    local dir="$1" name="$2"
    local out="" status detached current

    if [ "$do_fetch" = 1 ]; then
        git -C "$dir" fetch --prune --quiet 2>/dev/null || out="$out  ${YEL}! fetch failed (offline or no access)${RST}"$'\n'
    fi

    current="$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null)"
    if [ -z "$current" ]; then
        detached="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
        out="$out  ${YEL}! detached HEAD at ${detached:-?}${RST}"$'\n'
    fi

    # Working tree: staged / modified / untracked
    status="$(git -C "$dir" status --porcelain 2>/dev/null)"
    if [ -n "$status" ]; then
        local staged modified untracked
        staged=$(printf '%s\n' "$status" | grep -c '^[MADRC]')
        modified=$(printf '%s\n' "$status" | grep -c '^.[MD]')
        untracked=$(printf '%s\n' "$status" | grep -c '^??')
        out="$out  ${RED}* uncommitted changes:${RST} $staged staged, $modified modified, $untracked untracked"$'\n'
    fi

    # Stashes
    local stashes
    stashes="$(git -C "$dir" stash list 2>/dev/null | wc -l | tr -d ' ')"
    if [ "$stashes" -gt 0 ]; then
        out="$out  ${YEL}* $stashes stash(es)${RST}"$'\n'
    fi

    # Branches: no upstream, ahead of upstream, or upstream gone
    local line branch upstream track
    while IFS='|' read -r branch upstream track; do
        [ -z "$branch" ] && continue
        if [ -z "$upstream" ]; then
            out="$out  ${RED}* $branch${RST} has no upstream (never pushed)"$'\n'
        elif [ "$track" = "[gone]" ]; then
            out="$out  ${YEL}* $branch${RST} upstream $upstream is gone"$'\n'
        else
            case "$track" in
                *ahead*) out="$out  ${RED}* $branch${RST} is $track of $upstream"$'\n' ;;
            esac
        fi
    done <<EOT
$(git -C "$dir" for-each-ref --format='%(refname:short)|%(upstream:short)|%(upstream:track)' refs/heads 2>/dev/null)
EOT

    repos=$((repos + 1))
    if [ -n "$out" ]; then
        problems=$((problems + 1))
        printf '%s%s%s %s(%s)%s\n%s' "$BOLD" "$name" "$RST" "$DIM" "${current:-detached}" "$RST" "$out"
    elif [ "$show_all" = 1 ]; then
        printf '%s%s%s %s(%s)%s  %sclean%s\n' "$BOLD" "$name" "$RST" "$DIM" "${current:-detached}" "$RST" "$GRN" "$RST"
    fi
}

clean_repo() {
    local dir="$1" name="$2"
    local base current candidates="" reason current_reason="" current_blocked=""

    if [ "$do_fetch" = 1 ]; then
        git -C "$dir" fetch --prune --quiet 2>/dev/null
        # Make sure origin/HEAD reflects the remote's real default branch instead of a guess
        git -C "$dir" remote set-head origin --auto >/dev/null 2>&1
    fi

    base="$(default_branch "$dir")"
    current="$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null)"
    local base_local="${base#origin/}"

    local branch upstream track
    while IFS='|' read -r branch upstream track; do
        [ -z "$branch" ] && continue
        [ "$branch" = "$base_local" ] && continue
        reason=""
        if [ -n "$base" ] && git -C "$dir" merge-base --is-ancestor "$branch" "$base" 2>/dev/null; then
            reason="merged into $base"
        elif [ "$include_gone" = 1 ] && [ "$track" = "[gone]" ]; then
            reason="upstream $upstream is gone"
        fi
        [ -z "$reason" ] && continue
        if [ "$branch" = "$current" ]; then
            # The checked-out branch can only go if we can safely switch away first
            if [ -z "$base" ]; then
                current_blocked="cannot tell which branch is the default"
            elif [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
                current_blocked="working tree has uncommitted or untracked files"
            else
                current_reason="$reason"
            fi
        else
            candidates="$candidates$branch|$reason"$'\n'
        fi
    done <<EOT
$(git -C "$dir" for-each-ref --format='%(refname:short)|%(upstream:short)|%(upstream:track)' refs/heads 2>/dev/null)
EOT

    repos=$((repos + 1))
    [ -z "$candidates" ] && [ -z "$current_reason" ] && [ -z "$current_blocked" ] && return

    printf '%s%s%s %s(%s)%s\n' "$BOLD" "$name" "$RST" "$DIM" "${current:-detached}" "$RST"

    if [ -n "$current_blocked" ]; then
        printf '  %sskipped%s %s  %s(checked out, %s)%s\n' "$YEL" "$RST" "$current" "$DIM" "$current_blocked" "$RST"
    elif [ -n "$current_reason" ]; then
        problems=$((problems + 1))
        if [ "$confirm" = 1 ]; then
            if git -C "$dir" checkout --quiet "$base_local" >/dev/null 2>&1 && git -C "$dir" branch -D "$current" >/dev/null 2>&1; then
                printf '  %sdeleted%s %s  %s(%s; switched to %s)%s\n' "$GRN" "$RST" "$current" "$DIM" "$current_reason" "$base_local" "$RST"
            else
                printf '  %sfailed%s  %s  %s(%s; could not switch to %s)%s\n' "$RED" "$RST" "$current" "$DIM" "$current_reason" "$base_local" "$RST"
            fi
        else
            printf '  %swould delete%s %s  %s(%s; would switch to %s first)%s\n' "$YEL" "$RST" "$current" "$DIM" "$current_reason" "$base_local" "$RST"
        fi
    fi

    while IFS='|' read -r branch reason; do
        [ -z "$branch" ] && continue
        problems=$((problems + 1))
        if [ "$confirm" = 1 ]; then
            if git -C "$dir" branch -D "$branch" >/dev/null 2>&1; then
                printf '  %sdeleted%s %s  %s(%s)%s\n' "$GRN" "$RST" "$branch" "$DIM" "$reason" "$RST"
            else
                printf '  %sfailed%s  %s  %s(%s)%s\n' "$RED" "$RST" "$branch" "$DIM" "$reason" "$RST"
            fi
        else
            printf '  %swould delete%s %s  %s(%s)%s\n' "$YEL" "$RST" "$branch" "$DIM" "$reason" "$RST"
        fi
    done <<EOT
$candidates
EOT
}

printf '%sScanning %s (depth %s)%s\n\n' "$DIM" "$root" "$depth" "$RST"

# .git can be a directory or, for worktrees/submodules, a file. Sort for stable output.
while IFS= read -r gitpath; do
    [ -z "$gitpath" ] && continue
    dir="$(dirname "$gitpath")"
    name="${dir#$root/}"
    [ "$name" = "$dir" ] && name="."
    git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
    if [ "$clean_mode" = 1 ]; then
        clean_repo "$dir" "$name"
    else
        report_repo "$dir" "$name"
    fi
done <<EOT
$(find "$root" -mindepth 2 -maxdepth "$((depth + 1))" -name .git \( -type d -o -type f \) -prune 2>/dev/null | sort)
EOT

echo
if [ "$clean_mode" = 1 ]; then
    if [ "$confirm" = 1 ]; then
        printf '%s%d repos scanned, %d branches deleted.%s\n' "$CYA" "$repos" "$problems" "$RST"
    else
        printf '%s%d repos scanned, %d branches would be deleted. Re-run with --yes to delete them.%s\n' "$CYA" "$repos" "$problems" "$RST"
    fi
    exit 0
fi

if [ "$problems" -eq 0 ]; then
    printf '%s%d repos scanned, all clean.%s\n' "$GRN" "$repos" "$RST"
    exit 0
fi
printf '%s%d repos scanned, %d need attention.%s\n' "$YEL" "$repos" "$problems" "$RST"
[ "$do_fetch" = 0 ] && printf '%s(Run without --no-fetch for an up-to-date view against the remotes.)%s\n' "$DIM" "$RST"
exit 1
