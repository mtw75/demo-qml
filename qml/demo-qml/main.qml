import QtQuick 2.0
import Qt.labs.folderlistmodel 2.0
import "CubeView.js" as CubeView
import "Cube.js" as Cube
import "Util.js" as Util

Image {
    id: background
    source: "../../resources/icons/bg.png"

    Image {
        id: logo
        source: "../../resources/icons/logo01.png"
        anchors {
            top: background.top
            topMargin: 20
            left: background.left
            leftMargin: 10
        }
    }

    BorderImage {
        id: patientInfo
        source: "../../resources/icons/s.png"
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: logo.verticalCenter
        }

        width: 360; height: 78
        border.left: 38; border.top: 39
        border.right: 38; border.bottom: 39

        Text {
            id: text1
            anchors.horizontalCenter: patientInfo.horizontalCenter
            anchors.top: patientInfo.top
            anchors.topMargin: 5
            color: "#939393"
            text: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")
            font.pointSize: 16
        }

        Text {
            id: text2
            x: 27
            y: 36
            color: "#0254cd"
            text: "Mario Rossi"
            font.pixelSize: 28
        }

        Text {
            id: text3
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: text2.verticalCenter
            text: qsTr("Male, 35 yo")
            font.pixelSize: 16
        }
    }

    FolderListModel {
        id: topImagesDir
        folder: "../../resources/top"
        nameFilters: ["*.png"]
    }
    FolderListModel {
        id: sideImagesDir
        folder: "../../resources/side"
        nameFilters: ["*.png"]
    }
    FolderListModel {
        id: frontImagesDir
        folder: "../../resources/rear"
        nameFilters: ["*.png"]
    }

    Column {
        id: imageControls
        anchors {
            left: background.left
            leftMargin: 10
            right: view1.left
            rightMargin: 10
            top: background.top
            topMargin: 100
        }
        spacing: 20
        Knob {
            id: brightnessKnob
            label: "Brigthness"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Knob {
            id: contrastKnob
            label: "Contrast"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Column {
        anchors {
            bottom: view1.bottom
            left: background.left
            leftMargin: 10
            right: view1.left
            rightMargin: 10
        }

        Pad {
            anchors.horizontalCenter: parent.horizontalCenter
            onTopClicked: cube.selectCubeFace(Cube.TOP)
            onLeftClicked: cube.selectCubeFace(Cube.LEFT)
            onBottomClicked: cube.selectCubeFace(Cube.BOTTOM)
            onRightClicked: cube.selectCubeFace(Cube.RIGHT)
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Rotation")
            font.pixelSize: 16
            color: "#939393"
        }
    }

    Image {
        id: view1

        source: "../../resources/icons/bigbox.png"
        anchors {
            top: background.top
            topMargin: 100
            left: background.left
            leftMargin: 150
        }
        clip: true

        CubeView {
            id: cube
            anchors.fill: parent
            topImagesDir: topImagesDir
            sideImagesDir: sideImagesDir
            frontImagesDir: frontImagesDir
            currentView: CubeView.TOP
            currentIndex: 0.5

            brightness: brightnessKnob.percentage
            contrast: contrastKnob.percentage

            onViewUpdateRequest: {
                var viewports = [view2, view3]

                for (var v = 0; v < 2; v++) {
                    if (viewports[v].currentView === currView) {
                        viewports[v].currentView = prevView
                        viewports[v].image = image
                    }
                }
            }
        }
    }

    Image {
        source: "../../resources/icons/bigbox_bg.png"
        anchors.centerIn: view1
        anchors.verticalCenterOffset: 2
        z: view1.z - 1
    }

    Column {
        anchors {
            top: background.top
            right: background.right
            topMargin: 100
            rightMargin: 50
        }
        spacing: 18

        Row {
            spacing: 20
            ImageView {
                id: view2
                currentView: CubeView.SIDE
                image: Util.getImgFile(sideImagesDir, cube.currentIndex)
            }

            HorizontalLaser {
                visible: false
                anchors.verticalCenter: view2.verticalCenter
                percentage: .3
                //onPercentageChangedByUser: console.log("percentage changed: " + newPercentage)
            }
        }

        VerticalLaser {
            z:1
            cursorOnTop: false
            anchors.left: parent.left
            anchors.leftMargin: 14.5
        }

        Row {
            spacing: 20
            ImageView {
                id: view3
                currentView: CubeView.FRONT
                image: Util.getImgFile(frontImagesDir, cube.currentIndex)
            }

            HorizontalLaser {
                anchors.verticalCenter: view3.verticalCenter
                percentage: .5
            }
        }
    }

    Item {
        id: markersArea
        anchors {
            bottom: parent.bottom
            bottomMargin: 6
            left: parent.left
            leftMargin: 10
            right: parent.right
        }
        height: 78

        BorderImage {
            id: markersInfo
            source: "../../resources/icons/s.png"

            width: 910;
            border.left: 38; border.top: 39
            border.right: 38; border.bottom: 39
            opacity: 1
        }

        Image {
            opacity: markersInfo.opacity
            source: "../../resources/icons/s.png"
            anchors {
                verticalCenter: markersInfo.verticalCenter
                right: parent.right
                rightMargin: 10
            }

            Button {
                icon: "../../resources/icons/add.png"
                anchors.centerIn: parent
                onClicked: markersArea.state = "editMarker"
            }
        }

        Image {
            id: markerDescription
            source: "../../resources/icons/descrizione_bg.png"
            opacity: 0

            TextInput {
                visible: markersArea.state == "editMarker"
                anchors.fill: parent
                text: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
                font.pixelSize: 16
                wrapMode: TextInput.WordWrap
                color: "#939393"
            }
        }

        BorderImage {
            source: "../../resources/icons/s.png"

            anchors {
                left: markerDescription.right
                leftMargin: 10
                right: parent.right
                rightMargin: 10
            }

            border.left: 38; border.top: 39
            border.right: 38; border.bottom: 39
            opacity: markerDescription.opacity

            Row {
                visible: markersArea.state == "editMarker"
                spacing: 15
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 10
                }

                Button {
                    icon: "../../resources/icons/001.png"
                }
                Button {
                    icon: "../../resources/icons/002.png"
                    onClicked: markersArea.state = ""
                }
                Button {
                    icon: "../../resources/icons/003.png"
                }
                Button {
                    icon: "../../resources/icons/004.png"
                }
            }
        }

        states: State {
            name: "editMarker"
            PropertyChanges { target: markersInfo; opacity: 0 }
            PropertyChanges { target: markerDescription; opacity: 1 }
        }

        transitions: Transition {
            SequentialAnimation {
                NumberAnimation { target: markersInfo; property: "opacity"; duration: 200 }
                NumberAnimation { target: markerDescription; property: "opacity"; duration: 200 }
            }
        }
    }



    KeyboardLauncher {
        id: kbdLauncher
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
        width: parent.width
        height: parent.height / 2
    }
}
