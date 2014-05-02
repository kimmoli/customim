#include "custim.h"
#include <QCoreApplication>
#include <QSettings>
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
    qDBusRegisterMetaType<SimplePresence>();

    readSettings();

    emit versionChanged();
}


CustIM::~CustIM()
{
}


QString CustIM::readVersion()
{
    return APPVERSION;
}

void CustIM::readSettings()
{
    QSettings s("kimmoli", "customim");

    s.beginGroup("settings");
    m_storedStatus = s.value("status", "First time here?").toString();
    m_textType = s.value("type", 0).toInt();
    m_addLocation = s.value("addLocation", false).toBool();
    s.endGroup();

    emit storedStatusChanged();
    emit textTypeChanged();
}

QString CustIM::readStoredStatus()
{
    return m_storedStatus;
}

int CustIM::readTextType()
{
    return m_textType;
}

bool CustIM::readAddLocation()
{
    return m_addLocation;
}


void CustIM::updateImStatus(QString message, bool addLocation, QString location, int textType)
{
    unsigned type = 2;
    QString status = "Available";

    QSettings s("kimmoli", "customim");

    m_storedStatus = message;
    m_textType = textType;
    m_addLocation = addLocation;

    s.beginGroup("settings");
    s.setValue("status", m_storedStatus);
    s.setValue("type", m_textType);
    s.setValue("addLocation", m_addLocation);
    s.endGroup();

    emit storedStatusChanged();
    emit textTypeChanged();
    emit addLocationChanged();

    QString fullMessage = (addLocation ? (message + " | " + location) : message);

    QDBusConnection bus = QDBusConnection::sessionBus();

         QDBusInterface *dbi, *dbi2;
         QDBusArgument a;
         SimplePresence ms;

        ms.type = type;
        ms.status = status;
        ms.message = fullMessage;

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

