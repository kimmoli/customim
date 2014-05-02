#ifndef CUSTIM_H
#define CUSTIM_H
#include <QObject>


class CustIM : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ readVersion NOTIFY versionChanged())
    Q_PROPERTY(QString storedStatus READ readStoredStatus NOTIFY storedStatusChanged())
    Q_PROPERTY(int textType READ readTextType NOTIFY textTypeChanged())
    Q_PROPERTY(bool addLocation READ readAddLocation NOTIFY addLocationChanged())

public:
    explicit CustIM(QObject *parent = 0);
    ~CustIM();

    QString readVersion();

    Q_INVOKABLE void updateImStatus(QString message, bool addLocation, QString location, int textType);

    void readSettings();
    QString readStoredStatus();
    int readTextType();
    bool readAddLocation();

signals:
    void versionChanged();
    void storedStatusChanged();
    void textTypeChanged();
    void addLocationChanged();


private:
    QString m_storedStatus;
    int m_textType;
    bool m_addLocation;

};


#endif // CUSTIM_H

