# Bubbles - Qt6 Physics-Based Application

A Qt6 QML application featuring physics-based bubbles using Box2D physics engine with comprehensive cross-platform support and automated CI/CD pipeline.

## Supported Platforms

This application supports building and deployment across multiple platforms:
- **Desktop**: Linux, macOS, Windows
- **Mobile**: iOS, Android
- **Web**: WebAssembly (via Emscripten) with GitHub Pages deployment

## CI/CD Pipeline Features

Our GitHub Actions workflow provides:
- ✅ **Automated multi-platform builds** for Linux, macOS, and Windows
- ✅ **Caching optimizations** for Qt, CMake, and vcpkg dependencies
- ✅ **Automated testing** with CTest integration
- ✅ **Fail-fast validation** of submodules and dependencies
- ✅ **Release automation** with GitHub Releases
- ✅ **Artifact packaging** (AppImage, DMG, ZIP)
- 🔜 **Code signing** for Windows binaries
- 🔜 **Notarization** for macOS DMG files

## System Requirements

- macOS 10.15 Catalina or later
- Xcode Command Line Tools
- Qt6 (6.5 or later recommended)
- CMake 3.24 or later
- Git

## Quick Start

### One-Command Run (Recommended)
For the quickest way to build and run the application:
```bash
./bubbles.sh
```

Or remotely:
```bash
curl -sSL <repo>/bubbles.sh | bash
```

The `bubbles.sh` script will:
1. Build the application (or reuse cache if already built)
2. Automatically detect the platform and build directory
3. Run the application immediately

### Universal Build Script
For more control over the build process, use the universal build script:
```bash
./build-universal.sh [BUILD_TYPE] [TARGET_PLATFORM]
```

Examples:
```bash
./build-universal.sh                    # Auto-detect platform, Release build
./build-universal.sh Debug              # Auto-detect platform, Debug build
./build-universal.sh Release ios        # iOS Release build
./build-universal.sh Debug android      # Android Debug build
```

### Platform-Specific Setup

#### macOS
```bash
./setup-mac.sh      # Install dependencies and build
# OR
./build-mac.sh      # Build only (if dependencies exist)
```

#### Windows
```powershell
# Run in PowerShell as Administrator
.\setup-windows.ps1
```

#### Linux
```bash
./setup-linux.sh    # Auto-detects distribution (Ubuntu/Debian/Fedora/Arch)
```

#### iOS (requires macOS + Qt6 with iOS support)

**Important**: Homebrew Qt6 does not include iOS support. You need to install Qt6 from the official Qt installer.

```bash
# Option 1: Use dedicated iOS build script (recommended)
./build-ios.sh

# Option 2: Use universal script (requires Qt6 with iOS support)
./build-universal.sh Release ios
```

**iOS Setup Requirements**:
1. Download Qt6 from https://www.qt.io/download
2. Run the Qt Installer
3. Select Qt 6.x.x with iOS component
4. Install Xcode from App Store
5. Run `./build-ios.sh` - it will detect Qt6 iOS installation and create Xcode project

#### Android (requires Android SDK/NDK)
```bash
export ANDROID_HOME=/path/to/android/sdk
export ANDROID_NDK_ROOT=/path/to/android/ndk
./build-universal.sh Release android
```

#### WebAssembly (GitHub Pages Deployment)

The project supports automatic WebAssembly compilation and deployment to GitHub Pages!

**Automatic Deployment:**
1. Push to `main` branch triggers WebAssembly build
2. The built app is automatically deployed to GitHub Pages
3. Access your app at: `https://username.github.io/bubbles`

**Manual Local WebAssembly Build:**
```bash
# Install Emscripten (one-time setup)
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install 3.1.50
./emsdk activate 3.1.50
source ./emsdk_env.sh
cd ..

# Install Qt6 WebAssembly (one-time setup)
pip3 install aqtinstall
mkdir -p qt6-wasm
cd qt6-wasm
aqt install-qt linux desktop 6.5.2 wasm_multithread -m qt5compat qtshadertools
cd ..

# Build for WebAssembly
export QT_ROOT="$(pwd)/qt6-wasm/6.5.2/wasm_multithread"
source emsdk/emsdk_env.sh
mkdir -p build-wasm
cd build-wasm
emcmake cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$QT_ROOT"
cmake --build . --parallel $(nproc)

# Serve locally for testing
python3 -m http.server 8000
# Open http://localhost:8000/BubblesApp.html
```

**GitHub Pages Setup (One-time):**
1. Go to your repository Settings
2. Scroll to "Pages" section
3. Source: "GitHub Actions"
4. That's it! Push to main branch to deploy

### One-Command Setup and Build

For a completely automated setup and build process:

```bash
# Clone the repository
git clone <repository-url>
cd bubbles

# Run automated setup (installs all dependencies)
./setup-mac.sh

# Or just build (if dependencies are already installed)
./build-mac.sh
```

That's it! The application will be built and ready to run.

### Running the Application

```bash
# After build completes
cd build/macos-release
./BubblesApp
```

## Expected Behavior

- **Black 1024×768 window**
- **Ten initial bubbles** with avatar or placeholder images
- **Click to add bubbles**: Clicking adds 5 new bubbles at mouse position
- **Physics simulation**: All bubbles collide with walls and each other
- **Round clipping**: Bubbles rendered with GraphicalEffects mask

