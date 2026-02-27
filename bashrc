#!/usr/bin/env bash
# bash profiling to analyze use .vim/scripts/bashprofiling.py
# for bash profiling -  www.rosipov.com/blog/profiling-slow-bashrc
# PS4='+ $(date "+%s.%N")\011 '
# exec 3>&2 2>/tmp/bashstart.$$.log
# set -x

# tips
# pbcopy-pbpaste - put thing in/out of the clipboard
# tmux session to system clipboard. local session (pbcopy or xclip or xsel
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

alias anki='/opt/anki-launcher-25.09-linux/anki'

# ------------------------------- test area---------------------------------------------
# Enable history expansion with space
# E.g. Typing !!<space> will replace the !! with your last command
bind Space:magic-space

source "$HOME"/.fonts/*.sh

complete -o default -o nospace -F _man vman

# http://box.matto.nl/turn-capslock-into-control-key-on-a-thinkpad-x270-running-freebsd.html
setxkbmap -model thinkpad -layout us -option caps:ctrl_modifier

# Find File and Edit
function fzf-find-edit() {
    local file=$(
      fzf --no-multi --preview 'bat --color=always --line-range :500 {}'
      )
    if [ -n "$file" ]; then
        $EDITOR "$file"
    fi
}
alias ffe='fzf-find-edit'

# Find File with Term and Edit
function fzf-rg-edit(){
    if [ $# == 0 ]; then
        echo 'Error: search term was not provided.'
        return
    fi
    local match=$(
      rg --color=never --line-number "$1" |
        fzf --no-multi --delimiter : \
            --preview "bat --color=always --line-range {2}: {1}"
      )
    local file=$(echo "$match" | cut -d':' -f1)
    if [ -n "$file" ]; then
        $EDITOR $file +$(echo "$match" | cut -d':' -f2)
    fi
}
alias frge='fzf-rg-edit'

# Find and Kill Process
function fzf-kill() {
    local pids=$(
      ps -f -u $USER | sed 1d | fzf --multi | tr -s [:blank:] | cut -d' ' -f3
      )
    if [ -n "$pids" ]; then
        echo "$pids" | xargs kill -9 "$@"
    fi
}
alias fkill='fzf-kill'

# Git Log Browser
function fzf-git-log() {
    local commits=$(
      git ll --color=always "$@" |
          fzf --ansi --no-sort --height 100% --preview "git show --color=always {2}")
    if [ -n "$commits" ]; then
        local hashes=$(printf "$commits" | cut -d' ' -f2 | tr '\n' ' ')
        git show $hashes
    fi
}

alias fll='fzf-git-log'

function open_with_fzf() {
file="$(fd -t f -H | fzf --preview="head -$LINES {}")"
if [ -n "$file" ]; then
    mimetype="$(xdg-mime query filetype $file)"
    default="$(xdg-mime query default $mimetype)"
    if [[ "$default" == "vim.desktop" ]]; then
        vim "$file"
    else
        &>/dev/null xdg-open "$file" & disown
    fi
fi
}

function cd_with_fzf() {
    cd $HOME && cd "$(fd -t d | fzf --preview="tree -L 1 {}" --bind="space:toggle-preview" --preview-window=:hidden)"
}
bind '"\C-o":"cd_with_fzf\n"'
bind '"\C-f":"open_with_fzf\n"'

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

alias nvim='/home/mp466/Downloads/nvim-linux-x86_64/bin/nvim'

# ------------------------------ ctags -------------------------------------------------
alias f_ctagit="ctags --append=no -f ./.git/tags --recurse --totals --exclude=blib --exclude=.svn --exclude=.git --exclude='*~' --extra=q --languages=Perl --langmap=Perl:+.t"

alias mp3-dl='yt-dlp --audio-quality 1 --extract-audio --audio-format mp3'
alias weather='curl -s wttr.in/Seattle | sed -n "1,17p"'

# Base16 Shell  https://github.com/chriskempson/base16-shell
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# shellcheck source=/home/mp466/.config/base16-shell/base16-default.dark.sh
# shellcheck source=/home/mp466/.config/base16-shell/base16-default.light.sh

# BASE16_SHELL="$HOME/.config/base16-shell/scripts/base16-grayscale-light.sh"
BASE16_SHELL="$HOME/.config/base16-shell/scripts/base16-grayscale-dark.sh"
[ -s "$BASE16_SHELL" ] && . "$BASE16_SHELL"

# ------------------------------- urlportal --------------------------------------------

export RTV_BROWSER=~/.vim/scripts/urlportal.sh

# ------------------------------- bash tools--------------------------------------------
export BROWSER=firefox
export BROWSERCLI=w3m
export EDITOR='vim'
export PAGER='less'
export LESSOPEN='| /home/mp466/.vim/scripts/lesspipe.sh %s'
# set options for less
export LESS='--quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'
# use vim as manpager
# export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""
export MANPAGER="/bin/sh -c \"col -b | vim --noplugin --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""
export MANWIDTH=100

# --------------------- bash_history config --------------------------------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTIGNORE="ls:cd:cl:[bf]g:exit:..:...:la:ll:lla:lls:x:vw"
# This will ignore consecutive duplicate commands.
export HISTCONTROL=ignoredups
# Avoid Duplicates on Exit: To prevent the same command from being saved multiple times, you can set:
export HISTCONTROL=erasedups
export HISTFILESIZE=
export HISTSIZE=
# HISTFILESIZE=100000
# HISTSIZE=500000
# Remove Extra Commands, Erase duplicates across the whole history
# export HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="[%F %T] "
# export HISTTIMEFORMAT="%h %d %H:%M:%S "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
# PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

PROMPT_DIRTRIM=2

#
# hint-
# cfg-
# ----------------------------- cheat config -------------------------------------------
function _cheat_autocomplete {
    sheets=$(cheat -l | cut -d' ' -f1)
    COMPREPLY=()
    if [ "$COMP_CWORD" = 1 ]; then
        COMPREPLY=($(compgen -W "$sheets" -- "$2"))
    fi
}
complete -F _cheat_autocomplete cheat:

export CHEATCOLORS=true
export CHEATPATH=$HOME/.cheat

# curl cheat.sh/*
function _cheatsh_complete_curl() {
    local cur prev opts
    _get_comp_words_by_ref -n : cur

    COMPREPLY=()
    #cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(curl -s cheat.sh/:list | sed s@^@cheat.sh/@)"

    if [[ ${cur} == cheat.sh/* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        __ltrim_colon_completions "$cur"
        return 0
    fi
}
complete -F _cheatsh_complete_curl curl

## pip bash completion start
function _pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip

complete -W "$(echo "$(grep '^ssh ' ~/.bash_eternal_history | sort -u | sed 's/^ssh //')")" ssh

## ssh completion
function _ssh() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    #opts=$(grep '^Host' ~/.ssh/config | grep -v '[?*]' | cut -d ' ' -f 2-)
    opts=$(awk '{print $1}' ~/.ssh/known_hosts)
        opts=$(cat "$HOME/.ssh/known_hosts" | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;)

    COMPREPLY=( $(compgen -W "$opts" -- "${cur}") )
    return 0
}
complete -F _ssh ssh ping dig host telnet nc

# Bang! previous command Hotkeys but only the first nth arguments Alt+1, Alt+2 ...etc
bind '"\e1": "!:0 \n"'
bind '"\e2": "!:0-1 \n"'
bind '"\e3": "!:0-2 \n"'
bind '"\e4": "!:0-3 \n"'
bind '"\e5": "!:0-4 \n"'
bind '"\e`": "!:0- \n"'     # all but the last word

# ----------------------------- shell options -------------------------------------------
# shopt is a shell builtin command to set and unset (remove) various Bash shell options
# To enable (set) option use the following command: shopt -s optionNameHere
# To disable (unset) option use the following command: shopt -u optionNameHere

# save multi line commands as one command
shopt -s cmdhist
# Typing a directory name just by itself will automatically change into that directory.
shopt -s autocd
# minor errors in the spelling of a directory component in a cd corrected
shopt -s cdspell
# minor errors in the spelling of a directory component in a cd corrected
shopt -s dirspell
# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
# Define search path for cd command, activate and define cdable variables
CDPATH=".:~/Downloads"
shopt -s cdable_vars
export dotfiles="$HOME/dotfiles"
# checks that a command found in the hash table exists before trying to execute it
shopt -s checkhash
# check the window size after each command and, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# uses the value of PATH to find the directory containing the file
shopt -s sourcepath
# Bash will not attempt to search the PATH for possible completion on an empty line.
shopt -s no_empty_cmd_completion
# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# append to the history file, don't overwrite it, a failed history substitution,
shopt -s histreedit
# append to history, don't overwrite it
shopt -s histappend
# enable history verification: bang commands (!, !!, !?) print to shell and not executed
# http://superuser.com/a/7416
shopt -s histverify
# Enable the ** globstar recursive pattern in file and directory expansions.
shopt -s extglob
# the pattern ‘**’ used in a filename expansion context will match all files
# For example, ls **/*.txt will list all text files in the current directory hierarchy.
shopt -s globstar

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null   ; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases define LS_COLORS
if [ -x /usr/bin/dircolors ]; then
    # alias ls='ls --color=auto'
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto --group-directories-first'
    # alias dir='dir --color=auto'
    # alias vdir='vdir --color=auto'
    # alias grep='grep --color=auto'
    # alias fgrep='fgrep --color=auto'
    # alias egrep='egrep --color=auto'
