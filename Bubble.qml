import QtQuick
import Box2D 2.0
import Qt5Compat.GraphicalEffects
import "shared"

PhysicsItem {
    id: bubble

    property int radius: 100
    property alias friction: circle.friction
    property alias restitution: circle.restitution
    property alias density: circle.density
    property bool isActive: false
    property alias avatar: avatar.source

    fixedRotation: false
    sleepingAllowed: false

    width: 200
    height: 200
    bodyType: Body.Dynamic

    property color color: "#EFEFEF"

    fixtures: Circle {
        id: circle
        radius: bubble.radius
        density: 0.5
    }

    Rectangle {
        id: rect
        anchors.centerIn: bubble
        height: bubble.radius * 2
        width: bubble.radius * 2
        radius: bubble.radius
        color: (avatar.status==Image.Ready)?"white":"#00FFFFFF"
        border.color: (bubble.isActive)?"green":"white"
        border.width: (avatar.status==Image.Ready)?2:0
        Image{
            anchors.fill: parent
            source: "qrc:/images/bubble1.png"
            fillMode: Image.PreserveAspectFit
            visible:  !(avatar.status==Image.Ready)
        }
        Image{
            id: avatar
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: ""
            visible: false
        }
        OpacityMask {
            anchors.margins: 2
            id: roundedPhoto
            anchors.fill: parent
            source: avatar
            maskSource: rect
            visible: (avatar.status==Image.Ready)
        }
    }

    MouseArea{
        anchors.fill: parent
        onReleased: {
            console.log(bubble.x+bubble.width/2, bubble.y+bubble.height/2);
            bubble.body.linearVelocity.x += mouseX / 10;
            bubble.body.linearVelocity.y += mouseY / 10;
        }
    }
}
