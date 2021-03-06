import QtQuick 2.0
import "Cube.js" as Cube
Item {
    id: cube

    property alias frontFaceLoader: frontFaceLoader
    property alias rightFaceLoader: rightFaceLoader
    property alias leftFaceLoader: leftFaceLoader
    property alias topFaceLoader: topFaceLoader
    property alias bottomFaceLoader: bottomFaceLoader

    property int rotationDirection: 0
    property real rotationPosition: 0

    signal faceSelected(int face)

    function initRotation(mousePos) {
        Cube.initRotation(mousePos)
    }

    function rotate(mousePos) {
        return Cube.rotate(mousePos)
    }

    function animate(mousePos) {
        Cube.animate(mousePos)
    }

    function goToFace(cubeFace) {
        Cube.selectedFace = cubeFace
        var state = ""
        var direction = 0
        var orientation = 0

        switch(Cube.selectedFace) {
        case Cube.LEFT:
            direction = Cube.DIRECTION_X
            orientation = Cube.ORIENTATION_POSITIVE
            state = "showLeftFace"
            break

        case Cube.TOP:
            direction = Cube.DIRECTION_Y
            orientation = Cube.ORIENTATION_NEGATIVE
            state = "showTopFace"
            break

        case Cube.RIGHT:
            direction = Cube.DIRECTION_X
            orientation = Cube.ORIENTATION_NEGATIVE
            state = "showRightFace"
            break

        case Cube.BOTTOM:
            direction = Cube.DIRECTION_Y
            orientation = Cube.ORIENTATION_POSITIVE
            state = "showBottomFace"
            break
        default:
            return
        }

        rotationDirection = direction
        // make sure we first init the rotation and then change state
        Cube.setFrontFaceRotation(direction, orientation)
        container.state = state
    }

    function finishRotation(mousePos) {
        Cube.selectedFace = Cube.finishRotation(mousePos)

        switch(Cube.selectedFace) {
        case Cube.FRONT:
            container.state = "showFrontFace"
            break

        case Cube.LEFT:
            container.state = "showLeftFace"
            break

        case Cube.TOP:
            container.state = "showTopFace"
            break

        case Cube.RIGHT:
            container.state = "showRightFace"
            break

        case Cube.BOTTOM:
            container.state = "showBottomFace"
        }
    }

    Item {
        id: container
        anchors.fill: parent

        Item {
            id: frontFaceContainer
            width: parent.width
            height: parent.height

            Loader { id: frontFaceLoader; anchors.fill: parent }

            transform: Rotation { id: frontFaceRot; axis.z: 0 }
            onXChanged: rotationPosition = x
            onYChanged: rotationPosition = y
        }

        Item {
            id: rightFaceContainer
            anchors.left: frontFaceContainer.right
            width: parent.width
            height: parent.height

            Loader { id: rightFaceLoader; anchors.fill: parent }

            transform: Rotation {
                id: rightFaceRot
                axis { y: 1; z: 0 }
                angle: 90
                origin { x: 0; y: height/2 }
            }
        }

        Item {
            id: leftFaceContainer
            anchors.right: frontFaceContainer.left
            width: parent.width
            height: parent.height

            Loader {
                id: leftFaceLoader
                anchors.fill: parent
            }

            transform: Rotation {
                id: leftFaceRot
                axis { y: 1; z: 0 }
                angle: 270
                origin { x: width; y: height/2 }
            }
        }

        Item {
            id: topFaceContainer
            anchors.bottom: frontFaceContainer.top
            width: parent.width
            height: parent.height

            Loader {
                id: topFaceLoader
                anchors.fill: parent
            }

            transform: Rotation {
                id: topFaceRot
                axis { x: 1; y: 0; z: 0 }
                angle: 90
                origin { x: width / 2; y: height }
            }
        }

        Item {
            id: bottomFaceContainer
            anchors.top: frontFaceContainer.bottom
            width: parent.width
            height: parent.height

            Loader {
                id: bottomFaceLoader
                anchors.fill: parent
            }

            transform: Rotation {
                id: bottomFaceRot
                axis { x: 1; y: 0; z: 0 }
                angle: 270
                origin { x: width / 2; y: 0 }
            }
        }

        states: [
            State {
                name: "showFrontFace"
                PropertyChanges { target: frontFaceRot; angle: 0 }
                PropertyChanges { target: frontFaceContainer; x: 0; y: 0}

                PropertyChanges { target: rightFaceRot; angle: 90 }
                PropertyChanges { target: rightFaceContainer; x: 0 }

                PropertyChanges { target: leftFaceRot; angle: 270 }
                PropertyChanges { target: leftFaceContainer; x: 0 }

                PropertyChanges { target: topFaceRot; angle: 90 }
                PropertyChanges { target: topFaceContainer; y: 0 }

                PropertyChanges { target: bottomFaceRot; angle: 270 }
                PropertyChanges { target: bottomFaceContainer; y: 0 }
            },

            State {
                name: "showLeftFace"
                PropertyChanges { target: frontFaceRot; angle: 90 }
                PropertyChanges { target: frontFaceContainer; x: width }
                PropertyChanges { target: leftFaceRot; angle: 360 }
                PropertyChanges { target: leftFaceContainer; x: 0 }
            },

            State {
                name: "showRightFace"
                PropertyChanges { target: frontFaceRot; angle: -90 }
                PropertyChanges { target: frontFaceContainer; x: -width }
                PropertyChanges { target: rightFaceRot; angle: 0 }
                PropertyChanges { target: rightFaceContainer; x: -width }
            },

            State {
                name: "showTopFace"
                PropertyChanges { target: frontFaceRot; angle: -90 }
                PropertyChanges { target: frontFaceContainer; y: height }
                PropertyChanges { target: topFaceRot; angle: 0 }
                PropertyChanges { target: topFaceContainer; y: height}
            },

            State {
                name: "showBottomFace"
                PropertyChanges { target: frontFaceRot; angle: 90 }
                PropertyChanges { target: frontFaceContainer; y: -height }
                PropertyChanges { target: bottomFaceRot; angle: 360 }
                PropertyChanges { target: bottomFaceContainer; y: -height}
            }

        ]

        transitions: [
            Transition {
                SequentialAnimation {
                    PropertyAnimation { properties: "angle,x,y"; duration: 150 }
                    ScriptAction {
                        script: {
                            cube.faceSelected(Cube.selectedFace)
                        }
                    }
                }
            }
        ]
    }
}