fi

# shellcheck source=/home/mp466/.bash_alias
[ -f "$HOME/.bash_alias" ] && . "$HOME/.bash_alias"
# shellcheck source=/home/mp466/.bash_functions
[ -f "$HOME/.bash_functions" ] && . "$HOME/.bash_functions"
# shellcheck source=/home/mp466/.bash_functions_list
[ -f "$HOME/.bash_functions_list" ] && . "$HOME/.bash_functions_list"
# shellcheck source=/home/mp466/.buku/auto-completion/bash/buku-completion.bash
[ -f "$HOME/.buku-completion.bash" ] && . "$HOME/.buku-completion.bash"
# shellcheck source=/home/mp466/.ddgr/auto-completion/bash/ddgr-completion.bash
[ -f "$HOME/.ddgr/auto-completion/bash/ddgr-completion.bash" ] && . "$HOME/.ddgr/auto-completion/bash/ddgr-completion.bash"
# shellcheck source=/usr/share/bash-completion/completions/git
# [ -f "/usr/share/bash-completion/completions/git" ] && . "/usr/share/bash-completion/completions/git"
[ -f "$HOME/.git-completion.bash" ] && . "$HOME/.git-completion.bash"
# shellcheck source=/home/mp466/.rg-completion.bash
[ -f "$HOME/.rg-completion.bash" ] && . "$HOME/.rg-completion.bash"
# shellcheck source=/home/mp466/.git-prompt.sh
[ -f "$HOME/.git-prompt.sh" ] && . "$HOME/.git-prompt.sh"
# shellcheck source=/home/mp466/.googler/auto-completion/bash/googler-completion.bash
[ -f "$HOME/.googler/auto-completion/bash/googler-completion.bash" ] && . "$HOME/.googler/auto-completion/bash/googler-completion.bash"
# shellcheck source=/home/mp466/.googler/auto-completion/googler_at/googler_at
[ -f "$HOME/.googler/auto-completion/googler_at/googler_at" ] && . "$HOME/.googler/auto-completion/googler_at/googler_at"
# shellcheck source=/home/mp466/.pdfgrep/completion/pdfgrep
[ -f "$HOME/.pdfgrep/completion/pdfgrep" ] && . "$HOME/.pdfgrep/completion/pdfgrep"
# shellcheck source=/home/mp466/.vim/scripts/tmux-bash-completion.sh
[ -f "$HOME/.vim/scripts/tmux-bash-completion.sh" ] && . "$HOME/.vim/scripts/tmux-bash-completion.sh"
# shellcheck source=/home/mp466/.vim/scripts/cheat.sh
[ -f "$HOME/.vim/scripts/cheat.sh" ] && . "$HOME/.vim/scripts/cheat.sh"
# shellcheck source=/etc/bash_completion
[ -f /etc/bash_completion ] && . /etc/bash_completion
# shellcheck source=/home/mp466/.autojump/etc/profile.d/autojump.sh
# [ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ] && . "$HOME/.autojump/etc/profile.d/autojump.sh"
# Marker installed lets you bookmark commands
# shellcheck source=/home/mp466/.local/share/marker/marker.sh
# [[ -s "$HOME/.local/share/marker/marker.sh" ]] && . "$HOME/.local/share/marker/marker.sh"
# shellcheck source=/home/mp466/.tig/contrib/tig-completion.bash
[ -f "$HOME/.tig/contrib/tig-completion.bash" ] && . "$HOME/.tig/contrib/tig-completion.bash"
# shellcheck source=/home/mp466/.pyenv/completion/pyenv.bash
[ -f "$HOME/.pyenv/completion/pyenv.bash" ] && . "$HOME/.pyenv/completion/pyenv.bash"
# shellcheck source=/home/mp466/.lynis/extras/bash_completion.d/lynis
[ -f "/home/mp466/.lynis/extras/bash_completion.d/lynis" ] && . "/home/mp466/.lynis/extras/bash_completion.d/lynis"
# shellcheck source=/home/mp466/.vim/scripts/poetry
[ -f "$HOME/.vim/scripts/poetry.bash-completion" ] && . "$HOME/.vim/scripts/poetry.bash-completion"
# shellcheck source=/home/mp466/.fzf/shell/completion.bash
[ -f "/home/mp466/.fzf/shell/completion.bash" ] && . "/home/mp466/.fzf/shell/completion.bash"
# shellcheck source=/home/mp466/.fzf/shell/key-binding.bash
[ -f "/home/mp466/.fzf/shell/key-bindings.bash" ] && . "/home/mp466/.fzf/shell/key-bindings.bash"
# shellcheck source=/home/mp466/.alacritty/extra/completions/alacritty.bash
[ -f "/home/mp466/.alacritty/extra/completions/alacritty.bash" ] && . "/home/mp466/.alacritty/extra/completions/alacritty.bash"
# shellcheck source=/home/mp466/.vim/scripts/jaauliaup-completion.sh
[ -f "$HOME/.vim/scripts/juliaup-completion.sh" ] && . "$HOME/.vim/scripts/juliaup-completion.sh"
# shellcheck source=/home/mp466/.vim/scripts/readable-completion.sh
[ -f "$HOME/.vim/scripts/readable-completion.sh" ] && . "$HOME/.vim/scripts/readable-completion.sh"
# shellcheck source=/home/mp466/.vim/scripts/nb.completion.ash_
[ -f "$HOME/.vim/scripts/nb.completions.sh" ] && . "$HOME/.vim/scripts/nb.completions.sh"

