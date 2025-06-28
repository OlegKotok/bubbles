#!/bin/bash

# Universal Build Script for Bubbles Qt6 Application
# Supports macOS, Linux, Windows (via WSL), iOS, Android

set -e

# Handle platform-only option first (before any output)
if [[ "$1" == "platform-only" ]]; then
    # Function to detect current platform (inline for platform-only)
    detect_platform_inline() {
        case "$(uname -s)" in
            Darwin*)
                echo "macos"
                ;;
            Linux*)
                echo "linux"
                ;;
            CYGWIN*|MINGW32*|MSYS*|MINGW*)
                echo "windows"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    }
    echo "$(detect_platform_inline)"
    exit 0
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build configuration
BUILD_TYPE=${1:-Release}
TARGET_PLATFORM=${2:-auto}

echo -e "${GREEN}🚀 Universal Bubbles Qt6 Application Builder${NC}"
echo "=============================================="
echo -e "${BLUE}Build Type: $BUILD_TYPE${NC}"
echo -e "${BLUE}Target Platform: $TARGET_PLATFORM${NC}"

# Function to detect current platform
detect_platform() {
    if [[ "$TARGET_PLATFORM" != "auto" ]]; then
        echo "$TARGET_PLATFORM"
        return
    fi

    case "$(uname -s)" in
        Darwin*)
            if [[ -n "$IOS_DEPLOYMENT_TARGET" ]]; then
                echo "ios"
            else
                echo "macos"
            fi
            ;;
        Linux*)
            if [[ -n "$ANDROID_NDK_ROOT" ]] || [[ -n "$ANDROID_HOME" ]]; then
                echo "android"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to check dependencies for platform
check_dependencies() {
    local platform=$1
    echo -e "${YELLOW}🔍 Checking dependencies for $platform...${NC}"
    
    # Common dependencies
    local deps_ok=true
    command -v cmake >/dev/null 2>&1 || { echo -e "${RED}✗${NC} cmake not found"; deps_ok=false; }
    command -v git >/dev/null 2>&1 || { echo -e "${RED}✗${NC} git not found"; deps_ok=false; }
    
    case $platform in
        macos)
            command -v make >/dev/null 2>&1 || { echo -e "${RED}✗${NC} make not found"; deps_ok=false; }
            [[ -d "/opt/homebrew/opt/qt@6" ]] || [[ -d "/usr/local/opt/qt@6" ]] || { echo -e "${RED}✗${NC} Qt6 not found"; deps_ok=false; }
            ;;
        linux)
            command -v make >/dev/null 2>&1 || { echo -e "${RED}✗${NC} make not found"; deps_ok=false; }
            command -v pkg-config >/dev/null 2>&1 || { echo -e "${RED}✗${NC} pkg-config not found"; deps_ok=false; }
            ;;
        windows)
            # Check for Visual Studio or MinGW
            if ! command -v cl.exe >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1; then
                echo -e "${RED}✗${NC} No suitable compiler found (Visual Studio or MinGW required)"
                deps_ok=false
            fi
            ;;
        ios)
            command -v xcodebuild >/dev/null 2>&1 || { echo -e "${RED}✗${NC} Xcode not found"; deps_ok=false; }
            ;;
        android)
            [[ -n "$ANDROID_NDK_ROOT" ]] || { echo -e "${RED}✗${NC} ANDROID_NDK_ROOT not set"; deps_ok=false; }
            [[ -n "$ANDROID_HOME" ]] || { echo -e "${RED}✗${NC} ANDROID_HOME not set"; deps_ok=false; }
            ;;
    esac
    
    if [[ "$deps_ok" == "false" ]]; then
        echo -e "${RED}❌ Missing dependencies. Please run the appropriate setup script first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All dependencies found${NC}"
}

