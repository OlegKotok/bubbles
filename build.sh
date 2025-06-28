#!/bin/bash

# Simple build script for Bubbles Qt6 application
# This script checks dependencies and builds the application in one command

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Bubbles Qt6 Application Builder${NC}"
echo "=================================="

# Function to check if a command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1 is available"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not available"
        return 1
    fi
}

# Function to check Qt6 installation
check_qt6() {
    if [ -d "/opt/homebrew/opt/qt@6" ] || [ -d "/usr/local/opt/qt@6" ]; then
        echo -e "${GREEN}✓${NC} Qt6 installation found"
        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
        export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"
        export QT_PLUGIN_PATH="/opt/homebrew/opt/qt@6/plugins"
        return 0
    else
        echo -e "${RED}✗${NC} Qt6 not found. Please install with: brew install qt@6"
        return 1
    fi
}

# Check dependencies
echo "🔍 Checking dependencies..."
DEPS_OK=true

check_command "cmake" || DEPS_OK=false
check_command "make" || DEPS_OK=false
check_command "git" || DEPS_OK=false
check_qt6 || DEPS_OK=false

if [ "$DEPS_OK" = false ]; then
    echo -e "${RED}❌ Missing dependencies. Please run ./setup.sh first.${NC}"
    exit 1
fi

# Check for git submodules
echo "🔧 Checking qml-box2d submodule..."
if [ ! -d "qml-box2d" ] || [ ! "$(ls -A qml-box2d)" ]; then
    echo -e "${YELLOW}⚠️ Initializing qml-box2d submodule...${NC}"
    git submodule update --init --recursive
else
    echo -e "${GREEN}✓${NC} qml-box2d submodule is ready"
fi

# Build configuration
BUILD_TYPE=${1:-Release}
BUILD_DIR="build/macos-${BUILD_TYPE,,}"

echo "🔨 Building application (${BUILD_TYPE} mode)..."
echo "Build directory: ${BUILD_DIR}"

# Create and enter build directory
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Configure with CMake
echo "⚙️ Configuring with CMake..."
cmake ../.. \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DQt6_DIR="${Qt6_DIR}" \
    -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt@6"

# Build
echo "🏗️ Building..."
make -j$(sysctl -n hw.ncpu)

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "🎯 To run the application:"
echo "   cd ${BUILD_DIR} && ./BubblesApp"
echo ""
echo "📱 Expected behavior:"
echo "   • Black 1024×768 window"
echo "   • Ten initial bubbles with images"
echo "   • Click to add 5 new bubbles at mouse position"
echo "   • Physics collisions with walls and other bubbles"
echo "   • Round clipping with GraphicalEffects mask"
