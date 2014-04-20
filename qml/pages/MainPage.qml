
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.0
import QtQuick.XmlListModel 2.0
import customim.CustIM 1.0
import "../parts"

Page
{
    id: page

    property bool showEm: false
    property int selectedText: 0

    PositionSource
    {
        id: pos
        updateInterval: 1000
        active: false
        onPositionChanged:
        {
            if (posOn.checked)
                showEm = true
            locationParser.reload()
        }
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
            spacing: Theme.paddingSmall
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
                text: "Add location"
                description: "Get GPS location"
                onClicked:
                {
                    showEm = false
                    autoUpdate.checked = false
                    addToStatus.text = "Wait..."
                    if (checked)
                        pos.update()
                }
            }

            TextSwitch
            {
                visible: posOn.checked
                id: autoUpdate
                x: Theme.paddingLarge
                checked: false
                text: "Auto refresh"
                description: "Update every 15 min"
            }


            Label
            {
                id: addToStatus
                visible: posOn.checked
                x: Theme.paddingLarge
                color: enabled ? Theme.primaryColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium

                text: showEm ? "Select below" : "Wait..."
            }
            Timer
            {
                running: autoUpdate.checked
                repeat: true
                interval: 10000 /* testing, change to 900000 */
                onTriggered:
                {
                    pos.update()
                }
            }

            XmlListModel
            {
                    id: locationParser

                    source: "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + pos.position.coordinate.latitude +
                            "," + pos.position.coordinate.longitude + "&sensor=true"

                    query: "/GeocodeResponse/result"

                    XmlRole
                    {
                        name: "formatted_address";
                        query: "formatted_address/string()"
                    }

                    onStatusChanged:
                        if (status == XmlListModel.Ready)
                        {
                            addToStatus.text = locationParser.get(selectedText).formatted_address
                            if (autoUpdate.checked)
                                custim.updateImStatus(imStatus.text, posOn.checked, addToStatus.text)
                        }

            }

            VerticalSeparator
            {
                visible: showEm
            }

            Repeater
            {
                model: locationParser

                BackgroundItem
                {
                    visible: showEm
                    width: column.width - (2 * Theme.paddingLarge)
                    height: Theme.itemSizeSmall
                    onClicked:
                    {
                        selectedText = index
                        addToStatus.text = formatted_address
                    }
                    x: Theme.paddingLarge
                    Label
                    {
                        visible: showEm
                        width: parent.width
                        text: formatted_address
                        color: (index == selectedText) ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.centerIn: parent
                    }
                }
            }

            VerticalSeparator
            {
                visible: showEm
            }
        }

    }

    CustIM
    {
        id: custim
    }
}


