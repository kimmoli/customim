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
QT += dbus

SOURCES += src/customim.cpp \
	src/custim.cpp
	
HEADERS += src/custim.h

OTHER_FILES += qml/customim.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    rpm/customim.spec \
    rpm/customim.yaml \
	customim.png \
    customim.desktop
