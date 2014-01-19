#ifndef CUSTIM_H
#define CUSTIM_H
#include <QObject>

class CustIM : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString variable READ readVar WRITE writeVar(QString) NOTIFY varChanged())

public:
    explicit CustIM(QObject *parent = 0);
    ~CustIM();

    QString readVar();
    void writeVar(QString);

    Q_INVOKABLE void readInitParams();
    Q_INVOKABLE void updateImStatus(QString message);

signals:
    void varChanged();

private:
    QString m_var;
};


#endif // CUSTIM_H

