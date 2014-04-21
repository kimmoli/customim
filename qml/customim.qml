
import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow
{
    id: app

    property bool autoUpdate : false
    property bool updateRunning : false
    property bool coverUpdate : false

    initialPage: mainPage

    Component
    {
        id: mainPage

        MainPage
        {
            id: mp
            /* this was tricky */
            Component.onCompleted:
            {
                app.autoUpdate = autoUpdate
                app.updateRunning = updateRunning
            }
            onAutoUpdateChanged: app.autoUpdate = autoUpdate
            onUpdateRunningChanged: app.updateRunning = updateRunning

            coverUpdate: app.coverUpdate
        }
    }

    cover: CoverPage { id: coverPage }

    function updateLocation()
    {
        coverUpdate = true
        console.log("app.updateLocation()")
        coverUpdate = false
    }

}


