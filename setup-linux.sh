#!/bin/bash

# Linux Setup Script for Bubbles Qt6 Application
# Supports Ubuntu/Debian, Fedora/CentOS, and Arch Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Bubbles Qt6 Application Setup for Linux${NC}"
echo "============================================="

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    else
        echo -e "${RED}❌ Unsupported Linux distribution${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📋 Detected distribution: $DISTRO${NC}"
}

# Function to install dependencies based on distribution
install_dependencies() {
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y \
                build-essential \
                cmake \
                git \
                qt6-base-dev \
                qt6-declarative-dev \
                qt6-tools-dev \
                qt6-tools-dev-tools \
                qml6-module-qtquick \
                qml6-module-qtquick-controls \
                qml6-module-qtquick-layouts \
                qml6-module-qtquick-window \
                qml6-module-qt5compat-graphicaleffects \
                libqt6multimedia6-dev
            ;;
        fedora|centos|rhel)
            if command -v dnf &> /dev/null; then
                PKG_MGR="dnf"
            else
                PKG_MGR="yum"
            fi
            
            sudo $PKG_MGR install -y \
                gcc-c++ \
                cmake \
                git \
                qt6-qtbase-devel \
                qt6-qtdeclarative-devel \
                qt6-qttools-devel \
                qt6-qt5compat-devel \
                qt6-qtmultimedia-devel
            ;;
        arch|manjaro)
            sudo pacman -S --needed --noconfirm \
                base-devel \
                cmake \
                git \
                qt6-base \
                qt6-declarative \
                qt6-tools \
                qt6-5compat \
                qt6-multimedia
            ;;
        opensuse*)
            sudo zypper install -y \
                gcc-c++ \
                cmake \
                git \
                libqt6-qtbase-devel \
                libqt6-qtdeclarative-devel \
                libqt6-qttools-devel \
                libqt6-qt5compat-devel \
                libqt6-qtmultimedia-devel
            ;;
        *)
            echo -e "${RED}❌ Unsupported distribution: $DISTRO${NC}"
            echo "Please install the following packages manually:"
            echo "- build-essential/gcc-c++/base-devel"
            echo "- cmake"
            echo "- git"
            echo "- Qt6 development packages"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
}

# Function to setup Qt6 environment
setup_qt_environment() {
    echo -e "${YELLOW}⚙️ Setting up Qt6 environment...${NC}"
    
    # Try to find Qt6 installation
    QT6_PATHS=(
        "/usr/lib/qt6"
        "/usr/lib/x86_64-linux-gnu/qt6"
        "/usr/local/Qt-6*"
        "/opt/Qt/6*"
        "$HOME/Qt/6*"
    )
    
    for path in "${QT6_PATHS[@]}"; do
        if [ -d "$path" ]; then
            export PATH="$path/bin:$PATH"
            export Qt6_DIR="$path/lib/cmake/Qt6"
            export QML_IMPORT_PATH="$path/qml"
            echo -e "${GREEN}✓ Found Qt6 at: $path${NC}"
            break
        fi
    done
    
    # Add to shell profile
    SHELL_PROFILE=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_PROFILE" ] && [ -n "$Qt6_DIR" ]; then
        echo "# Qt6 environment" >> "$SHELL_PROFILE"
        echo "export PATH=\"$(dirname $Qt6_DIR)/../bin:\$PATH\"" >> "$SHELL_PROFILE"
        echo "export Qt6_DIR=\"$Qt6_DIR\"" >> "$SHELL_PROFILE"
        echo "export QML_IMPORT_PATH=\"$(dirname $Qt6_DIR)/../qml\"" >> "$SHELL_PROFILE"
        echo -e "${GREEN}✓ Qt6 environment added to $SHELL_PROFILE${NC}"
    fi
}

# Function to initialize git submodules
initialize_submodules() {
    echo -e "${YELLOW}🔧 Initializing Git submodules...${NC}"
    git submodule update --init --recursive
    echo -e "${GREEN}✓ Git submodules initialized${NC}"
}

# Function to build the application
build_application() {
    echo -e "${YELLOW}🏗️ Building the application...${NC}"
    
    BUILD_DIR="build/linux-release"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake ../.. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_LINUX=ON
    
    make -j$(nproc)
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    
    # Make the application executable
    chmod +x BubblesApp
}

# Function to install additional libraries for runtime
install_runtime_dependencies() {
    echo -e "${YELLOW}📦 Installing runtime dependencies...${NC}"
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt install -y \
                qt6-qpa-plugins \
                libqt6gui6 \
                libqt6widgets6
            ;;
        fedora|centos|rhel)
            sudo $PKG_MGR install -y \
                qt6-qtbase-gui \
                qt6-qtbase
            ;;
        arch|manjaro)
            # Dependencies should already be covered
            ;;
    esac
}

# Main execution
main() {
    detect_distro
    install_dependencies
    setup_qt_environment
    install_runtime_dependencies
    initialize_submodules
    build_application
    
    echo ""
    echo -e "${GREEN}🎯 To run the application:${NC}"
    echo -e "${BLUE}   cd $BUILD_DIR && ./BubblesApp${NC}"
    echo ""
    echo -e "${GREEN}📱 Expected behavior:${NC}"
    echo -e "${BLUE}   • Black 1024×768 window${NC}"
    echo -e "${BLUE}   • Ten initial bubbles with images${NC}"
    echo -e "${BLUE}   • Click to add 5 new bubbles at mouse position${NC}"
    echo -e "${BLUE}   • Physics collisions with walls and other bubbles${NC}"
    echo -e "${BLUE}   • Round clipping with GraphicalEffects mask${NC}"
    echo ""
    echo -e "${GREEN}💡 Troubleshooting:${NC}"
    echo -e "${BLUE}   - If you get QML import errors, check QML_IMPORT_PATH${NC}"
    echo -e "${BLUE}   - For display issues, try: export QT_QPA_PLATFORM=xcb${NC}"
    echo -e "${BLUE}   - For Wayland: export QT_QPA_PLATFORM=wayland${NC}"
}

# Run main function
main "$@"
