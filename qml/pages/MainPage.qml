
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.0
import QtQuick.XmlListModel 2.0
import customim.CustIM 1.0

Page
{
    id: mainPage

    property alias autoUpdate : posOn.checked
    property bool updateRunning : true

    property bool showEm: false
    property bool firstRun: true
    property int selText: custim.textType

    property bool coverUpdate : false

    onCoverUpdateChanged:
        if (coverUpdate)
        {
            console.log("Cover requested update")
            updateRunning = true
            pos.update()
        }

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
                                          { "version": custim.version,
                                              "year": "2014",
                                              "name": "Custom IM status",
                                              "imagelocation": "../customim.png"} )
            }
        }

        contentHeight: column.height

        Column
        {
            id: column

            width: mainPage.width
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
                    custim.updateImStatus(imStatus.text, posOn.checked, addToStatus.text, selText)
                    focus = false
                }
            }

            SectionHeader
            {
                text: "Position information"
            }

            Row
            {
                width: parent.width
                spacing: Theme.paddingSmall

                TextSwitch
                {
                    id: posOn
                    checked: custim.addLocation
                    width: (parent.width - Theme.paddingSmall) / 2
                    text: "Add location"
                    description: "Get GPS location"
                    onCheckedChanged:
                    {
                        showEm = false
                        autoUpdate.checked = false
                        addToStatus.text = "Wait..."
                        if (checked)
                        {
                            updateRunning = true
                            pos.update()
                        }
                    }
                    onClicked:  /* If clicked to disable, update status to remove location, and to store changed setting */
                        if (!checked)
                            custim.updateImStatus(imStatus.text, posOn.checked, addToStatus.text, selText)
                }

                TextSwitch
                {
                    id: autoUpdate
                    visible: posOn.checked
                    width: (parent.width - Theme.paddingSmall) / 2
                    checked: false
                    text: "Auto refresh"
                    description: "Update every 15 min"
                }
            }

            SectionHeader
            {
                text: "Current location"
                visible: showEm
            }

            Label
            {
                id: addToStatus
                visible: posOn.checked && text === "Wait..."
                x: Theme.paddingLarge
                height: Theme.itemSizeSmall
                font.pixelSize: Theme.fontSizeMedium
                text: "Wait..."
            }

            Timer
            {
                running: autoUpdate.checked
                repeat: true
                interval: 10000 // 900000
                onTriggered:
                {
                    updateRunning = true
                    pos.update()
                }
            }

            XmlListModel
            {
                /* uses google geocoding reverse api to get some details about your location */
                id: locationParser

                source: "https://maps.googleapis.com/maps/api/geocode/xml?latlng=" + pos.position.coordinate.latitude +
                        "," + pos.position.coordinate.longitude + "&sensor=true"

                query: "/GeocodeResponse/result"

                XmlRole
                {
                    name: "formatted_address";
                    query: "formatted_address/string()"
                }

                onStatusChanged:
                {
                    if (status == XmlListModel.Ready)
                    {
                        if (!firstRun || posOn.checked)
                        {
                            addToStatus.text = locationParser.get(selText).formatted_address
                            custim.updateImStatus(imStatus.text, posOn.checked, addToStatus.text, selText)
                            console.log(source)
                        }
                        firstRun = false
                        updateRunning = false
                    }
                }
            }

            Repeater
            {
                model: locationParser

                BackgroundItem
                {
                    visible: showEm
                    width: column.width - (2 * Theme.paddingLarge)
                    height: Theme.itemSizeSmall
                    x: Theme.paddingLarge

                    onClicked:
                    {
                        selText = index
                        addToStatus.text = formatted_address
                        custim.updateImStatus(imStatus.text, posOn.checked, addToStatus.text, selText)
                    }

                    Label
                    {
                        visible: showEm
                        width: parent.width
                        text: formatted_address
                        color: (index == selText) ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.centerIn: parent
                    }
                }
            }

        }

    }

    CustIM
    {
        id: custim
        onTextTypeChanged:
            selText = custim.textType
    }
}


