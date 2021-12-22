import QtQuick 2.2
import Box2DStatic 2.0
import "shared"

PhysicsItem {
    id: wall

    fixtures: Box {
        width: wall.width
        height: wall.height
        friction: 0.2
        restitution: 0.95
        density: 1000
    }
}
