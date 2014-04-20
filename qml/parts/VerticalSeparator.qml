import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle /* Vertical separator line */
{
    property int hx: parent.width
    height: 6
    width: hx
    color: "Transparent"
    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle /* Horizontal separator */
    {
        rotation: 90
        anchors.centerIn: parent
        height: parent.hx
        width: 2
        gradient: Gradient
        {
            GradientStop { position: 0.0; color: "Transparent" }
            GradientStop { position: 0.5; color: Theme.secondaryColor }
            GradientStop { position: 1.0; color: "Transparent" }
        }
    }
}
