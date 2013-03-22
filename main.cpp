#include <QApplication>
#include <QDeclarativeView>
#include <QGLWidget>
#include "qdeclarativemozview.h"
#include "qgraphicsmozview.h"
#include "qmozcontext.h"

int main(int argc, char *argv[])
{
    QApplication application(argc, argv);
    QDeclarativeView view;
    qmlRegisterType<QmlMozContext>("QtMozilla", 1, 0, "QmlMozContext");
    qmlRegisterType<QGraphicsMozView>("QtMozilla", 1, 0, "QGraphicsMozView");
    qmlRegisterType<QDeclarativeMozView>("QtMozilla", 1, 0, "QmlMozView");

    view.setViewport(new QGLWidget);
    view.setSource(QUrl("qrc:/qml/main_meego.qml"));

    view.setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view.show();

    return application.exec();
}
