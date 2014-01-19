
#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QtGlobal>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include <QQmlExtensionPlugin>
#include "custim.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationDomain("KimmoLi");
    QCoreApplication::setOrganizationName("KimmoLi");
    QCoreApplication::setApplicationName("customim");
    QCoreApplication::setApplicationVersion("0.1-1");

    qmlRegisterType<CustIM>("customim.CustIM", 1, 0, "CustIM");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/customim.qml"));
    view->show();

    return app->exec();
}

