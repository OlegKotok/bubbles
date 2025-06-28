import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Bubbles 1.0
import Box2D 2.0

// Early import check for Qt5Compat.GraphicalEffects - will fail fast if Core5Compat is not available
import Qt5Compat.GraphicalEffects

Window {
    visible: true
    width: 1024
    height: 768
    title: qsTr("Bubbles")

    color: "black"

    // Check for Qt5Compat.GraphicalEffects at startup
    Component.onCompleted: {
        console.log("Application started successfully.")
        console.log("Qt5Compat.GraphicalEffects module is available.")
    }

    BubblesLayout {
        anchors.fill: parent
    }
}
