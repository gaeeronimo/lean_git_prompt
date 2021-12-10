# Simple powerline prompt for bash, optimized for speed even under Windows 
# Licensed under MIT

export PROMPT_COMMAND="__simple_set_prompt"

# Configuration
PS1_SHOW_LONG_CWD=
PS1_SHOW_DIRTYSTATE=
PS1_SHOW_UPSTREAM=1

PS1_SEGMENT_CHAR=""
PS1_PROMPT_CHAR=""
PS1_GIT_CHAR=""

PS1_USERINFO_COLOR="B W"
PS1_SYSTEM_COLOR="M Bl"
PS1_VENV_COLOR="C Bl"
PS1_CWD_COLOR="Y Bl"
PS1_GIT_DEFAULT_COLOR="B Bl"
PS1_GIT_CLEAN_COLOR="G Bl"
PS1_GIT_DIRTY_COLOR="R Bl"

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
    PS1="$PS1\[\e[0;${c_bg};${c_last}m\]${PS1_SEGMENT_CHAR}"
  fi

  # Set color and add text to PS1
  PS1="$PS1\[\e[0;${c_bg};${c_fg}m\]$txt"
  last_segment=$bg
}

function __simple_set_prompt {

    # Save exit code - must be first statement
    local ex=$?

    # Get information about our GIT branch
    local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    [[ "$git_branch" == "HEAD" ]] && git_branch=$(git rev-parse --short HEAD 2>/dev/null)

    # Save last segment color 
    local last_segment=''


    # Set terminal title
    PS1="\[\033]0;${TITLEPREFIX}:\w\007\]\n"

    # Exit code
    [[ "$ex" != 0 ]] &&
      __pl_seg R Bl "$ex " || __pl_seg G Bl "✓ "
    
    # User information when not local
    [[ -n "${SSH_CLIENT}" ]] &&
       __pl_seg ${PS1_USERINFO_COLOR} " \u@\h "

    # Show $MSYSTEM when not default
    [[ -n "${MSYSTEM}" ]] &&
    [[ "${MSYSTEM}" != "MINGW64" ]] &&
      __pl_seg ${PS1_SYSTEM_COLOR} " ${MSYSTEM} "
    
    # Python virtual environment
    [[ -n "${VIRTUAL_ENV_PROMPT}" ]] &&
      __pl_seg ${PS1_VENV_COLOR} " ${VIRTUAL_ENV_PROMPT} "
    
    # Current working directory
    [[ -n "${PS1_SHOW_LONG_CWD}" ]] &&
      __pl_seg ${PS1_CWD_COLOR} " \w " || __pl_seg ${PS1_CWD_COLOR} " `__abbrev_cwd` "
    
    # GIT information
    if [[ -n "$git_branch" ]]; then
        local color="${PS1_GIT_DEFAULT_COLOR}"
        if [[ -n "$PS1_SHOW_DIRTYSTATE" ]]; then
            git diff --quiet && color=${PS1_GIT_CLEAN_COLOR} || color=${PS1_DIRTY_COLOR}
        fi
        local git_info=" ${PS1_GIT_CHAR} $git_branch"
        if [[ -n "${PS1_SHOW_UPSTREAM}" ]]; then
          local upstream_branch=$(git rev-parse --abbrev-ref "@{upstream}" 2> /dev/null)
          [[ -n "$upstream_branch" ]] && git_info="$git_info ➦ $upstream_branch"
        fi
        __pl_seg $color "$git_info"
    fi

    # Finally the prompt
    __pl_seg _ _  " \n${PS1_PROMPT_CHAR} "
}

function __abbrev_cwd {
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