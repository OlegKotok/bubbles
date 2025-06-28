#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found, installing it..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

# Function to install necessary packages
install_packages() {
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install || echo "Xcode Command Line Tools are already installed."

    echo "Installing Qt6..."
    brew install qt@6

    echo "Installing CMake..."
    brew install cmake

    echo "Installing Git..."
    brew install git
}

# Function to set Qt6 environment variables
setup_qt_environment() {
    echo "Setting up Qt6 environment variables..."
    export PATH="/opt/homebrew/bin:$PATH"
    export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"
    export QT_PLUGIN_PATH="/opt/homebrew/opt/qt@6/plugins"

    echo "Adding Qt6 environment variables to ~/.zshrc..."
    { 
        echo '# Qt6 PATH';
        echo 'export PATH="/opt/homebrew/bin:$PATH"';
        echo 'export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"';
        echo 'export QT_PLUGIN_PATH="/opt/homebrew/opt/qt@6/plugins"';
    } >> ~/.zshrc

    source ~/.zshrc
}

# Function to initialize Git submodules
initialize_submodules() {
    echo "Initializing Git submodules..."
    git submodule update --init --recursive
}

# Function to build the application
build_application() {
    mkdir -p build/macos-release
    cd build/macos-release

    echo "Configuring CMake..."
    cmake ../.. -DCMAKE_BUILD_TYPE=Release

    echo "Building the application..."
    make -j$(sysctl -n hw.ncpu)

    echo "Build completed."
}

# Main function to orchestrate installation
main() {
    check_homebrew
    install_packages
    setup_qt_environment
    initialize_submodules
    build_application

    echo "Installation and setup are complete!"
    echo "Run './build/macos-release/BubblesApp' to start the application."
}

# Run the main function
main

