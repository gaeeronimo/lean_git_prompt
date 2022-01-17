# Simple powerline prompt for bash, optimized for speed even under Windows
# Licensed under MIT

export PROMPT_COMMAND="__lean_ps1"

# Configuration
LEAN_PS1_VENV_SHOWNAME=
LEAN_PS1_SHORTEN_CWD=1
LEAN_PS1_GIT_PS1=
[[ "$OSTYPE" == *linux* ]] && GIT_PS1_SHOWDIRTYSTATE=1 || GIT_PS1_SHOWDIRTYSTATE=
GIT_PS1_SHOWUPSTREAM=1
[[ "$OSTYPE" == *linux* ]] && GIT_PS1_SHOWUPSTREAMSTATE=1 || GIT_PS1_SHOWUPSTREAMSTATE=

[[ "$OSTYPE" == *linux* ]] && [[ "$XDG_SESSION_TYPE" = *tty* ]] && LEAN_PS1_TTY_MODE=1

[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_OKAY_CHAR="✓" || LEAN_PS1_OKAY_CHAR="0"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_SEGMENT_CHAR="" || LEAN_PS1_SEGMENT_CHAR=""
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_PROMPT_CHAR="" || LEAN_PS1_PROMPT_CHAR="$"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_PY_CHAR="🐍" || LEAN_PS1_PY_CHAR="~~*"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_CHAR="" || LEAN_PS1_GIT_CHAR="git:"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_UPSTREAM_CHAR="➦" || LEAN_PS1_GIT_UPSTREAM_CHAR="->"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_DIRTY_CHAR="≠" || LEAN_PS1_GIT_DIRTY_CHAR="*"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_STAGED_CHAR="±" || LEAN_PS1_GIT_STAGED_CHAR="±"

[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_AHEAD_CHAR="↑" || LEAN_PS1_GIT_AHEAD_CHAR="^"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_BEHIND_CHAR="↓" || LEAN_PS1_GIT_BEHIND_CHAR="v"

[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_OKAY_COLOR="G Bl" || LEAN_PS1_OKAY_COLOR="Bl G"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_ERROR_COLOR="R Bl" || LEAN_PS1_ERROR_COLOR="Bl R"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_USERINFO_COLOR="B W" || LEAN_PS1_USERINFO_COLOR="Bl B"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_SYSTEM_COLOR="M Bl" || LEAN_PS1_SYSTEM_COLOR="Bl M"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_VENV_COLOR="Bl W" || LEAN_PS1_VENV_COLOR="Bl W"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_CWD_COLOR="B Bl" || LEAN_PS1_CWD_COLOR="Bl W"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_DEFAULT_COLOR="C Bl" || LEAN_PS1_GIT_DEFAULT_COLOR="Bl C"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_CLEAN_COLOR="G Bl" || LEAN_PS1_GIT_CLEAN_COLOR="Bl G"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_DIRTY_COLOR="R Bl" || LEAN_PS1_GIT_DIRTY_COLOR="Bl R"
[[ -z $LEAN_PS1_TTY_MODE ]] && LEAN_PS1_GIT_STAGED_COLOR="Y Bl" || LEAN_PS1_GIT_STAGED_COLOR="Bl Y"

# Declare colormaps for background and foreground colors
declare -A COLMAP_BG=( [Bl]=40 [R]=41 [G]=42 [Y]=43 [B]=44 [M]=45 [C]=46 [W]=47 [_]=49 )
declare -A COLMAP_FG=( [Bl]=30 [R]=31 [G]=32 [Y]=33 [B]=34 [M]=35 [C]=36 [W]=37 [_]=39 )

function __pl_seg {

  # usage: __pl_seg <bg> <fg> <text>
  local bg="$1"
  local fg="$2"
  local txt="$3"

  # Get color codes
  local c_bg=${COLMAP_BG[$bg]}
  local c_fg=${COLMAP_FG[$fg]}

  # Saved color, start new segment with SEGMENT_CHAR, use old BG as FG
  if [[ -n "${last_segment}" ]]; then
    local c_last=${COLMAP_FG[$last_segment]}
    PS1="$PS1\[\e[0;${c_bg};${c_last}m\]${LEAN_PS1_SEGMENT_CHAR}"
  fi

  # Set color and add text to PS1
  PS1="$PS1\[\e[0;${c_bg};${c_fg}m\]$txt"
  last_segment=$bg
}

function __lean_ps1 {

    # Save exit code - must be first statement
    local ex=$?

    # Save last segment color
    local last_segment=''

    # Set terminal title
    PS1="\[\033]0;${TITLEPREFIX}:\w\007\]\n"

    # Exit code
    [[ "$ex" != 0 ]] &&
      __pl_seg $LEAN_PS1_ERROR_COLOR "$ex " || __pl_seg $LEAN_PS1_OKAY_COLOR "${LEAN_PS1_OKAY_CHAR} "

    # User information when not local
    [[ -n "${SSH_CLIENT}" ]] &&
       __pl_seg ${LEAN_PS1_USERINFO_COLOR} " \u@\h "

    # Show $MSYSTEM when not default
    [[ -n "${MSYSTEM}" ]] &&
    [[ "${MSYSTEM}" != "MINGW64" ]] &&
      __pl_seg ${LEAN_PS1_SYSTEM_COLOR} " ${MSYSTEM} "

    # Python virtual environment
    local venv_prompt="${VIRTUAL_ENV_PROMPT}"
    [[ -z "${venv_prompt}" ]] && [[ -n "${VIRTUAL_ENV}" ]] && venv_prompt=`basename "${VIRTUAL_ENV}"`
    if [[ -n "${venv_prompt}" ]]; then
      [[ -n "${LEAN_PS1_VENV_SHOWNAME}" ]] && 
        __pl_seg ${LEAN_PS1_VENV_COLOR} " ${LEAN_PS1_PY_CHAR} ${venv_prompt} " ||
        __pl_seg ${LEAN_PS1_VENV_COLOR} " ${LEAN_PS1_PY_CHAR} "
    fi

    # Current working directory
    [[ -n "${LEAN_PS1_SHORTEN_CWD}" ]] &&
      __pl_seg ${LEAN_PS1_CWD_COLOR} " `__abbrev_cwd` " || __pl_seg ${LEAN_PS1_CWD_COLOR} " \w "

    # GIT information
    readarray -t git_info <<< `git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --abbrev-ref HEAD 2> /dev/null`

    local git_dir="${git_info[0]}"
    local git_inside_gd="${git_info[1]}"
    local git_bare="${git_info[2]}"
    local git_inside_wt="${git_info[3]}"
    local git_branch="${git_info[4]}"

	  if [[ -n "$LEAN_PS1_GIT_PS1" ]]; then

        # Use configured use of default __git_ps1 prompt
			  __pl_seg $LEAN_PS1_GIT_DEFAULT_COLOR "$(__git_ps1)"

	  elif [[ "$git_inside_gd" == "true" ]]; then

        # GIT, but not inside worktree => Let __git_ps1 do the job
			  __pl_seg $LEAN_PS1_GIT_DEFAULT_COLOR "$(__git_ps1)"

	  elif [[ "$git_inside_wt" == "true" ]]; then

      # Rebase or merge in progress, let __git_ps1 display all the details
      if [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" || -f "$g/MERGE_HEAD" || -f "$g/BISECT_LOG"  ]]; then
			  __pl_seg $LEAN_PS1_GIT_DEFAULT_COLOR "$(__git_ps1)"
      else

        # Fast version: display branch, dirtystate and upstream branch
        local color="${LEAN_PS1_GIT_DEFAULT_COLOR}"
        local dirty_marker=""
        local staged_marker=""

        if [[ -n "$GIT_PS1_SHOWDIRTYSTATE" ]]; then
            color=${LEAN_PS1_GIT_CLEAN_COLOR}
            if ! git diff --staged --quiet; then
              color=${LEAN_PS1_GIT_STAGED_COLOR}
              staged_marker=" ${LEAN_PS1_GIT_STAGED_CHAR}"
            fi
            if ! git diff --quiet; then
              color=${LEAN_PS1_GIT_DIRTY_COLOR}
              dirty_marker="${LEAN_PS1_GIT_DIRTY_CHAR} "
            fi
        fi

        [[ "$git_branch" == "HEAD" ]] && git_branch=$(git rev-parse --short HEAD 2>/dev/null)
        local git_txt=" ${LEAN_PS1_GIT_CHAR} ${dirty_marker}${git_branch}${staged_marker}"
        if [[ -n "${GIT_PS1_SHOWUPSTREAM}" ]]; then
          local upstream_branch=$(git rev-parse --abbrev-ref "@{upstream}" 2> /dev/null)
          if [[ -n "$upstream_branch" ]]; then
            git_txt="$git_txt ${LEAN_PS1_GIT_UPSTREAM_CHAR} $upstream_branch"
            if [[ -n "$GIT_PS1_SHOWUPSTREAMSTATE" ]]; then
              local ahead=$(git rev-list --left-right ${git_branch}...${upstream_branch} 2> /dev/null | grep -c "^<")
              local behind=$(git rev-list --left-right ${git_branch}...${upstream_branch} 2> /dev/null | grep -c "^>")
              [[ "$ahead" != 0 ]] && git_txt="$git_txt ${LEAN_PS1_GIT_AHEAD_CHAR}${ahead}"
              [[ "$behind" != 0 ]] && git_txt="$git_txt ${LEAN_PS1_GIT_BEHIND_CHAR}${behind}"
            fi
          fi
        fi
        __pl_seg $color "$git_txt"

      fi
    fi

    # Finally the prompt
    __pl_seg _ _  " \n${LEAN_PS1_PROMPT_CHAR} "
}

function __abbrev_cwd {
  # Shorten all parts of CWD to 1 char except the final part
  local dir="\w"
  local dir=${dir@P}
  local IFS="/"
  local prev=''
  [[ "${dir:0:1}" == "/" ]] && echo -n "/"
  for part in $dir; do
    [[ -n "$prev" ]] && echo -n "${prev:0:1}/"
    prev="$part"
  done
  echo "$prev"
}