autoload colors; colors

if [[ $SSH_TTY == $TTY ]]; then uptime; fi

alias ll="ls -lh"
alias grep='grep --colour'
alias gitk='gitk --date-order'
alias nano='vim'

alias phpcheck='for i (**/*.php) php -lq $i | grep -v "^No syntax errors"'

alias sf="bin/console"

if [[ "`uname`" == "Darwin" ]] {
	# Mac OS
	alias ls='ls -G'

} else {

    if [[ $SSH_TTY != $TTY ]] {
        if [[ -f ~/.Xmodmap ]] {
            xmodmap ~/.Xmodmap
        }
    }

	alias ls='ls --color=auto'
	if [ -f ~/.dircolors ]; then
		eval `dircolors -b ~/.dircolors`
	else
	    eval `dircolors`
	fi

}


if [[ "`uname`" == "Darwin" ]] {
    alias as='brew search'
    alias ai='brew install'
    alias ad='brew info'
    gitUpdate=`stat -f '%m' .git/FETCH_HEAD`

} else {
    if [[ "`whoami`" == "root" ]] {
        alias as='apt-cache search'
        alias ai='apt-get install'
        alias ad='apt-cache show'
    }

    gitUpdate=`stat -c %Y .git/FETCH_HEAD`
}

now=`date '+%s'`
gitAge=`echo "($now - $gitUpdate)/3600/24" | bc`

if [[ $gitAge > 28 ]] {
    echo 'Config files have not been updated for 28 days. Updating...'
    git pull
}

function merge-to {
    myBranch=`git status | grep 'On branch' | cut -d' ' -f3`
    dstBranch=$1
    git checkout $dstBranch
    git pull
    git merge --no-edit $myBranch
    git push
    git checkout $myBranch
}

function syupd {
    git checkout master
    git pull --rebase
    composer install
    bin/console doctrine:schema:update --force
    bin/console assets:install
    bin/console assetic:dump
}

export LC_ALL=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8

# for "< file.txt"
PAGER='less -M'
export VISUAL=vim
export EDITOR=vim

# new completion-mode
autoload -U compinit; compinit
autoload -U zcalc

if [ -d ~/.zsh ]; then
    for config (~/.zsh/*) source $config
fi

# autocompletion for networking tools
compctl -k hosts telnet ftp ssh ping scp mosh

zstyle ':completion:*:scp:*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(ssh|scp|mosh):*:hosts-host' ignored-patterns '*.*' loopback localhost
zstyle ':completion:*:(ssh|scp|mosh):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^*.*' '*@*'
zstyle ':completion:*:(ssh|scp|mosh):*:hosts-ipaddr' ignored-patterns '^<->.<->.<->.<->' '127.0.0.<->'
zstyle -e ':completion:*:(ssh|scp|mosh):*' hosts 'reply=(
        ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ,]*}//,/ }
        )'

#   don't complete the same file more than one time
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*:cp:*' ignore-line yes

#   cache for completion (good for ssh)
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

# tuning for tools that I use a lot
zstyle ':completion:*:*:vim:*:*files' ignored-patterns '*.(o|pdf|ps|aux)'
compdef '_files -g "*.(pdf|ps)"' evince

# better kill completion
zstyle ':completion:*:processes' command 'ps -x'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"
zstyle ':completion:*:processes-names' command  'ps c -u ${USER} -o command | uniq'

unsetopt promptcr
setopt nocheckjobs             # don't warn me about bg processes when exiting
setopt nohup                   # and don't kill them, either
setopt hist_ignore_dups

# history
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=1000

# cmd<cursor-up> searches for cmd
bindkey "$(echotc ku)" history-search-backward
bindkey "$(echotc kd)" history-search-forward
bindkey "^[[A"  up-line-or-search       # cursor up

git() { if [[ $@ == "merge testing" ]]; then command echo 'nooooooooooooo!!!!111'; else command git "$@"; fi; }

# print path into title of ?term

precmd() {
#	when drawing the prompt
    case $TERM in
	*xterm*|rxvt*)
    if [[ $SSH_TTY == $TTY ]]; then hostfield="[%n@%m]"; else hostfield="[%n]"; fi

    print -Pn "]2;$hostfield %~\a"
	;;
	screen*)
    print -Pn "\"%~\134"
	;;
    esac
}

preexec() {
#	before running a command
    case $TERM in
	*xterm*|rxvt*)
	print -Pn "]2;$1\a"
	;;
	screen*)
	print -Pn "\"$1\134"
	;;
    esac
}

# cool colored prompt
if [[ `whoami` == 'root' ]]; then logincolor=red; else logincolor=green; fi
if [[ $SSH_TTY == $TTY ]]; then hostcolor=red; else hostcolor=blue; fi

PS1="[%{$fg[$logincolor]%}%n%{$terminfo[sgr0]%}@%{$fg[$hostcolor]%}%m%{$terminfo[sgr0]%}] %~> "

umask 022

setopt AUTO_CD

mkcd() { mkdir -p $1; cd $1 }

# to execute chpwd() on login
cd .

