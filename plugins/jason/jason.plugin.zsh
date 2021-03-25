export CLICOLOR=1
export EDITOR="emacsclient -t"
#export LSCOLORS=GxFxCxDxBxegedabagaced
#export PAGER=less
#export LESS="-iMSx4 -FX"

#alias e='emacsclient -t'
alias ec='emacsclient -c'
alias vim='emacsclient -t'
alias vi='emacsclient -t'


# enable color support of ls
if [[ -x $(which /usr/bin/dircolors) ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi


######################
#### COMPLETION   ####
######################

fpath=(/usr/local/share/zsh-completions $fpath)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' completer _complete _ignored
autoload -Uz compinit
unsetopt automenu # Don't fill the first option when autocompleting twice
compinit


###################
#### HISTORY   ####
###################

setopt SHARE_HISTORY
HISTSIZE=10000000
if (( ! EUID )); then
  HISTFILE=~/.history_root
else
  HISTFILE=~/.history
fi
SAVEHIST=10000000


#################
#### EMACS   ####
##################

# Open a new frame (by default) to edit a file in the appropriate emacs server,
# starting that emacs first if appropriate.
function edit() {
  SERVER=$(client || echo -n server)
  SERVER_FILE="/tmp/emacs${UID}/$SERVER"
  if [[ ! -e "$SERVER_FILE" ]]; then
    if client > /dev/null; then
      pushd / > /dev/null # change to the google3 directory of this client
    else
      pushd . > /dev/null
    fi
    emacs --daemon
    popd > /dev/null
    while [[ ! -e "$SERVER_FILE" ]]; do sleep 1; done
  fi

  emacsclient -s "$SERVER" "$@"
}
# Open a file in the current frame of an emacs, starting it first if necessary.
function editin() {
  edit -c "$@"
}

#######################
#### SUDO Touchbar ####
#######################
sudo() {
  unset -f sudo
  if [[ "$(uname)" == 'Darwin' ]] && ! grep 'pam_tid.so' /etc/pam.d/sudo --silent; then
  sudo /usr/bin/sed -i -e '1s;^;auth       sufficient     pam_tid.so\;' /etc/pam.d/sudo
  fi
  sudo "$@"
}


########################
#### KEY BINDINGS   ####
########################

bindkey '^R' history-incremental-search-backward
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
bindkey "^[[1;5D" emacs-backward-word
bindkey "^[[1;5C" emacs-forward-word
bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

# Attempt to fix tmux tab names
DISABLE_AUTO_TITLE=true

settitle() {
    if [ -z TMUX ]; then
        tmux rename-window "$*"
    else
        echo "\e]1;$*\e\\"
    fi
}


# load rvm when there is a Gemfile present
load-rvm() {
  [[ -a Gemfile ]] || return # if the directoy doesn't have an Gemfile, return early
  LC_ALL=C type rvm > /dev/null || (echo "loading rvm..." && source /etc/profile.d/rvm.sh)
}


# autoload -U add-zsh-hook
# add-zsh-hook chpwd load-rvm


##################
#### ALIASES   ####
###################
alias e='subl'
alias ec='subl -w'
alias fastcop='git diff --name-only HEAD | xargs rubocop -a'
alias fr='foreman run -f ~/src/clocktower/Procfile -e /Users/jason/src/clocktower/development.env'
alias frc='fr spring rails console'
alias frs='fr spring rspec'
alias fs='foreman start -f ~/src/clocktower/Procfile -e /Users/jason/src/clocktower/development.env'
alias gg='git grep -n --color=always'
alias ggi='git grep -ni --color=always'
alias gs='git status'
alias kc="~/src/clocktower/scripts/kube/kubectl"
alias kc\!="~/src/clocktower/scripts/kube/kubectl!"
alias la='ls -a'
alias ll='ls -l'
alias ls='ls --color=auto'
alias psql='psql -eL /tmp/psql.log'
alias glc='golangci-lint run \
          --no-config \
          --presets bugs,format,style,unused \
          --out-format=tab \
          -D goimports \
          -D lll \
          -D megacheck \
          -D gofmt \
          -D golint \
          -D typecheck'