# Function to setup platform-specific environment
setup_environment() {
    local platform=$1
    echo -e "${YELLOW}⚙️ Setting up environment for $platform...${NC}"
    
    case $platform in
        macos)
            export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
            export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"
            export QT_PLUGIN_PATH="/opt/homebrew/opt/qt@6/plugins"
            ;;
        linux)
            # Try to find Qt6 installation
            for qt_path in "/usr/lib/qt6" "/usr/lib/x86_64-linux-gnu/qt6" "/usr/local/Qt-6*" "/opt/Qt/6*"; do
                if [[ -d "$qt_path" ]]; then
                    export PATH="$qt_path/bin:$PATH"
                    export Qt6_DIR="$qt_path/lib/cmake/Qt6"
                    export QML_IMPORT_PATH="$qt_path/qml"
                    break
                fi
            done
            ;;
        windows)
            # Windows-specific Qt setup
            if [[ -d "C:/Qt/6.5.0/msvc2019_64" ]]; then
                export PATH="C:/Qt/6.5.0/msvc2019_64/bin:$PATH"
                export Qt6_DIR="C:/Qt/6.5.0/msvc2019_64/lib/cmake/Qt6"
            fi
            ;;
        ios)
            export PATH="/opt/homebrew/bin:$PATH"
            export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"
            export IOS_DEPLOYMENT_TARGET="12.0"
            ;;
        android)
            export PATH="/opt/homebrew/bin:$PATH"
            export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"
            ;;
    esac
}

# Function to configure CMake for platform
configure_cmake() {
    local platform=$1
    local build_dir="build/${platform}-$(echo $BUILD_TYPE | tr '[:upper:]' '[:lower:]')"
    
    echo -e "${YELLOW}⚙️ Configuring CMake for $platform...${NC}"
    echo -e "${BLUE}Build directory: $build_dir${NC}"
    
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    local cmake_args=(
        "../.."
        "-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
    )
    
    case $platform in
        macos)
            cmake_args+=("-DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt@6")
            ;;
        linux)
            cmake_args+=("-DBUILD_LINUX=ON")
            ;;
        windows)
            cmake_args+=("-G" "Visual Studio 16 2019" "-A" "x64")
            cmake_args+=("-DBUILD_WINDOWS=ON")
            ;;
        ios)
            cmake_args+=("-G" "Xcode")
            cmake_args+=("-DCMAKE_SYSTEM_NAME=iOS")
            cmake_args+=("-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0")
            cmake_args+=("-DBUILD_IOS=ON")
            ;;
        android)
            cmake_args+=("-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake")
            cmake_args+=("-DANDROID_ABI=arm64-v8a")
            cmake_args+=("-DANDROID_PLATFORM=android-21")
            cmake_args+=("-DBUILD_ANDROID=ON")
            ;;
    esac
    
    cmake "${cmake_args[@]}"
}

# Function to build the application
build_application() {
    local platform=$1
    echo -e "${YELLOW}🏗️ Building application for $platform...${NC}"
    
    case $platform in
        windows)
            cmake --build . --config $BUILD_TYPE
            ;;
        ios)
            cmake --build . --config $BUILD_TYPE -- -destination "generic/platform=iOS"
            ;;
        android)
            cmake --build . --config $BUILD_TYPE
            ;;
        *)
            make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
            ;;
    esac
    
    # Deploy macOS app bundle for standalone distribution
    if [[ "$platform" == "macos" ]] && [[ -f "BubblesApp.app/Contents/MacOS/BubblesApp" ]]; then
        deploy_macos_app
    fi
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
}

# Function to deploy macOS app bundle
deploy_macos_app() {
    echo -e "${YELLOW}📦 Deploying Qt frameworks to macOS app bundle...${NC}"
    
    # Find macdeployqt in common locations
    local macdeployqt=""
    for path in "/opt/homebrew/opt/qt@6/bin/macdeployqt" "/usr/local/opt/qt@6/bin/macdeployqt" "/opt/homebrew/bin/macdeployqt"; do
        if [[ -f "$path" ]]; then
            macdeployqt="$path"
            break
        fi
    done
    
    if [[ -n "$macdeployqt" ]]; then
        echo -e "${BLUE}   Using macdeployqt: $macdeployqt${NC}"
        "$macdeployqt" BubblesApp.app -qmldir=../../ -verbose=2
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ App bundle deployment completed!${NC}"
            echo -e "${GREEN}🎉 The app bundle is now standalone and ready for distribution${NC}"
        else
            echo -e "${YELLOW}⚠️ macdeployqt completed with warnings, but app may still work${NC}"
        fi
        
        # Sign the app bundle for macOS security requirements
        echo -e "${BLUE}🔐 Code signing app bundle...${NC}"
        codesign --force --deep --sign - BubblesApp.app
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ App bundle code signed successfully${NC}"
        else
            echo -e "${YELLOW}⚠️ Code signing failed, but app may still work locally${NC}"
        fi
        
        # Verify the signature
        echo -e "${BLUE}🔍 Verifying code signature...${NC}"
        codesign -v BubblesApp.app
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ Code signature verification passed${NC}"
        else
            echo -e "${YELLOW}⚠️ Code signature verification failed${NC}"
        fi
        
        # Copy the standalone app to the project root for convenience
        echo -e "${BLUE}📋 Copying standalone app to project root...${NC}"
        rm -rf "../../BubblesApp.app" 2>/dev/null || true
        cp -R "BubblesApp.app" "../../BubblesApp.app"
        
        # Sign the copied app as well
        echo -e "${BLUE}🔐 Code signing copied app bundle...${NC}"
        codesign --force --deep --sign - "../../BubblesApp.app"
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ Copied app bundle code signed successfully${NC}"
        else
            echo -e "${YELLOW}⚠️ Code signing of copied app failed${NC}"
        fi
        
        echo -e "${GREEN}✅ Standalone BubblesApp.app copied to project root${NC}"
    else
        echo -e "${YELLOW}⚠️ macdeployqt not found - app bundle may require Qt installation to run${NC}"
        echo -e "${YELLOW}   To install: brew install qt@6${NC}"
    fi
}

