ZSH=$HOME/.oh-my-zsh

# You can change the theme with another one from https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

# Useful oh-my-zsh plugins for Le Wagon bootcamps
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting history-substring-search)

# (macOS-only) Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

# Disable warning about insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
unalias lt # we need `lt` for https://github.com/localtunnel/localtunnel

# Load rbenv if installed (to manage your Ruby versions)
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv > /dev/null && eval "$(rbenv init -)"

# Load pyenv (to manage your Python versions)
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# Load nvm (to manage your node versions)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Call `nvm use` automatically in a directory with a `.nvmrc` file
autoload -U add-zsh-hook
load-nvmrc() {
  if nvm -v &> /dev/null; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use --silent
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      nvm use default --silent
    fi
  fi
}
type -a nvm > /dev/null && add-zsh-hook chpwd load-nvmrc
type -a nvm > /dev/null && load-nvmrc

# Rails and Ruby uses the local `bin` folder to store binstubs.
# So instead of running `bin/rails` like the doc says, just run `rails`
# Same for `./node_modules/.bin` and nodejs
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export BUNDLER_EDITOR=code
export EDITOR=code

# Set ipdb as the default Python debugger
export PYTHONBREAKPOINT=ipdb.set_trace

# Do not use export VAR without a value. Better use set -a.
set -a

: ${LEVEL:=-1}
let LEVEL=LEVEL+1

NULLCMD=:
RANDOM=$$

WINEDITOR="${VISUAL:=${EDITOR:=vim}}"
FCEDIT=vim

# (
case "$-" in
	*i*)
		CDPATH=:..:../..

		# (
		case "${ZSH_VERSION}" in
			[3-9].*)
				setopt AUTO_PARAM_SLASH
				setopt BEEP
				setopt CLOBBER
				;;
		esac

		set -E  # PUSHD_SILENT
		set -D  # PUSHD_TO_HOME
		set -o PUSHD_IGNORE_DUPS
		set -h	# HIST_IGNORE_DUPS
		set -k	# INTERACTIVE_COMMENTS

		setopt AUTO_CD
		setopt AUTO_LIST
		setopt AUTO_PUSHD
		setopt AUTO_REMOVE_SLASH
		setopt CDABLE_VARS
		setopt PRINT_EXIT_VALUE
		setopt HIST_IGNORE_DUPS
		setopt INTERACTIVE_COMMENTS
		# setopt MARK_DIRS
		alias markdirs='setopt MARK_DIRS'
		alias unmarkdirs='unsetopt MARK_DIRS'

		alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'''

		setopt PUSHD_IGNORE_DUPS
		setopt PUSHD_SILENT
		setopt PUSHD_TO_HOME

		for i in ls ll lt unalias
			do
				# ((
				case "$(whence -v $i)" in
					"$i is an alias for"*) builtin unalias $i;;
					"$i is a shell function"*) builtin unset -f $i;;
				esac
			done

		alias	ll='command /bin/ls -lFb'
		lt	() { command /bin/ls -lFtb $@ ; }
		rs	() { eval `resize -u` ; export TERMCAP ; }
		cdpwd	() { cd `/bin/pwd` ; }
		setenv	() { # var value
			eval export "$1"="\"$2\""
		} # setenv
		unsetenv () { # var.....
			unset $@
		} # unsetenv
		ifndef () { # var value
			eval export $1=\${$1-\$2}
		} # ifndef
		ifnull()   { eval export $1=\${$1:-\$2} ; }
		append()   { eval export $1=\${$1:+\$$1${2:+:}}\$2 ; }
		prepend()  { eval export $1=\$2\${$1:+${2:+:}\$$1} ; }

		alias	:ta='vim -t'
		alias	:n=vim
		alias	a=alias
		alias	ec='echo $?'
		alias	h="fc -l"
		alias	so=.
		alias	j='jobs -l'
		alias -- -='cd -'
		alias	l=ll
		alias	cls='echotc clear'
		alias	zshrc='let LEVEL=LEVEL-1;. ~/.zshrc'

		if [ -n "${FPATH}" ]
			then FPATH="${HOME}/zshautoload${PSEP}${FPATH}"
			else FPATH=${HOME}/zshautoload
		fi

		stty ixon echo echoe -tabs isig icanon erase "^H" intr "^C" eof "^D" -nl
		compctl -v export integer typeset declare readonly unset vared
		compctl -c man nohup env
		compctl -caF type whence which
		compctl -u whois finger id
		compctl -g '*(-/)' cd chdir pushd rmdir
		compctl -g '*.Z' + -g '*(-/)' uncompress
		compctl -g '*.(tar|tgz|tar.gz)' + -g '*(-/)' gnutar gtar tar zcat zmore zless
		compctl -u -x 'r[-c,;]' -l '' -- su

		for i in 1 2 3 4 5 6 7 8 9
			do
				alias ${i}="fg %${i}"
			done

		# Switch to vi mode and let BS work like in vi(1).
		bindkey -v
		bindkey -a '^H' backward-char
		bindkey -a 'J' vi-join
		bindkey -a '?' which-command
		# The next should be append-last-word
		# bindkey -a '_' insert-last-word
		# This comes close to ksh(1)'s version of ESC-_
		# bindkey -s -a '_' 'a \033-$by$+$pA'
		# bindkey -s -a '_' 'a \033-A \033byw+$pea'
		# Must set this for version 3.1.2
		bindkey -a '\M-_' insert-last-word
		# This seems to do the trick. \M-_ is insert-last-word.
		bindkey -s -a '_' 'a  \E\M-_s'

		[ -r "${HOME}/.exrc" ] && EXINIT="so ${HOME}/.exrc"

		for i in . ${HOME}/bin /bin /usr/sbin /sbin /usr/local/bin /usr/ucb ${OPENWINHOME}/bin /home/estw_ddts/ddts/bin /tools/gnu/bin /tools/samba/bin /home/manager/tdsc/Admintools /etc/venus/current/etc /usr/local/venus/ldap/admin/sbin /usr/local/ssh/bin /usr/local/scadmintools/bin /etc/venus/current/bin /opt/GNU/bin /usr/local/scadmintools/bin /opt/cc_scripts/ibm/bin  /usr/sfw/bin
			do
				case "${PATH}" in
					"$i"|"$i":*|*:"$i":*|*:"$i")
						;;
					*)
						[ -d "$i/." ] && PATH="${PATH}:$i"
						;;
				esac
			done

		for i in ${HOME}/man /usr/man ${OPENWINHOME}/man /usr/local/man /tools/gnu/man
			do
				case "${MANPATH}" in
					"$i"|"$i":*|*:"$i":*|*:"$i")
						;;
					*)
						[ -d "$i/." ] && MANPATH="${MANPATH}:$i"
						;;
				esac
			done
		;;
esac

set +a

