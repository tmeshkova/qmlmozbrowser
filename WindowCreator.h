#include <QDeclarativeView>

class MozWindowCreator : public QObject
{
    Q_OBJECT
public:
    MozWindowCreator(const QString& aQmlstring, const bool& aGlwidget, const bool& aIsFullScreen);
    QDeclarativeView* CreateNewWindow(const QString& url = QString("about:blank"), unsigned int* aUniqueID = 0, unsigned int aParentID = 0);
public Q_SLOTS:
    unsigned newWindowRequested(const QString& url, const unsigned& aParentID);

public:
    QList<QDeclarativeView*> mWindowStack;
private:
    QString qmlstring;
    bool glwidget;
    bool mIsFullScreen;
};
