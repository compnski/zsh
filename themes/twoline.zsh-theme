
######################
#### BEGIN PROMPT ####
######################

function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
    ###
    # Truncate the path if it's too long.

    PR_FILLBAR=""
    PR_PWDLEN=""

    local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    local pwdsize=${#${(%):-%~}}

    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
      ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
  PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi
}


setopt extended_glob

# function preexec {
#   local fg_title
#   if [[ $* == fg* ]]; then
#      if [[ $* == *%* ]]; then
#         fg_title=($(jobs ${${(z)1}[2]}))
#      else
#         fg_title=($(jobs %%))
#      fi
#      settitle "${fg_title[5,-1]}"
#   else
#      settitle $*
#   fi
# }

setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst


    ###
    # See if we can use colors.

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
  colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
  eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
  eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
  (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    ###
    # See if we can use extended characters to look nicer.

    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}


    ###
    # Decide if we need to set titlebar text.

    case $TERM in
  xterm*)
      PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | %y\a%}'
      ;;
  screen)
      PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | %y\e\\%}'
      ;;
  *)
      PR_TITLEBAR=''
      ;;
    esac


    ###
    # Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
  PR_STITLE=$'%{\ekzsh\e\\%}'
    else
  PR_STITLE=''
    fi

  if [[ -n "$SSH_TTY" ]]; then
    PR_BARCOLOR="%(!.$PR_RED.$PR_MAGENTA)"
    PR_HOST="$PR_MAGENTA%S%m%s"
  elif [[ "$TERM" == "screen" ]]; then
    PR_BARCOLOR="%(!.$PR_RED.$PR_CYAN)"
    PR_HOST="$PR_CYAN%S%m%s"
  else
    PR_BARCOLOR="%(!.$PR_RED.$PR_GREEN)"
    PR_HOST="$PR_GREEN%m"
  fi
    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_BARCOLOR$PR_SHIFT_IN$PR_ULCORNER$PR_BARCOLOR$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.$PR_RED%SROOT%s.%n)$PR_GREEN@$PR_HOST$PR_GREEN:\
$PR_BLUE%$PR_PWDLEN<...<%~%<<\
$PR_BARCOLOR)$PR_SHIFT_IN$PR_HBAR$PR_BARCOLOR$PR_HBAR${(e)PR_FILLBAR}$PR_BARCOLOR$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%l\
$PR_BARCOLOR)$PR_SHIFT_IN$PR_HBAR$PR_BARCOLOR$PR_URCORNER$PR_SHIFT_OUT\

$PR_BARCOLOR$PR_SHIFT_IN$PR_LLCORNER$PR_BARCOLOR$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_RED%?$PR_YELLOW:)$PR_YELLOW%!\
$PR_BARCOLOR)\
%(?.$PR_GREEN.$PR_RED)%#\
$PR_NO_COLOUR '

    RPROMPT=' $PR_BARCOLOR$PR_SHIFT_IN$PR_BARCOLOR$PR_SHIFT_OUT(\
$PR_YELLOW%D{%H:%M:%S}\
$PR_BARCOLOR)$PR_SHIFT_IN$PR_HBAR$PR_BARCOLOR$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_BARCOLOR$PR_SHIFT_IN.$PR_SHIFT_OUT\
$PR_BARCOLOR$PR_SHIFT_IN.$PR_SHIFT_OUT(\
%(?..$PR_RED%?$PR_YELLOW:)$PR_YELLOW%!\
$PR_LIGHT_GREEN%_$PR_BARCOLOR)$PR_SHIFT_IN:$PR_SHIFT_OUT\
$PR_NO_COLOUR '
}

setprompt
