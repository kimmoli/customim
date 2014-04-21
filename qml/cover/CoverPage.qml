
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    Image
    {
         source: "../customim.png"
         anchors.centerIn: parent
         Label
         {
             anchors.bottom: parent.top
             anchors.bottomMargin: 15
             anchors.horizontalCenter: parent.horizontalCenter
             font.pixelSize: 30
             text: "Custom IM"
         }
     }
}


