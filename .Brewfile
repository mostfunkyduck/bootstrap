# Allows dumping extra stuff in the brewfile without committing to sharing it everywhere
instance_eval(File.read("#{Dir.home}/.Brewfile.local"))
# k8s
brew "kubectl"
brew "argocd"

# NeoVim
brew "nvim"
brew "ripgrep"

# Utilities
brew "age"
brew "obsidian" if OS.mac?
brew "libnotify"
brew "ncdu"
brew "gcc"
brew "npm"
brew "gh"
brew "jsonlint"
brew "jq"
brew "ag"

# need this because the version in repos is too old and there are compatibility issues b/c of course there are
brew "gnupg"
brew "rsc_2fa"

# Shell things
brew "bat"
brew "btop"
brew "shellcheck"

# Python things
brew "python3"
brew "pylint"
brew "mypy"
brew "pyright"

# Terminal things
tap "wez/wezterm"
cask "wez/wezterm/wezterm"
brew "tmux"
brew "tmux-mem-cpu-load"

# Useful, also used in tmux powerline extension
brew "ifstat"

# LSPs
brew "lua-language-server"
brew "bash-language-server"
brew "terraform-ls"
brew "gopls"

# Languages
brew "go"
