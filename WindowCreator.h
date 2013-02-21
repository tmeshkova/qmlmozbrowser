#include <QDeclarativeView>

class MozWindowCreator : public QObject
{
    Q_OBJECT
public:
    MozWindowCreator(const QString& aQmlstring, const bool& aGlwidget, const bool& aIsFullScreen);
    QDeclarativeView* CreateNewWindow(const QString& url = QString("about:blank"));
public Q_SLOTS:
    void newWindowRequested(const QString& url);

public:
    QList<QDeclarativeView*> mWindowStack;
private:
    QString qmlstring;
    bool glwidget;
    bool mIsFullScreen;
};
