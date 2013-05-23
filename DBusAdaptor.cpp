#include "DBusAdaptor.h"

DBusAdaptor::DBusAdaptor()
{}

void DBusAdaptor::newUrl(QString url)
{
    Q_EMIT newWindowUrl(url, 0, 0);
}

void DBusAdaptor::show()
{
    Q_EMIT bringToFront();
}