# tmuxp completion
# eval "$(_TMUXP_COMPLETE=source tmuxp)"

# pipx completion
eval "$(register-python-argcomplete pipx)"

# ignore case completion
bind 'set completion-ignore-case on'
# filename matching during completion will treat hyphens and underscores as equivalent
bind "set completion-map-case on"
# display all possible matches for an ambiguous pattern at the first <Tab> press
bind "set show-all-if-ambiguous on"

# man pages
export MANPATH=/usr/local/share/man:$MANPATH
export MANPATH=$HOME/.rvm/man:$MANPATH

# HPC compilers
export PGI=$HOME/misc/opt/pgi
export PATH=/home/mp466/misc/opt/pgi/linux86-64/19.10/bin:$PATH
export MANPATH=/home/mp466/misc/opt/pgi/linux86-64/19.10/man:$MANPATH
export PATH=/usr/lib/postgresql/12/bin:$PATH

export PGI=$HOME/misc/opt/pgi
# export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH
# export LIBRARY_PATH=/usr/lib64:$LIBRARY_PATH
# export LM_LICENSE_FILE=$LM_LICENSE_FILE:/opt/pgi/license.dat

export PATH=/usr/bin:$PATH

# Intel Distribution for Python – High-performance Python powered by native Intel Performance Libraries
# Intel Cluster Checker node list -  anaylyse cluster performance 
# intel-architecture-code-analyzer
# export PATH=/home/mp466/alcf/intel/iaca-lin64/bin:$PATH

