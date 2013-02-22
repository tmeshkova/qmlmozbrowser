#include <QDeclarativeView>

class MozWindowCreator : public QObject
{
    Q_OBJECT
public:
    MozWindowCreator(const QString& aQmlstring, const bool& aGlwidget, const bool& aIsFullScreen);
    QDeclarativeView* CreateNewWindow(const QString& url = QString("about:blank"), quint32* aUniqueID = 0, quint32 aParentID = 0);
public Q_SLOTS:
    quint32 newWindowRequested(const QString& url, const unsigned& aParentID);

public:
    QList<QDeclarativeView*> mWindowStack;
private:
    QString qmlstring;
    bool glwidget;
    bool mIsFullScreen;
};
