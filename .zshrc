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
# zstyle ':omz:update' mode auto      # update automatically without asking
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
# ENABLE_CORRECTION="true"

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
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(pyenv init -)"

function git-update() {
    # Store the current branch name
    local current_branch=$(git branch --show-current)

    # Check if we're in a git repository
    if [ -z "$current_branch" ]; then
        echo "Error: Not in a git repository or detached HEAD state"
        return 1
    fi

    # Stash current changes
    echo "Stashing changes..."
    git stash

    # Switch to main branch
    echo "Switching to main branch..."
    git checkout main

    # Pull latest changes
    echo "Pulling latest changes..."
    git pull

    # Switch back to original branch
    echo "Switching back to $current_branch..."
    git checkout "$current_branch"

    # Merge main into current branch
    echo "Merging main into $current_branch..."
    git merge main

    # Pop the stash
    echo "Applying stashed changes..."
    git stash pop
}

function git-renew() {
    # Get current branch name
    local current_branch=$(git branch --show-current)

    # Check if on main/master
    if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        echo "Error: Already on $current_branch. Switch to a feature branch first."
        return 1
    fi

    echo "Current branch: $current_branch"

    # Stash current work
    echo "Stashing changes..."
    git stash push -m "git-renew stash for $current_branch"

    # Switch to main and pull
    echo "Switching to main and pulling latest..."
    git checkout main && git pull

    # Delete local branch
    echo "Deleting local branch $current_branch..."
    git branch -D "$current_branch"

    # Delete remote branch
    echo "Deleting remote branch $current_branch..."
    git push origin --delete "$current_branch" 2>/dev/null || echo "Remote branch doesn't exist (ok)"

    # Create new branch from main
    echo "Creating fresh $current_branch from main..."
    git checkout -b "$current_branch"

    # Pop stash
    echo "Restoring your changes..."
    git stash pop

    echo "✅ Branch $current_branch renewed from latest main"
}

autoactivate_venv() {
  if [[ -f "$PWD/venv/bin/activate" ]]; then
    source "$PWD/venv/bin/activate"
  elif [[ -f "$PWD/.venv/bin/activate" ]]; then
    source "$PWD/.venv/bin/activate"
  elif [[ -n "$VIRTUAL_ENV" ]]; then
    # Deactivate if we leave a venv directory
    deactivate
  fi
}

# Hook into directory changes
autoload -U add-zsh-hook
add-zsh-hook chpwd autoactivate_venv

# Also run on shell startup
autoactivate_venv
export PATH="$HOME/.local/bin:$PATH"

