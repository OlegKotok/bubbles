# Bubbles - Qt6 Physics-Based Application

A Qt6 QML application featuring physics-based bubbles using Box2D physics engine.

## System Requirements

- macOS 10.15 Catalina or later
- Xcode Command Line Tools
- Qt6 (6.5 or later recommended)
- CMake 3.24 or later
- Git

## Quick Start (Recommended)

### One-Command Setup and Build

For a completely automated setup and build process:

```bash
# Clone the repository
git clone <repository-url>
cd bubbles

# Run automated setup (installs all dependencies)
./setup.sh

# Or just build (if dependencies are already installed)
./build.sh
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
└── qml-box2d/             # Box2D physics engine (submodule)
```

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
