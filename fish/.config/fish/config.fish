source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
#function fish_greeting
#    # smth smth
#end

# opencode
fish_add_path /home/jose/.opencode/bin

set -gx BW_SESSION "aTY8vvmHSpdRmR9StbCGhECsBEyX1nSCnCIMk1/YmES2golPM0z5M0RZAt9NJ/eWJcGnWqU3GCHbJjiN+eBAUw=="

# Editor
set -gx EDITOR nvim

# Language
set -gx LANG en_US.UTF-8

# Tmux
set -gx TERM xterm-256color
set -gx tmux "tmux -u"

# FZF
set -gx FZF_DEFAULT_COMMAND "fd --hidden"
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND "$FZF_DEFAULT_COMMAND --type d"
alias fzf "fzf --tmux"

# Mason, Zig, local bins
fish_add_path $HOME/.local/share/nvim/mason/bin
fish_add_path $HOME/.local/share/zig
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/scripts

# JAVA
set -gx JAVA_HOME "$HOME/.sdkman/candidates/java/current"
fish_add_path $JAVA_HOME/bin

# Prettierd
set -gx PRETTIERD_DEFAULT_CONFIG ~/.config/prettierd/.prettierrc.json

# Compose
set -gx COMPOSE_BAKE true

# Bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# PNPM
set -gx PNPM_HOME "/home/jose/.local/share/pnpm"
fish_add_path $PNPM_HOME

# Aliases
alias open "xdg-open"
alias vim "nvim"
alias vi "bob run nightly -- -u ~/.config/nvim-mini/init.lua"
alias mvci "mvn clean install"
alias py "/usr/bin/python3.13"
alias python "/usr/bin/python3.13"
alias gjf 'fd -e java -X google-java-format --replace {}'
alias gjfo 'fd -e java -X google-java-format -aosp --replace {}'
alias mvsr "mvn spring-boot:run"
alias mvss "mvn spring-boot:start"
alias mvsc "mvn spring-boot:stop"
alias lg "lazygit"
alias cpf "copyfile"
alias ldock "lazydocker"
alias dcu "docker compose up"
alias dcd "docker compose down"
alias dcub "docker compose up --build"
alias kill_mysql 'sudo /etc/init.d/mysql stop'
alias tm "tmux"
alias sf "fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim"
alias ls "eza --icons=always -s=type"
alias l "ls -1"
alias tree "l -T"
alias ginit 'g init && gaa && gcam "initialized project"'
alias glg "g log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n%C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
alias bathelp 'bat --plain --language=help'

# Yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file=$tmp
    set cwd (cat $tmp)
    if test -n "$cwd"; and test "$cwd" != "$PWD"
        cd $cwd
    end
    rm -f $tmp
end

# Help function
function help
    $argv --help 2>&1 | bathelp
end

# Vi key bindings
set -g fish_key_bindings fish_vi_key_bindings

# Starship
# starship init fish | source

# Zoxide
zoxide init fish --cmd cd | source

# FZF fish key bindings
fzf --fish | source

# Pipx completions
# register-python-argcomplete pipx | source

# NVM (use bass or nvm.fish plugin)
# Option 1: nvm.fish (recommended)
# fisher install jorgebucaran/nvm.fish

# Tmux git autofetch
# function tmux_git_autofetch --on-variable PWD
#     /home/jose/.tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &
# end

# SDKMAN (MUST BE AT END)
# set -gx SDKMAN_DIR "$HOME/.sdkman"
# source "$HOME/.sdkman/bin/sdkman-init.sh"
