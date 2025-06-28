cmake_minimum_required(VERSION 3.24)

project(Bubbles LANGUAGES CXX)

# Dependency checking and validation
function(check_dependencies)
    # Check for required tools
    find_program(GIT_EXECUTABLE git)
    if(NOT GIT_EXECUTABLE)
        message(FATAL_ERROR "Git is required but not found. Please install git.")
    endif()
    
    # Check for submodules
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/qml-box2d/CMakeLists.txt")
        message(STATUS "qml-box2d submodule not found. Initializing...")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE GIT_SUBMOD_RESULT
        )
        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(FATAL_ERROR "git submodule update --init failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
        endif()
    endif()
    
    # Validate Qt6 installation
    if(NOT Qt6_FOUND)
        message(STATUS "Searching for Qt6 in common locations...")
        set(CMAKE_PREFIX_PATH 
            "/opt/homebrew/opt/qt@6"
            "/usr/local/opt/qt@6"
            "/usr/local/Qt-6*"
            "~/Qt/6*"
            ${CMAKE_PREFIX_PATH}
        )
    endif()
endfunction()

# Call dependency checking
check_dependencies()

# Enable native architecture for macOS (auto-detect)
if(APPLE AND NOT CMAKE_OSX_ARCHITECTURES)
    # Let CMake auto-detect the architecture
    # This will use arm64 on Apple Silicon and x86_64 on Intel Macs
endif()

# Set Qt policies to suppress warnings
if(POLICY CMP0151)
    cmake_policy(SET CMP0151 NEW)
endif()


# Platform detection and build options
if(ANDROID)
    set(BUILD_ANDROID ON)
elseif(IOS)
    set(BUILD_IOS ON)
elseif(WIN32)
    set(BUILD_WINDOWS ON)
elseif(UNIX AND NOT APPLE)
    set(BUILD_LINUX ON)
else()
    # Default to desktop build
endif()

# Manual platform override options
option(BUILD_ANDROID "Build for Android" ${BUILD_ANDROID})
option(BUILD_IOS "Build for iOS" ${BUILD_IOS})
option(BUILD_WINDOWS "Build for Windows" ${BUILD_WINDOWS})
option(BUILD_LINUX "Build for Linux" ${BUILD_LINUX})

# Set platform-specific configurations
if(BUILD_IOS)
    set(QT_QMAKE_TARGET_MKSPEC "macx-ios-clang")
    set(CMAKE_SYSTEM_NAME "iOS")
    if(NOT CMAKE_TOOLCHAIN_FILE)
        include("_toolchains/ios.cmake" OPTIONAL)
    endif()
elseif(BUILD_ANDROID)
    set(QT_QMAKE_TARGET_MKSPEC "android-clang")
    set(CMAKE_SYSTEM_NAME "Android")
    if(NOT CMAKE_TOOLCHAIN_FILE)
        include("_toolchains/android.cmake" OPTIONAL)
    endif()
elseif(BUILD_WINDOWS)
    set(QT_QMAKE_TARGET_MKSPEC "win32-msvc")
    set(CMAKE_SYSTEM_NAME "Windows")
    if(NOT CMAKE_TOOLCHAIN_FILE)
        include("_toolchains/windows.cmake" OPTIONAL)
    endif()
elseif(BUILD_LINUX)
    set(QT_QMAKE_TARGET_MKSPEC "linux-g++")
    set(CMAKE_SYSTEM_NAME "Linux")
    if(NOT CMAKE_TOOLCHAIN_FILE)
        include("_toolchains/linux.cmake" OPTIONAL)
    endif()
endif()

# Find Qt6 modules
set(QT_COMPONENTS Quick Qml Gui Core QuickControls2 Core5Compat)

# Add Multimedia for mobile platforms if needed
if(BUILD_IOS OR BUILD_ANDROID)
    list(APPEND QT_COMPONENTS Multimedia)
endif()

find_package(Qt6 REQUIRED COMPONENTS ${QT_COMPONENTS})

# Set Qt policies before standard setup
if(COMMAND qt_policy)
    qt_policy(SET QTP0001 NEW)  # Default QML resource prefix
    # Note: QTP0004 is not available in Qt 6.5.2, so we skip it
    # qt_policy(SET QTP0004 NEW)  # QML directory structure - not supported in this Qt version
endif()

# Standard Qt project setup
qt_standard_project_setup()

# Add qml-box2d subdirectory first (it exports a target)
add_subdirectory(qml-box2d)

# Define QML module for the application
qt_add_qml_module(bubbles
    URI Bubbles
    VERSION 1.0
    QML_FILES
        main.qml
        BubblesLayout.qml
        Bubble.qml
        Wall.qml
        shared/BoxBody.qml
        shared/ChainBody.qml
        shared/CircleBody.qml
        shared/EdgeBody.qml
        shared/ImageBoxBody.qml
        shared/PhysicsItem.qml
        shared/PolygonBody.qml
        shared/RectangleBoxBody.qml
        shared/ScreenBoundaries.qml
)

# Create executable target
qt_add_executable(BubblesApp)

# Enable app bundle for macOS
if(APPLE AND NOT BUILD_IOS)
    set_target_properties(BubblesApp PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/Info.plist"
        MACOSX_BUNDLE_BUNDLE_NAME "BubblesApp"
        MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
        MACOSX_BUNDLE_IDENTIFIER "com.example.bubbles"
    )
endif()

# Add main.cpp to the executable
target_sources(BubblesApp PRIVATE main.cpp)

# Add separate resource compilation with correct prefix
qt_add_resources(BubblesApp "images"
    PREFIX "/"
    FILES
        images/avatar.jpg
        images/bubble1.png
        images/bubble2.png
)

# Add include directory for Box2D plugin headers
target_include_directories(BubblesApp PRIVATE qml-box2d)

# Link libraries
target_link_libraries(BubblesApp PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Core5Compat
    qmlbox2d
    bubbles
)

# Add Multimedia library for mobile platforms
if(BUILD_IOS OR BUILD_ANDROID)
    target_link_libraries(BubblesApp PRIVATE Qt6::Multimedia)
endif()

# Installation and deployment rules
if(BUILD_ANDROID OR BUILD_IOS)
    # Set deployment output directory
    set(QT_DEPLOYMENT_OUTPUT "${CMAKE_BINARY_DIR}/deploy")
    
    # Generate deployment for QML app
    qt_generate_deploy_qml_app_script(
        TARGET BubblesApp
        OUTPUT_SCRIPT deploy_script
        MACOS_BUNDLE_POST_BUILD
        NO_UNSUPPORTED_PLATFORM_ERROR
        DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    )
    
    # Install the application
    install(TARGETS BubblesApp
        BUNDLE DESTINATION .
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
    )
    
    # Install deployment script
    install(SCRIPT ${deploy_script})
else()
    # Standard installation for desktop platforms
    install(TARGETS BubblesApp
        BUNDLE DESTINATION .
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
    )
endif()

# Platform-specific configurations
if(BUILD_IOS)
    set_target_properties(BubblesApp PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/platforms/ios/Info.plist"
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.example.bubbles"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    )
elseif(BUILD_ANDROID)
    set_target_properties(BubblesApp PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/platforms/android"
        QT_ANDROID_TARGET_SDK_VERSION "31"
        QT_ANDROID_MIN_SDK_VERSION "21"
    )
endif()
