import QtQuick
import QtQuick.Window
import Box2D 2.0
import "shared"

Item {
    id: root;
    width: 800
    height: 600
    visible: true

    property int borderWidth: 5

    World {
        id: physicsWorld

        gravity.x: 0
        gravity.y: 0.2
    }

    //Creating new bubbles
    MouseArea{
        anchors.fill: parent
        z: -1
        onClicked: {
            console.log("click");
            for (var i = 0; i < 5; i++){
                var cp = Qt.createComponent("Bubble.qml");
                var sprite = cp.createObject(root, {});
                sprite.radius = 25 + Math.random() * 75;
                sprite.linearVelocity.x = Math.random()*8 - 4;
                sprite.linearVelocity.y = Math.random()*8 - 4.5;
                sprite.friction = 0.15;
                sprite.restitution = 0.98;
                sprite.density = 2 + Math.random() * 2;
                sprite.avatar = ""
                sprite.x = mouseX - sprite.radius;
                sprite.y = mouseY - sprite.radius;
            }
        }
    }

    //******* *bubles ********//
    Repeater {
        id: bubbleRepetor
        model: 10

        Bubble{
            radius: 25 + Math.random() * 50
            linearVelocity.x: Math.random()*8 - 4
            linearVelocity.y: Math.random()*8 - 4.5
            friction: 0.15
            restitution: 0.98
            density: 2 + Math.random() * 2
            avatar: (index%2===0)?"qrc:/images/avatar.jpg":""
            x: root.width/2 - radius + Math.random()*root.width/2 - root.width/4
            y: root.height/2 - radius + Math.random()*root.height/2 - root.height/4
        }
    }
    //******* *bubles ********/


    //**** screen borders
    Wall {
        id: wall1
        height: root.borderWidth
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }
    Wall {
        id: wall2
        height: root.borderWidth
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
    Wall {
        id: wall3
        height: root.borderWidth
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
    }
    Wall {
        id: wall4
        height: root.borderWidth
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
    }

    // DebugDraw {
    //     id: debugDraw
    //     world: physicsWorld
    //     opacity: 1
    //     visible: false
    // }

}
