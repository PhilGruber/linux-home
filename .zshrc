autoload colors; colors

# better colors for ls
if [ -f ~/.dircolors ]; then
    eval `dircolors -b ~/.dircolors`
else
    eval `dircolors`
fi

# colored ls, ll
alias ls='ls --color=auto'
alias ll="ls -lh"
# alias less=/usr/share/vim/vim63/macros/less.sh

if [[ "`whoami`" == "root" ]] {
    alias as='apt-cache search'
    alias ai='apt-get install'
    alias ad='apt-cache show'
}

export LC_ALL=en_GB.utf-8
export LANGUAGE=en_GB.utf-8

# for "< file.txt"
PAGER='less -M'
export VISUAL=vim
export EDITOR=vim

# new completion-mode
autoload -U compinit; compinit
autoload -U zcalc
      
# load host-specific settings
if [ -f ~/.zsh/user ]; then
    source ~/.zsh/user
fi

if [ -f ~/.zsh/motd ]; then
    source ~/.zsh/motd
fi

# autocompletion for networking tools
compctl -k hosts telnet ftp ssh ping scp

zstyle ':completion:*:scp:*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(ssh|scp):*:hosts-host' ignored-patterns '*.*' loopback localhost
zstyle ':completion:*:(ssh|scp):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^*.*' '*@*'
zstyle ':completion:*:(ssh|scp):*:hosts-ipaddr' ignored-patterns '^<->.<->.<->.<->' '127.0.0.<->'
zstyle -e ':completion:*:(ssh|scp):*' hosts 'reply=(
        ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ,]*}//,/ }
        )'

#   don't complete the same file more than one time
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*:cp:*' ignore-line yes

#   cache for completion (good for ssh)
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

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
  

# print path into title of ?term

precmd() {
#    [[ -t 1 ]] || return
    case $TERM in
	*xterm*|rxvt*)
    print -Pn "\e]2;[%n@%m] %~\a"
	;;
	screen*)
    print -Pn "\"%~\134"
	;;
    esac
}

preexec() {
#    [[ -t 1 ]] || return
    case $TERM in
	*xterm*|rxvt*)
	print -Pn "]2;$1\a"
	;;
	screen*)
	print -Pn "\"$1\134"
	;;
    esac
}

# to execute chpwd() on login
cd .


# cool colored prompt
if [[ `whoami` == 'root' ]]; then logincolor=red; else logincolor=green; fi
if [[ $SSH_TTY == $TTY ]]; then hostcolor=red; else hostcolor=blue; fi
PS1="[%{$fg[$logincolor]%}%n%{$terminfo[sgr0]%}@%{$fg[$hostcolor]%}%m%{$terminfo[sgr0]%}] %~> " 

umask 022
