
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.0
import QtQuick.XmlListModel 2.0
import customim.CustIM 1.0
import "../parts"

Page
{
    id: page

    PositionSource
    {
        id: pos
        updateInterval: 1000
        active: false
        onPositionChanged: locationParser.reload()
    }

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            MenuItem
            {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("aboutPage.qml"),
                                          { "version": custim.version, "year": "2014", "name": "Custom IM status" } )
            }
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: "Custom IM status"
            }

            TextField
            {
                id: imStatus
                visible: true
                placeholderText: "Here goes your status..."
                label: "Your status"
                text: custim.storedStatus
                inputMethodHints:  Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                width: parent.width - ( 2 * Theme.paddingLarge )
                anchors.horizontalCenter: parent.horizontalCenter

                EnterKey.enabled: text.length > 0
                EnterKey.text: "Set"
                EnterKey.onClicked:
                {
                    custim.updateImStatus(imStatus.text, posOn.checked, addToStatus.text)
                    focus = false
                }
            }

            SectionHeader
            {
                text: "Position information"
            }

            TextSwitch
            {
                id: posOn
                x: Theme.paddingLarge
                checked: false
                text: "GPS"
                description: "Position source control"
                onClicked:
                {
                    if (checked)
                        pos.update()
                }
            }

            Label
            {
                id: addToStatus
                visible: posOn.checked
                x: Theme.paddingLarge
                color: enabled ? Theme.primaryColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium

                text: "Select below"
            }

            XmlListModel
            {
                    id: locationParser

                    source: "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + pos.position.coordinate.latitude +
                            "," + pos.position.coordinate.longitude + "&sensor=true"

                    query: "/GeocodeResponse/result"

                    XmlRole { name: "formatted_address";    query: "formatted_address/string()" }
            }

            VerticalSeparator
            {
                visible: posOn.checked
            }

            Rectangle
            {
                visible: posOn.checked
                width: parent.width - (2 * Theme.paddingLarge)
                height: 3 * Theme.itemSizeSmall
                color: "Transparent"
                anchors.horizontalCenter: parent.horizontalCenter

                SilicaListView
                {
                    id: locationText
                    width: parent.width
                    height: parent.height
                    model: locationParser
                    anchors.topMargin: Theme.itemSizeSmall
                    clip: true
                    VerticalScrollDecorator {}

                    delegate: BackgroundItem
                    {
                        id: listItem
                        width: parent.width
                        height: Theme.itemSizeSmall
                        property string labelText : formatted_address
                        onClicked: addToStatus.text = labelText

                        Label
                        {
                            id: label
                            text: listItem.labelText
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }
            VerticalSeparator
            {
                visible: posOn.checked
            }
        }

    }

    CustIM
    {
        id: custim
    }
}


