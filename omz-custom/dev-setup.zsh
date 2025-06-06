php_setup() {
    PATH="$HOME/.dev-tools/php:$PATH"
    PHP_INI_SCAN_DIR="$HOME/.dev-tools/php:$PHP_INI_SCAN_DIR"
    bash -c "$(curl -fsSL https://php.new/install/linux/8.4 | sed s/uninstall_herd_lite/uninstall/g | sed s#\$HOME/.config/herd-lite/bin#\$HOME/.dev-tools/php#g)"
}

uv_setup() {
    UV_INSTALL_DIR="$HOME/.dev-tools/uv"
    INSTALLER_NO_MODIFY_PATH=1
    UV_PYTHON_INSTALL_DIR="$UV_INSTALL_DIR/python"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    "$UV_INSTALL_DIR/uv" python install
}

rust_setup() {
    CARGO_HOME="$HOME/.dev-tools/cargo"
    RUSTUP_HOME="$HOME/.dev-tools/rustup"
    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
}