
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    id: coverPage

    Image
    {
         source: "../customim.png"
         anchors.centerIn: parent
         Label
         {
             anchors.bottom: parent.top
             anchors.bottomMargin: 15
             anchors.horizontalCenter: parent.horizontalCenter
             font.pixelSize: 25
             text: "Custom status"
         }
     }
     CoverActionList
     {
        id: coverActions
        enabled: app.autoUpdate && !app.updateRunning

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


