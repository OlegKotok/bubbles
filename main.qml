import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5

Window {
    visible: true
    width: 1024
    height: 768
    title: qsTr("Bubles")

    color: "black"


    BubblesLayout{
        anchors.fill: parent
    }
}
