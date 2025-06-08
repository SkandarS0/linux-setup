php_setup() {
    env PATH="$PATH" PHP_INI_SCAN_DIR="$PHP_INI_SCAN_DIR" bash -c "$(curl -fsSL https://php.new/install/linux/8.4 | sed s/uninstall_herd_lite/uninstall/g | sed s#\$HOME/.config/herd-lite/bin#\$HOME/.dev-tools/php#g)"
}

uv_setup() {
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$UV_INSTALL_DIR" INSTALLER_NO_MODIFY_PATH=1 bash
    env UV_PYTHON_INSTALL_DIR="$UV_INSTALL_DIR/python" "$UV_INSTALL_DIR/uv" python install
}

rust_setup() {
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | env CARGO_HOME="$HOME/.dev-tools/cargo" RUSTUP_HOME="$HOME/.dev-tools/rustup" bash -s -- -y --no-modify-path
}

pnpm_setup() {
    # download latest release from GitHub
    local url="https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linux-x64"
    local dest="$HOME/.dev-tools/pnpm/pnpm"
    mkdir -p "$(dirname "$dest")"
    wget -q -O "$dest" "$url"
    chmod +x "$dest"
}

sdkman_setup() {
    curl -s "https://get.sdkman.io" | env SDKMAN_DIR="$HOME/.dev-tools/sdkman" bash
}