## Prerequisites for Clean macOS Installation

### 1. Install Xcode Command Line Tools
```bash
xcode-select --install
```

### 2. Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Required Dependencies
```bash
# Install Qt6
brew install qt@6

# Install CMake
brew install cmake

# Install Git (if not already available)
brew install git
```

### 4. Add Qt6 to PATH
Add these lines to your shell profile (`~/.zshrc` for zsh or `~/.bash_profile` for bash):
```bash
# Qt6 PATH
export PATH="/opt/homebrew/bin:$PATH"
export Qt6_DIR="/opt/homebrew/opt/qt@6/lib/cmake/Qt6"
export QT_PLUGIN_PATH="/opt/homebrew/opt/qt@6/plugins"
```

Reload your shell:
```bash
source ~/.zshrc  # for zsh
# or
source ~/.bash_profile  # for bash
```

## Building and Running the Application

### 1. Clone the Repository
```bash
git clone <repository-url>
cd bubbles
```

### 2. Initialize Git Submodules
The project uses the qml-box2d library as a submodule:
```bash
git submodule init
git submodule update
```

If the `qml-box2d` folder doesn't appear, manually clone it:
```bash
git clone https://github.com/qml-box2d/qml-box2d.git
```

### 3. Create Build Directory
```bash
mkdir -p build/macos-release
cd build/macos-release
```

### 4. Configure with CMake
```bash
cmake ../.. -DCMAKE_BUILD_TYPE=Release
```

### 5. Build the Application
```bash
make -j$(sysctl -n hw.ncpu)
```

### 6. Run the Application
```bash
./BubblesApp
```

## Development Build

For development with debug symbols:
```bash
mkdir -p build/macos-debug
cd build/macos-debug
cmake ../.. -DCMAKE_BUILD_TYPE=Debug
make -j$(sysctl -n hw.ncpu)
./BubblesApp
```

## Troubleshooting

### Qt6 Not Found
If CMake can't find Qt6, manually specify the Qt6 path:
```bash
cmake ../.. -DQt6_DIR=/opt/homebrew/opt/qt@6/lib/cmake/Qt6
```

### Build Errors
- Ensure the project path contains only Latin characters (no Cyrillic or special characters)
- Make sure all submodules are properly initialized
- Verify that Qt6 Core5Compat module is available:
  ```bash
  ls /opt/homebrew/opt/qt@6/lib/cmake/ | grep Core5Compat
  ```

### Runtime Errors
- Check that QML modules are properly registered
- Ensure Qt6 plugin path is correctly set in environment

### Apple Silicon vs Intel Macs
The CMakeLists.txt automatically detects your Mac's architecture:
- Apple Silicon Macs (M1/M2/M3): Uses `arm64`
- Intel Macs: Uses `x86_64`

No additional configuration is needed.

## Project Structure

```
bubbles/
├── .github/workflows/      # CI/CD pipeline configurations
│   ├── release.yml         # Multi-platform release workflow
│   └── web-asm.yml        # WebAssembly deployment
├── CMakeLists.txt          # Main build configuration
├── main.cpp                # Application entry point
├── main.qml                # Main QML interface
├── BubblesLayout.qml       # Layout component
├── Bubble.qml              # Individual bubble component
├── Wall.qml                # Wall physics component
├── shared/                 # Shared QML components
│   ├── BoxBody.qml
│   ├── CircleBody.qml
│   └── ...
├── images/                 # Application resources
│   ├── bubble1.png
│   ├── bubble2.png
│   └── avatar.jpg
├── platforms/              # Platform-specific configurations
│   ├── android/            # Android manifest and resources
│   └── ios/                # iOS Info.plist and resources
├── build-*.sh              # Platform-specific build scripts
├── setup-*.sh              # Platform setup scripts
└── qml-box2d/             # Box2D physics engine (submodule)
```

## Automated Releases

The project uses GitHub Actions for automated building and releasing:

1. **Push to main branch**: Triggers multi-platform builds with testing
2. **Create version tag** (e.g., `v1.0.0`): Triggers release creation with packaged artifacts
3. **Download releases**: Pre-built binaries available on GitHub Releases page

### Release Artifacts

- **Linux**: `Bubbles-v1.0.0-linux.tar.gz` (AppImage format)
- **macOS**: `Bubbles-v1.0.0-mac.dmg` (Disk Image)
- **Windows**: `Bubbles-v1.0.0-windows.zip` (Executable + DLLs)

## Development Workflow

### Quality Gates

The CI pipeline enforces several quality gates:

1. **Submodule validation**: Ensures all git submodules are properly initialized
2. **Build verification**: Multi-platform compilation with Ninja generator
3. **Automated testing**: CTest execution with output on failure
4. **Dependency caching**: Optimized build times with Qt, CMake, and vcpkg caching

## Dependencies

- **Qt6**: Core application framework
  - Qt6::Quick - QML engine
  - Qt6::QuickControls2 - UI controls
  - Qt6::Core5Compat - Compatibility layer (for GraphicalEffects)
- **qml-box2d**: Box2D physics engine integration for QML
- **CMake**: Build system

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]
