#ifndef CUSTIM_H
#define CUSTIM_H
#include <QObject>


class CustIM : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QString storedStatus READ readStoredStatus NOTIFY storedStatusChanged())

public:
    explicit CustIM(QObject *parent = 0);
    ~CustIM();

    QString readVersion();

    Q_INVOKABLE void updateImStatus(QString message, bool addLocation, QString location);

    void readSettings();
    QString readStoredStatus();

signals:
    void versionChanged();
    void storedStatusChanged();


private:
    QString m_storedStatus;

};


#endif // CUSTIM_H

