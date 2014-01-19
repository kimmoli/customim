#include "custim.h"
#include <QSettings>
#include <QCoreApplication>
#include <QtDBus/QtDBus>

struct SimplePresence
{
        unsigned type;
        QString status;
        QString message;
};
Q_DECLARE_METATYPE(SimplePresence)
QDBusArgument &operator<<(QDBusArgument &argument, const SimplePresence &mystatus)
{
        argument.beginStructure();
        argument << mystatus.type;
        argument << mystatus.status;
        argument << mystatus.message;
        argument.endStructure();

        return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &argument, SimplePresence &mystatus)
{
        argument.beginStructure();
        argument >> mystatus.type;
        argument >> mystatus.status;
        argument >> mystatus.message;
        argument.endStructure();

        return argument;
}

CustIM::CustIM(QObject *parent) :
    QObject(parent)
{
    m_var = "";
    qDBusRegisterMetaType<SimplePresence>();
}

void CustIM::readInitParams()
{
    QSettings settings;
    m_var = settings.value("var", "").toString();

    emit varChanged();
}

CustIM::~CustIM()
{
}


QString CustIM::readVar()
{
    return m_var;
}

void CustIM::writeVar(QString s)
{
    m_var = s;

    emit varChanged();
}

void CustIM::updateImStatus(QString message)
{
    unsigned type = 2;
    QString status = "Available";

    QDBusConnection bus = QDBusConnection::sessionBus();

         QDBusInterface *dbi, *dbi2;
         QDBusArgument a;
         SimplePresence ms;

        ms.type = type; // 3;
        ms.status = status; // "away";
        ms.message = message; // "Fishing.";

        dbi = new QDBusInterface("org.freedesktop.Telepathy.AccountManager", "/org/freedesktop/Telepathy/AccountManager", "", bus, this);
        QDBusReply<QDBusVariant> reply = dbi->call(QDBus::AutoDetect, "Get", "org.freedesktop.Telepathy.AccountManager", "ValidAccounts");

        if (reply.isValid()) {
                QDBusVariant validAccounts = reply.value();
                const QVariant var = validAccounts.variant();
                const QDBusArgument arg = var.value<QDBusArgument>();
                a << ms;

                arg.beginArray();
                while (!arg.atEnd()) {
                QDBusObjectPath opath;
                        arg >> opath;
                        dbi2 = new QDBusInterface("org.freedesktop.Telepathy.AccountManager", opath.path(), "org.freedesktop.DBus.Properties", bus, this);
                        dbi2->call(QDBus::AutoDetect, "Set", "org.freedesktop.Telepathy.Account", "RequestedPresence", /* a.asVariant()*/
                                           QVariant::fromValue(QDBusVariant(QVariant::fromValue(a))) );
                }
                arg.endArray();
        }
}
//void CustIM::updateImStatus(QString status)
//{

//    int n;


//    if (!QDBusConnection::sessionBus().isConnected()) {
//        qDebug( "Cannot connect to the D-Bus session bus.\n"
//                "To start it, run:\n"
//                "\teval `dbus-launch --auto-syntax`\n");
//        return;
//    }
//    else
//        qDebug("Connected to sessionBus");

//    QDBusInterface iface("org.freedesktop.Telepathy.AccountManager",
//                         "/org/freedesktop/Telepathy/AccountManager",
//                         "org.freedesktop.DBus.Properties",
//                         QDBusConnection::sessionBus());
//    if (iface.isValid())
//    {
//        qDebug("interface is valid");

//        QDBusMessage reply = iface.call("Get", "org.freedesktop.Telepathy.AccountManager","ValidAccounts");

//        qDebug() << reply;

//        QList<QVariant> outArgs = reply.arguments();
//        QVariant first = outArgs.at(0);
//        QDBusVariant dbvFirst = first.value<QDBusVariant>();
//        QVariant vFirst = dbvFirst.variant();
//        QDBusArgument dbusArgs = vFirst.value<QDBusArgument>();
//        qDebug() << "QDBusArgument current type is" << dbusArgs.currentType();

//        QDBusObjectPath path;

//        dbusArgs.beginArray();

//        while (!dbusArgs.atEnd())
//        {
//            dbusArgs >> path;
//            qDebug() << "path == " << path.path();
//            if (!(path.path().contains("/org/freedesktop/Telepathy/Account/ring/tel")))
//            {
//                qDebug("Processing this !!\n");
//                QDBusInterface ixface("org.freedesktop.Telepathy.AccountManager",
//                                     path.path(),
//                                     "org.freedesktop.DBus.Properties",
//                                     QDBusConnection::sessionBus());
//                if (ixface.isValid())
//                {
//                    qDebug("interface is valid");
//                    QDBusReply<QString> rr = ixface.call("Set", "org.freedesktop.Telepathy.Account" ,"RequestedPresence", quint32(2), "Online", "kukkuu");
//                    qDebug() << rr;

//                }


//            }
//            // append path to a vector here if you want to keep it
//        }
//        dbusArgs.endArray();




////        qDebug("Call failed: %s\n", qPrintable(reply.error().message()));
////        return;
//    }
//}