# source /opt/intel/parallel_studio_xe_2019/bin/psxevars.sh
# running Application Performance Snapshot:
#source /opt/intel/performance_snapshots/apsvars.sh

# Intel Inspector – Easy-to-use Memory and Threading Error Debugger for C, C++, Fortran
#source /opt/intel/inspector_2019/inspxe-vars.sh

# Intel Trace Analyzer and Collector – Understand MPI application behavior for C, C++, Fortran, OpenSHMEM
# source /opt/intel/itac_latest/bin/itacvars.sh

# Intel Advisor – Optimize Vectorization and Thread Prototyping for C, C++, Fortran
# source /opt/intel/advisor_2020/advixe-vars.sh
# source /home/mp466/intel/advisor_2019.5.0.602216/advixe-vars.sh
# export ADVIXE_EXPERIMENTAL=roofline_guidance

# Intel Vtune Amplifier – Serial/Threaded Performance Profiler for C, C++, Fortran, Mixed Python 
# source /opt/intel/vtune_profiler/amplxe-vars.sh

#Intel Math Kernel Library
#source /opt/intel/mkl/bin/mklvars.sh intel64 mod

PS1='\[\e[0;32m\]\u\[\e[m\]\[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\]\[\e[1;37m\]'
PS1="\A $PS1\$(__git_ps1)"

