# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = customim

DEFINES += QT_VERSION_5

CONFIG += sailfishapp

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""

message($${DEFINES})

QT += dbus
QT += positioning

SOURCES += src/customim.cpp \
	src/custim.cpp
	
HEADERS += src/custim.h

OTHER_FILES += qml/customim.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    rpm/customim.spec \
    customim.desktop \
    qml/pages/aboutPage.qml \
    qml/data.xml \
    qml/customim.png \
    customim.png