# Function to provide run instructions
show_run_instructions() {
    local platform=$1
    local build_dir="build/${platform}-$(echo $BUILD_TYPE | tr '[:upper:]' '[:lower:]')"
    
    echo ""
    echo -e "${GREEN}🎯 To run the application:${NC}"
    
    case $platform in
        macos|linux)
            echo -e "${BLUE}   cd $build_dir && ./BubblesApp${NC}"
            ;;
        windows)
            echo -e "${BLUE}   cd $build_dir\\$BUILD_TYPE && .\\BubblesApp.exe${NC}"
            ;;
        ios)
            echo -e "${BLUE}   Open $build_dir/BubblesApp.xcodeproj in Xcode${NC}"
            echo -e "${BLUE}   Select target device and run${NC}"
            ;;
        android)
            echo -e "${BLUE}   Use Android Studio or adb to install the APK${NC}"
            echo -e "${BLUE}   APK location: $build_dir/android-build/build/outputs/apk/release/android-build-release.apk${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}📱 Expected behavior:${NC}"
    echo -e "${BLUE}   • Black 1024×768 window${NC}"
    echo -e "${BLUE}   • Ten initial bubbles with images${NC}"
    echo -e "${BLUE}   • Click to add 5 new bubbles at mouse position${NC}"
    echo -e "${BLUE}   • Physics collisions with walls and other bubbles${NC}"
    echo -e "${BLUE}   • Round clipping with GraphicalEffects mask${NC}"
}

# Function to check git submodules
check_submodules() {
    echo -e "${YELLOW}🔧 Checking qml-box2d submodule...${NC}"
    if [[ ! -d "qml-box2d" ]] || [[ ! "$(ls -A qml-box2d)" ]]; then
        echo -e "${YELLOW}⚠️ Initializing qml-box2d submodule...${NC}"
        git submodule update --init --recursive
    else
        echo -e "${GREEN}✓ qml-box2d submodule is ready${NC}"
    fi
}

# Main execution
main() {
    local platform=$(detect_platform)
    
    if [[ "$platform" == "unknown" ]]; then
        echo -e "${RED}❌ Unsupported platform${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Detected platform: $platform${NC}"
    
    check_dependencies "$platform"
    setup_environment "$platform"
    check_submodules
    configure_cmake "$platform"
    build_application "$platform"
    show_run_instructions "$platform"
}

# Show usage if help requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage: $0 [BUILD_TYPE] [TARGET_PLATFORM]"
    echo ""
    echo "BUILD_TYPE:"
    echo "  Release (default)    - Optimized build"
    echo "  Debug               - Debug build with symbols"
    echo ""
    echo "TARGET_PLATFORM:"
    echo "  auto (default)      - Auto-detect platform"
    echo "  macos              - macOS desktop"
    echo "  linux              - Linux desktop"
    echo "  windows            - Windows desktop"
    echo "  ios                - iOS mobile"
    echo "  android            - Android mobile"
    echo ""
    echo "Examples:"
    echo "  $0                  # Auto-detect platform, Release build"
    echo "  $0 Debug            # Auto-detect platform, Debug build"
    echo "  $0 Release ios      # iOS Release build"
    echo "  $0 Debug android    # Android Debug build"
    exit 0
fi

# Run main function
main "$@"