# GO Config
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$PATH
export PATH=$GOPATH/bin:$PATH

# Haskell Config for shellcheck
export PATH=$HOME/.cabal/bin:$PATH

# Node Config
export PATH="$HOME/misc/node-v16.14.2-linux-x64/bin:$PATH"

# defines the search path for the directory containing directories:
export CDPATH=.:~:$HOME/bin:
export FIGNORE='.tmp:.o'

# Python virtual env
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/envs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV="pyvenv"
# for tab completed repl
export PYTHONSTARTUP=$HOME/.pythonrc
# commented due to profiling
#source /usr/local/bin/virtualenvwrapper.sh

# pipsi
export PATH=/home/mp466/.local/bin:$PATH

# dasht Config
export PATH=$HOME/.dasht/bin:$PATH
export MANPATH=$HOME/.dasht/man:$MANPATH

#set term for clearing background color for tmuxp
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export MDM_LANG=en_US.UTF-8

export TERM=screen-256color-bce

# manpath
export MANPATH=$HOME/.lynis:$MANPATH

#-------------------- fzf -------------------------------------------------
# Use ~~ as the trigger sequence for <TAB> instead of the default **
export FZF_COMPLETION_TRIGGER='**'
# Options to fzf command
export fzf_completion_opts='+C -X'

# http://blog.burntsushi.net/ripgrep/
# http://owen.cymru/fzf-ripgrep-navigate-with-bash-faster-than-ever-before/

# Ctrl + p - edit a file in vim from fzf
bind -x '"\C-p": vim $(fzf);'

# Ctrl + t - insert file from fzf into command
# Set FZF_CTRL_T_COMMAND to override the default command
# Alt + c - change directory from fzf - see the update at the bottom for faster search with bfs.

export FZF_DEFAULT_COMMAND='fd --type f --color=never'
# select all search results with <alt-a> and deselect them with <alt-d>.
# export FZF_DEFAULT_OPTS='--bind J:down,K:up,alt-a:select-all,alt-d:deselect-all --reverse --ansi --multi'
export FZF_DEFAULT_OPTS="--height=~50% --bind J:down,K:up --reverse --ansi --multi"
#export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse --ansi --multi --height 50%'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"

# Use rg (https://github.com/BurntSushi/ripgrep) instead of the default find
# command for listing path candidates.
# - The first argument to the function is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
# - rg only lists files, so we use with-dir script to augment the output
_fzf_compgen_path() {
  rg --files "$1" | with-dir "$1"
}

# Use rg to generate the list for directory completion
_fzf_compgen_dir() {
  rg --files "$1" | only-dir "$1"
}

[ -f "$HOME/.fzf-marks-code/fzf-marks.plugin.bash" ] && source "$HOME/.fzf-marks-code/fzf-marks.plugin.bash"
# File containing the marks data
export FZF_MARKS_FILE=$HOME'/.fzf-marks'
# Command used to call `fzf`
# export FZF_MARKS_COMMAND='fzf  --height 40% --reverse'
export FZF_MARKS_COMMAND="fzf --height 40% --reverse --header='ctrl-y:jump, ctrl-t:toggle, ctrl-d:delete'"
# `\C-g` (*bash*) Keybinding to `fzm`
export FZF_MARKS_JUMP='\C-g'

# remove duplicates in PATH variable
# PATH=$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++')
# export PATH

# add terminal hints
~/.vim/scripts/vocab_info
~/.vim/scripts/vim_info

# pipenv handles dependency and virtual environment management, local libraries
export PATH="/home/mp466/.local/bin:$PATH"

# .pyenv run multiple Python versions, isolated from the system Python have at end of config
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# comment of bash profiling
# set +x
# exec 2>&3 3>&-

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# shellcheck source=/home/mp466/.fzf.bash
# [ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# source /home/mp466/.config/broot/launcher/bash/br

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in *:/home/mp466/.julia/juliaup/bin:*);; *)
    export PATH=/home/mp466/.julia/juliaup/bin${PATH:+:${PATH}};;
esac

# <<< juliaup initialize <<<
. "$HOME/.cargo/env"

# Add these lines to the very bottom of the file
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
