#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
#
# Aphrodite Terminal Theme
#
# Author: Sergei Kolesnikov
# https://github.com/win0err/aphrodite-terminal-theme
#
# ------------------------------------------------------------------------------

ZSH_THEME_GIT_PROMPT_PREFIX=" %F{10}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%f%F{11}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

aphrodite_get_welcome_symbol() {

	echo -n "%(?..%F{1})"
	
	local welcome_symbol='$'
	[ $EUID -ne 0 ] || welcome_symbol='#'
	
	echo -n $welcome_symbol
	echo -n "%(?..%f)"
}

gitbranch() {
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    local result=$?
    if [ $result -eq 0 ]; then
        #git diff-index --quiet HEAD --
        #dirty=$?
        local dirty=0
        if [ $branch = 'master' ]; then
            diffnum=$(git log origin/master.. 2>/dev/null|grep https://|grep -oP "D\d+")
            if [ $? = 0 ]; then
                branch="$branch++$diffnum"
            fi
        fi
        if [ $dirty -ne 0 ]; then
            branch="$branch*"
        fi
        echo " ($branch)"
    fi
}

# local aphrodite_get_time="%F{grey}[%*]%f"

aphrodite_get_current_branch() {

	local branch=$(git_current_branch)
	
	if [ -n "$branch" ]; then
		echo -n $ZSH_THEME_GIT_PROMPT_PREFIX
		echo -n $(parse_git_dirty)
		echo -n "‹${branch}›"
		echo -n $ZSH_THEME_GIT_PROMPT_SUFFIX
	fi
}

aphrodite_get_prompt() {

	# 256-colors check (will be used later): tput colors
	
	echo -n "%F{14}%n%f" # User
	echo -n "%F{14}@%f" # at
	echo -n "%F{14}%m%f" # Host
	echo -n "%F{8}:%f" # in 
	echo -n "%{$reset_color%}%B%F{12}%~%f%b" # Dir
	echo -n "$(gitbranch)" # Git branch
	echo -n " %F{7}\$%{$reset_color%} " # $ or #
}

export GREP_COLOR='1;31'

PROMPT="$(aphrodite_get_prompt)"
#PS1='${debian_chroot:+($debian_chroot)}\[\033[00;96m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ '
#
check_last_exit_code() {
  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    local EXIT_CODE_PROMPT=' '
    EXIT_CODE_PROMPT+="%{$fg[red]%}-%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg_bold[red]%}$LAST_EXIT_CODE%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg[red]%}-%{$reset_color%}"
    echo -n "$EXIT_CODE_PROMPT"
  fi
}

aphrodite_get_rprompt() {
    local LAST_EXIT_CODE=$?
	echo -n "%(?..%F{1})"
	
	local welcome_symbol="%F{241}%*%{$reset_color%}"
	[ $EUID -ne 0 ] || welcome_symbol='#'
	
    if [[ $LAST_EXIT_CODE -ne 0 ]]; then
        local EXIT_CODE_PROMPT=' '
        EXIT_CODE_PROMPT+="%B%F{241}$LAST_EXIT_CODE%{$reset_color%}"
        echo -n "$EXIT_CODE_PROMPT%{$reset_color%} "
    fi
	echo -n $welcome_symbol
	echo -n "%(?..%f)%{$reset_color%}"
}

RPROMPT="$(aphrodite_get_rprompt)"
