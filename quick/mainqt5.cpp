#include <QApplication>
#include <QtQuick/QQuickView>
#include "quickmozview.h"

int main(int argc, char **argv)
{
    setenv("QML_BAD_GUI_RENDER_LOOP", "1", 1);

    QApplication app(argc, argv);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:/qml/MainPageQuick.qml"));
    view.resize(800, 600);
    view.show();

    return app.exec();
}
