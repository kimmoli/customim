
import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow
{
    id: app

    property bool withLocation : false
    property bool updateRunning : false
    property bool coverUpdate : false
    property string yourMessage
    property string yourLocation


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
                app.withLocation = withLocation
                app.updateRunning = updateRunning
                app.yourMessage = yourMessage
                app.yourLocation = yourLocation
            }
            onWithLocationChanged: app.withLocation = withLocation
            onUpdateRunningChanged: app.updateRunning = updateRunning
            onYourMessageChanged: app.yourMessage = yourMessage
            onYourLocationChanged: app.yourLocation = yourLocation

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


