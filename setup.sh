#!/usr/bin/env bash

# Stop execution if any command fails
set -e

# Default versions
DEFAULT_RUST_VERSION="1.74.0"
DEFAULT_PYTHON_VERSION="3.10"

# Initialize variables with default values
RUST_VERSION="$DEFAULT_RUST_VERSION"
PYTHON_VERSION="$DEFAULT_PYTHON_VERSION"

# Function to display usage
usage() {
    echo "Usage: $0 [--rust <rust_version>] [--python <python_version>]"
    exit 1
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rust) RUST_VERSION="$2"; shift ;;
        --python) PYTHON_VERSION="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Rest of your setup script...
echo "Setting up environment with Rust $RUST_VERSION and Python $PYTHON_VERSION"

# Function to check if a command is available
command_exists() {
    command -v "$1" &>/dev/null
}

# Install Rust and set the specified version, if not already installed or set
install_rust() {
    echo "Checking Rust installation..."
    if ! command_exists rustup; then
        echo "Rustup not found. Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    else
        echo "Rust is already installed."
    fi

    echo "Setting Rust to version $RUST_VERSION..."
    rustup install "$RUST_VERSION"
    rustup default "$RUST_VERSION"
}

# Install Clippy and Rustfmt
install_rust_tools() {
    echo "Installing Rust tools (clippy, rustfmt)..."
    rustup component add clippy rustfmt
}

# Install pyenv for Python version management
install_pyenv() {
    echo "Checking for pyenv..."
    if [ -d "$HOME/.pyenv" ]; then
        echo "pyenv is already installed."
    else
        echo "pyenv not found. Installing pyenv..."
        curl https://pyenv.run | bash
    fi
    # Add pyenv to PATH and initialize if not already done
    if ! command_exists pyenv; then
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv virtualenv-init -)"
    fi
}

# Install Python using pyenv
install_python() {
    echo "Installing Python $PYTHON_VERSION using pyenv..."
    pyenv install -s "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
}

# Install Pipenv using pip
install_pipenv() {
    echo "Installing Pipenv..."
    pip install --user pipenv
}

# Create or update Pipfile with the specified Python version
create_or_update_pipfile() {
    if [ ! -f Pipfile ]; then
        echo "Creating Pipfile with Python version $PYTHON_VERSION..."
        pipenv --python "$PYTHON_VERSION"
    else
        echo "Pipfile exists. Checking Python version..."
        # Extract the Python version from the Pipfile
        PIPFILE_PYTHON_VERSION=$(grep 'python_version' Pipfile | cut -d '"' -f 2)
        if [ "$PIPFILE_PYTHON_VERSION" != "$PYTHON_VERSION" ]; then
            echo "Pipfile Python version ($PIPFILE_PYTHON_VERSION) differs from the specified version ($PYTHON_VERSION). Updating Pipfile..."
            pipenv --python "$PYTHON_VERSION"
        else
            echo "Pipfile already specifies Python $PYTHON_VERSION."
        fi
    fi
}

# Install pre-commit using Pipenv
install_pre_commit() {
    echo "Installing pre-commit..."
    pipenv install pre-commit
}

# Setup pre-commit hooks from .pre-commit-config.yaml if it exists
setup_pre_commit_hooks() {
    if [ -f .pre-commit-config.yaml ]; then
        echo "Setting up pre-commit hooks..."
        pipenv run pre-commit install
    else
        echo "No .pre-commit-config.yaml found. Skipping pre-commit hook setup."
    fi
}

# Main setup function
main_setup() {
    install_rust
    install_rust_tools
    install_pyenv
    install_python
    install_pipenv
    create_or_update_pipfile
    install_pre_commit
    setup_pre_commit_hooks
    echo "Setup completed successfully."
}

main_setup
