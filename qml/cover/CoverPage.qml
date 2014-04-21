
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    id: coverPage

    Image
    {
        id: cim
        source: "../customim.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 60

        Label
        {
            anchors.bottom: parent.top
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeSmall
            text: "Custom status"
        }
    }

    Label
    {
        id: ym
        anchors.top: cim.bottom
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeTiny
        text: app.yourMessage
        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
    }
    Label
    {
        visible: app.withLocation
        anchors.top: ym.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeTiny
        text: app.updateRunning ? "Updating..." : app.yourLocation
        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
    }


     CoverActionList
     {
        id: coverActions
        enabled: app.withLocation && !app.updateRunning

        CoverAction {
            id: coverAction
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered:
            {
                app.updateLocation()
            }
        }
    }

}


