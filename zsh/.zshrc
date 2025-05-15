# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy/mm/dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# These are the commands required to intall the plugins:
# zsh-autosuggestions: `git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`
# zsh-syntax-highlighting: `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`
# zsh-autoswitch-virtualenv: `git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" "$ZSH_CUSTOM/plugins/autoswitch_virtualenv"`
# you-should-use: `git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use`
# zsh-bat: `git clone https://github.com/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat`
plugins=(git copyfile copybuffer dirhistory zsh-autosuggestions zsh-syntax-highlighting autoswitch_virtualenv you-should-use zsh-bat)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


alias vim="nvim"
alias mvsr="mvn spring-boot:run"
alias mvci="mvn clean install"
alias py="/usr/bin/python3.13"
alias python="/usr/bin/python3.13"
# format whole java project, execute in project root
alias jgf='find . -name "*.java" -exec google-java-format -aosp --replace {} +'

# kill mysql instance
alias kill_mysql='sudo /etc/init.d/mysql stop'

alias tm='tmux'

# search files in the currently open folder with fd and fzf, and open it in vim
# must install fd first using `sudo apt install fd-find` and then `ln -s $(which fdfind) ~/.local/bin/fd`
alias sf="fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim"

alias ls="eza --icons=always -s=type"
alias l="ls -1"

# alias tree="l -T"

tree() {
    local ignore_patterns=()
    local args=()
    local show_hidden=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i)
                shift
                # Grab ignore patterns until the next flag or end of arguments
                while [[ $# -gt 0 && "$1" != -* ]]; do
                    ignore_patterns+=("$1")
                    shift
                done
                ;;
            -a)
                show_hidden=true
                shift
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    # Build the eza command
    local eza_cmd=(eza -T)

    [[ "$show_hidden" == true ]] && eza_cmd+=(-a)
    [[ ${#ignore_patterns[@]} -gt 0 ]] && eza_cmd+=(-I "$(IFS='|'; echo "${ignore_patterns[*]}")")
    [[ ${#args[@]} -gt 0 ]] && eza_cmd+=("${args[@]}")

    # Run the command
    echo "${eza_cmd[@]}"
    "${eza_cmd[@]}"
}


alias ginit='g init && gaa && gcam "initialized project"'

if which lazydocker &>/dev/null; then
    alias lazypod='DOCKER_HOST=unix:///mnt/wsl/podman-sockets/podman-machine-default/podman-root.sock lazydocker'
fi

# function l() {
#         local dirs=() files=() hidden_dirs=() hidden_files=()
#
#     # Process non-hidden entries
#     for entry in *; do
#         if [[ -e "$entry" ]]; then
#             if [[ -d "$entry" ]]; then
#                 dirs+=("$entry")
#             else
#                 files+=("$entry")
#             fi
#         fi
#     done
#
#     # Process hidden entries (excluding . and ..)
#     for entry in .*; do
#         if [[ "$entry" == "." || "$entry" == ".." ]]; then
#             continue
#         fi
#         if [[ -e "$entry" ]]; then
#             if [[ -d "$entry" ]]; then
#                 hidden_dirs+=("$entry")
#             else
#                 hidden_files+=("$entry")
#             fi
#         fi
#     done
#
#     # Print each category with formatted output
#     print_section() {
#         if [[ $# -gt 1 ]]; then
#             echo "$1:"
#             shift
#             printf -- '- %s\n' "$@"
#         fi
#     }
#
#     print_section "Directories" "${dirs[@]}"
#     print_section "Files" "${files[@]}"
#     print_section "Hidden directories" "${hidden_dirs[@]}"
#     print_section "Hidden files" "${hidden_files[@]}"
# }
#
# unalias l

# Enable vim in cli
bindkey -v

# tmux
export TERM="xterm-256color"
export PATH="$PATH:$HOME/.local/bin"
export tmux="tmux -u"

# Oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/catppuccin_macchiato.omp.json)"

# Fzf
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
alias fzf="fzf --tmux"
source /usr/share/fzf/key-bindings.zsh

# fzf ctrl-r and alt-c behavior
export FZF_DEFAULT_COMMAND="fd --hidden"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"

# Mason bin
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Zig bin
export PATH="$HOME/.local/share/zig:$PATH"

export PATH="$HOME/.local/bin/:$PATH"

# JAVA
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export PATH=$JAVA_HOME/bin:$PATH
# export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/nvim/mason/share/jdtls/lombok.jar"

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Others
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/scripts:$PATH"

autoload -U compinit && compinit

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Prettierd
export PRETTIERD_DEFAULT_CONFIG=~/.config/prettierd/.prettierrc.json

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/jose/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/jose/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/jose/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/jose/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fpath+=~/.zsh/completions

eval "$(zoxide init zsh)"

# Greeter

# if [[ ! -f test_image.png ]]; then
#     touch test_image.png
# fi
#
# if [[ -f test_image.png ]]; then
#
#     terminal=$(ps -o 'cmd=' -p $(ps -o 'ppid=' -p $$))
#
#     case "$terminal" in
#         *kitty* | *ghostty*)
#             if command -v fastfetch &>/dev/null; then
#                 fastfetch
#             elif command -v neofetch &>/dev/null; then
#                 neofetch
#             fi
#             ;;
#         *)
#             if command -v fastfetch &>/dev/null; then
#                 fastfetch --logo-type builtin
#             elif command -v neofetch &>/dev/null; then
#                 neofetch --source ascii
#             fi
#             ;;
#     esac
#     rm -f test_image.png
# fi
# Greeeter
fastfetch 

# WSL specific config
if grep -qE "(Microsoft|WSL)" /proc/version; then
    alias podman='podman-remote-static-linux_amd64'

    for i in "/mnt/wslg/runtime-dir/"*; do
      if [ ! -L "$XDG_RUNTIME_DIR$(basename "$i")" ]; then
        [ -d "$XDG_RUNTIME_DIR$(basename "$i")" ] && rm -r "$XDG_RUNTIME_DIR$(basename "$i")"
        ln -s "$i" "$XDG_RUNTIME_DIR$(basename "$i")"
      fi
    done

    eval $($HOME/wsl2-ssh-agent)
fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
