#include <QDeclarativeView>
#include "qmozviewcreator.h"

class MozWindowCreator : public QMozViewCreator
{
public:
    MozWindowCreator(const QString& aQmlstring, const bool& aGlwidget, const bool& aIsFullScreen);
    QDeclarativeView* CreateNewWindow(const QString& url = QString("about:blank"), quint32* aUniqueID = 0, quint32 aParentID = 0);
    virtual quint32 createView(const QString &url, const quint32 &parentId);
    void bringToFront();

public:
    QList<QDeclarativeView*> mWindowStack;
private:
    QString qmlstring;
    bool glwidget;
    bool mIsFullScreen;
};
