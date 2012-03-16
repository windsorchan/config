#-------------------------------------------------------------
# Environment Variables
#-------------------------------------------------------------
export PS1='\[\033[0;34m\][\T] \[\033[00;33m\][\W]\[\033[0;31m\] :\[\033[0m\] '
export PATH='/home/windsor/bin':$PATH
export LD_LIBRARY_PATH='/home/windsor/lib:/usr/local/lib'

#-------------------------------------------------------------
# Personal Aliases
#-------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias hist='history | grep $1'            # search cmd history
alias ducks='du -cks * |sort -rn |head -11' # disk hog
alias grep='grep --color=auto'            # colourized grep
alias egrep='egrep --color=auto'          # colourized egrep
alias adb='/opt/android-sdk/platform-tools/adb'
alias rs='redshift -l 37.7929:-122.4212 -m vidmode'
alias python='python2'

#-------------------------------------------------------------
# Colored man pages
#-------------------------------------------------------------
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;37m") \
    LESS_TERMCAP_md=$(printf "\e[1;37m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;47;30m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[0;36m") \
      man "$@"
}

#-------------------------------------------------------------
# Pacman Aliases
#-------------------------------------------------------------
alias pacup='sudo pacman -Syu'            # sync and update
alias pacin='sudo pacman -S'              # install pkg
alias pacout='sudo pacman -Rns'           # remove pkg and the deps it installed
alias pacs="pacman -Sl | cut -d' ' -f2 | grep " #
alias pac="pacsearch"                     # colorize pacman (pacs)
pacsearch () 
{
  echo -e "$(pacman -Ss $@ | sed \
  -e 's#core/.*#\\033[1;31m&\\033[0;37m#g' \
  -e 's#extra/.*#\\033[0;32m&\\033[0;37m#g' \
  -e 's#community/.*#\\033[1;35m&\\033[0;37m#g' \
  -e 's#^.*/.* [0-9].*#\\033[0;36m&\\033[0;37m#g' )"
}

#-------------------------------------------------------------
# The 'ls' family
#-------------------------------------------------------------
alias ll="ls -l --group-directories-first"
alias ls='ls --color --group-directories-first'  # add colors for filetype recognition
alias la='ls -Al'          # show hidden files
alias lx='ls -lXB'         # sort by extension
alias lk='ls -lSr'         # sort by size, biggest last
alias lc='ls -ltcr'        # sort by and show change time, most recent last
alias lu='ls -ltur'        # sort by and show access time, most recent last
alias lt='ls -ltr'         # sort by date, most recent last
alias lm='ls -al |more'    # pipe through 'more'
alias lr='ls -lR'          # recursive ls
alias tree='tree -Csu'     # nice alternative to 'recursive ls'

#-------------------------------------------------------------
# Git Auto Completion
#-------------------------------------------------------------
source ~/.git-completion.bash

#-------------------------------------------------------------
# Functions
#-------------------------------------------------------------
extract ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       rar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# start, stop, restart, reload - simple daemon management
# usage: start 
start()
{
  for arg in $*; do
    sudo /etc/rc.d/$arg start
  done
}
stop()
{
  for arg in $*; do
    sudo /etc/rc.d/$arg stop
  done
}
restart()
{
  for arg in $*; do
    sudo /etc/rc.d/$arg restart
  done
}
reload()
{
  for arg in $*; do
    sudo /etc/rc.d/$arg reload
  done
}

# Creates an archive from given directory
mktar() { tar cvf "${1%%/}.tar" "${1%%/}/"; }
mktgz() { tar cvzf "${1%%/}.tar.gz" "${1%%/}/"; }
mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

ranger()
{
    command ranger --fail-unless-cd $@ &&
    cd "$(grep \^\' ~/.config/ranger/bookmarks | cut -b3-)" #'
} 

yt()
{
    mplayer $(d=/proc/$(pidof plugin-container)/fd; ls --color=no  -l $d | gawk '/\/tmp\/Flash/ {print "'$d'/" $9}' )
}

