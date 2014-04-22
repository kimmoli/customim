
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.0
import QtQuick.XmlListModel 2.0
import customim.CustIM 1.0

Page
{
    id: mainPage

    property alias withLocation : posOn.checked
    property bool updateRunning : true
    property alias yourMessage : imStatus.text
    property alias yourLocation : addToStatus.text

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
                spacing: 0

                TextSwitch
                {
                    id: posOn
                    checked: custim.addLocation
                    width: parent.width / 2 - Theme.paddingMedium
                    text: "Add location"
                    description: "Get GPS location"
                    rightMargin: Theme.paddingSmall

                    onCheckedChanged:
                    {
                        showEm = false
//                        autoUpdate.checked = false
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
                    width: parent.width / 2 + Theme.paddingMedium
                    checked: (refreshConfig.currentIndex > 0)
                    text: "Refresh"
                    description: refreshConfig.label + refreshConfig.value
                    rightMargin: Theme.paddingSmall
                    automaticCheck: false

                    onDownChanged:
                    {
                        if (down)
                            longPress.restart()
                        else
                        {
                            if (longPress.running)
                            {
                                /* Just refresh */
                                longPress.stop()
                                addToStatus.text = "Wait..."
                                updateRunning = true
                                pos.update()
                            }
                        }
                    }

                    PropertyAnimation
                    {
                        /* This mimics press and hold thing */
                        id: longPress;
                        target: refreshConfig;
                        property: "visible";
                        to: !refreshConfig.visible;
                        duration: 1000;
                    }
                }
            }

            ComboBox
            {
                id: refreshConfig
                visible: false
                label: "Auto refresh  "
                onStateChanged:
                {
                    /* autohide after selection done - didn't find better way */
                    if (state != "anonymousState1")
                    {
                        visible = false
                        refreshTimer.restart()
                    }
                }

                menu: ContextMenu
                {
                    MenuItem { text: "Off" }
                    MenuItem { text: "5 min" }
                    MenuItem { text: "15 min" }
                    MenuItem { text: "30 min" }
                }

            }

            SectionHeader
            {
                text: "Current location"
                visible: posOn.checked
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
                id: refreshTimer
                running: autoUpdate.checked
                repeat: true
                interval:
                {
                    if (refreshConfig.currentIndex === 1)
                        return 300000
                    else if (refreshConfig.currentIndex === 2)
                        return 900000
                    else if (refreshConfig.currentIndex === 2)
                        return 1800000
                    else
                        return 60000
                }

                onTriggered:
                {
                    addToStatus.text = "Wait..."
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
                    visible: showEm && (addToStatus.text != "Wait...")
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


