php-setup() {
    env PATH="$PATH" PHP_INI_SCAN_DIR="$PHP_INI_SCAN_DIR" bash -c "$(curl -fsSL https://php.new/install/linux/8.4 | sed s/uninstall_herd_lite/uninstall/g | sed s#\$HOME/.config/herd-lite/bin#\$HOME/.dev-tools/php#g)"
}

uv-setup() {
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$UV_INSTALL_DIR" INSTALLER_NO_MODIFY_PATH=1 bash
    env UV_PYTHON_INSTALL_DIR="$UV_INSTALL_DIR/python" "$UV_INSTALL_DIR/uv" python install && "$UV_INSTALL_DIR/uv" tool install ruff
}

rust-setup() {
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | env CARGO_HOME="$HOME/.dev-tools/cargo" RUSTUP_HOME="$HOME/.dev-tools/rustup" bash -s -- -y --no-modify-path --default-toolchain '1.87.0'
}

pnpm-setup() {
    # download latest release from GitHub
    local url="https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linux-x64"
    local dest="$HOME/.dev-tools/pnpm/pnpm"
    mkdir -p "$(dirname "$dest")"
    wget -q -O "$dest" "$url"
    chmod +x "$dest"
}

bun-setup() {
    curl -fsSL https://bun.sh/install | env BUN_INSTALL="$HOME/.dev-tools/bun" bash
}

sdkman-setup() {
    curl -s "https://get.sdkman.io" | env SDKMAN_DIR="$HOME/.dev-tools/sdkman" bash
}

_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

_error() {
    echo "[ERROR] $1" >&2
    return 1
}

git-get-hooks() {
    local language="$1"
    local hooks_dir=".git/hooks"
    local temp_dir=$(mktemp -d)
    
    # Configuration for git hooks repositories
    typeset -A HOOK_REPOS
    HOOK_REPOS=(
        [rust]="git@github.com:SkandarS0/rust-git-hooks.git"
        # [python]="git@github.com:SkandarS0/python-git-hooks.git"
    )
    
    # Validate arguments
    if [[ -z "$language" ]]; then
        echo "Usage: git-get-hooks <language>"
        echo "Available languages: ${(k)HOOK_REPOS}"
        return 1
    fi
    
    # Check if we're in a git repository
    if [[ ! -d ".git" ]]; then
        _error "Not in a git repository"
        return 1
    fi
    
    # Check if language is supported
    if [[ -z "${HOOK_REPOS[$language]}" ]]; then
        _error "Unsupported language '$language'"
        echo "Available languages: ${(k)HOOK_REPOS}"
        return 1
    fi
    
    local repo_url="${HOOK_REPOS[$language]}"
    
    _log "Installing $language git hooks from $repo_url..."
    
    # Clone the hooks repository
    if ! git clone "$repo_url" "$temp_dir" &>/dev/null; then
        _error "Failed to clone hooks repository"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Create hooks directory if it doesn't exist
    mkdir -p "$hooks_dir"
    
    # Remove any existing .sample files
    rm -f "$hooks_dir"/*.sample 2>/dev/null
    
    # Copy hooks (try hooks/ directory first, then root)
    if [[ -d "$temp_dir/hooks" ]]; then
        cp -r "$temp_dir/hooks"/* "$hooks_dir/" 2>/dev/null
    else
        find "$temp_dir" -maxdepth 1 -type f -executable -exec cp {} "$hooks_dir/" \;
    fi
    
    # Make hooks executable
    chmod +x "$hooks_dir"/* 2>/dev/null

    # Clean up
    rm -rf "$temp_dir"
    
    _log "$language git hooks installed successfully"
    echo "Installed hooks:"
    ls -la "$hooks_dir" 2>/dev/null || echo "No hooks found in hooks directory"

    # Create a marker file named after the language key
    touch "$hooks_dir/.${language}"
}

alias gg-hooks=git-get-hooks