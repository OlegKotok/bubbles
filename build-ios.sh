#!/bin/bash

# iOS Build Script for Bubbles Qt6 Application
# Requires Qt6 installation with iOS support (not Homebrew version)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 iOS Build Script for Bubbles Qt6 Application${NC}"
echo "================================================="

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is required for iOS development${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check for Qt6 with iOS support
QT_IOS_PATHS=(
    "$HOME/Qt/6.5.0/ios"
    "$HOME/Qt/6.6.0/ios" 
    "$HOME/Qt/6.7.0/ios"
    "/Applications/Qt/6.5.0/ios"
    "/Applications/Qt/6.6.0/ios"
    "/Applications/Qt/6.7.0/ios"
    "/usr/local/Qt-6*/ios"
)

QT_IOS_PATH=""
for path in "${QT_IOS_PATHS[@]}"; do
    if [[ -d "$path" ]]; then
        QT_IOS_PATH="$path"
        break
    fi
done

if [[ -z "$QT_IOS_PATH" ]]; then
    echo -e "${RED}❌ Qt6 with iOS support not found${NC}"
    echo ""
    echo -e "${YELLOW}To build for iOS, you need to install Qt6 with iOS support:${NC}"
    echo ""
    echo "1. Download Qt6 from https://www.qt.io/download"
    echo "2. Run the Qt Installer"
    echo "3. During installation, make sure to select:"
    echo "   - Qt 6.x.x"
    echo "   - iOS component"
    echo "   - Qt Creator (recommended)"
    echo ""
    echo "4. After installation, Qt will be available at:"
    echo "   ~/Qt/6.x.x/ios/ or /Applications/Qt/6.x.x/ios/"
    echo ""
    echo -e "${BLUE}Alternative: Use Qt Creator for iOS development${NC}"
    echo "Qt Creator provides the best experience for iOS development."
    exit 1
fi

echo -e "${GREEN}✓ Found Qt6 iOS installation at: $QT_IOS_PATH${NC}"

# Set up environment
export PATH="$QT_IOS_PATH/bin:$PATH"
export Qt6_DIR="$QT_IOS_PATH/lib/cmake/Qt6"

# Check git submodules
echo -e "${YELLOW}🔧 Checking qml-box2d submodule...${NC}"
if [[ ! -d "qml-box2d" ]] || [[ ! "$(ls -A qml-box2d)" ]]; then
    echo -e "${YELLOW}⚠️ Initializing qml-box2d submodule...${NC}"
    git submodule update --init --recursive
else
    echo -e "${GREEN}✓ qml-box2d submodule is ready${NC}"
fi

# Create build directory
BUILD_DIR="build/ios-release"
echo -e "${YELLOW}🏗️ Creating build directory: $BUILD_DIR${NC}"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake for iOS
echo -e "${YELLOW}⚙️ Configuring CMake for iOS...${NC}"
cmake ../.. \
    -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_PREFIX_PATH="$QT_IOS_PATH" \
    -DQt6_DIR="$Qt6_DIR" \
    -DBUILD_IOS=ON \
    -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM="" \
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY="iPhone Developer" \
    -DCMAKE_XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER="com.example.bubbles"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌ CMake configuration failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ iOS project configured successfully!${NC}"
echo ""
echo -e "${GREEN}🎯 Next steps:${NC}"
echo -e "${BLUE}1. Open the Xcode project:${NC}"
echo "   open BubblesApp.xcodeproj"
echo ""
echo -e "${BLUE}2. In Xcode:${NC}"
echo "   - Select your development team in project settings"
echo "   - Choose a connected iOS device or simulator"
echo "   - Click the Run button to build and deploy"
echo ""
echo -e "${BLUE}3. Alternative command-line build:${NC}"
echo "   xcodebuild -project BubblesApp.xcodeproj -scheme BubblesApp -destination 'platform=iOS Simulator,name=iPhone 14' build"
echo ""
echo -e "${GREEN}📱 Expected behavior on iOS:${NC}"
echo -e "${BLUE}   • Touch interface adapted for mobile${NC}"
echo -e "${BLUE}   • Physics-based bubbles with touch interaction${NC}"
echo -e "${BLUE}   • Tap to add bubbles at touch position${NC}"
echo -e "${BLUE}   • Optimized for iOS performance${NC}"

# Try to open Xcode project if it exists
if [[ -f "BubblesApp.xcodeproj/project.pbxproj" ]]; then
    echo ""
    echo -e "${YELLOW}🚀 Opening Xcode project...${NC}"
    open BubblesApp.xcodeproj
fi
