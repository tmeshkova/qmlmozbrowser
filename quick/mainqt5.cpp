#include <QGuiApplication>
#include <QtQuick/QQuickView>
#include <QQmlContext>
#include <QTimer>
#include <QScreen>
#include "quickmozview.h"
#include "qmozcontext.h"
#include "qmozcontext.h"

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(true);

    QString path, urlstring, qmlstring;
    bool isFullscreen = false;
    QStringList arguments = app.arguments();
    for (int i = 0; i < arguments.count(); ++i) {
        QString parameter = arguments.at(i);
        if (parameter == "-path") {
            if (i + 1 >= arguments.count())
                qFatal("-path requires an argument");
            path = arguments.at(i + 1);
            i++;
        } else if (parameter == "-url") {
            if (i + 1 >= arguments.count())
                qFatal("-url requires an argument");
            urlstring = arguments.at(i + 1);
            i++;
        } else if (parameter == "-qml") {
            if (i + 1 >= arguments.count())
                qFatal("-qml requires an argument");
            qmlstring = arguments.at(i + 1);
            i++;
        } else if (parameter == "-fullscreen") {
            isFullscreen = true;
        } else if (parameter == "-help") {
            qDebug() << "EMail application";
            qDebug() << "-fullscreen   - show QML fullscreen";
            qDebug() << "-path         - path to cd to before launching -url";
            qDebug() << "-qml          - file to launch (default: main.qml inside -path)";
            qDebug() << "-url          - url to load";
            exit(0);
        }
    }

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.rootContext()->setContextProperty("startURL", QVariant(urlstring));
    view.rootContext()->setContextProperty("createParentID", QVariant(0));
    view.rootContext()->setContextProperty("MozContext", QMozContext::GetInstance());
    view.setSource(qmlstring.isEmpty() ? QUrl("qrc:/qml/MainPageQuick.qml") : QUrl(qmlstring));
    if (isFullscreen) {
        QRect r = QGuiApplication::primaryScreen()->geometry();
        view.resize(r.width(), r.height());
        view.showFullScreen();
    }
    else {
        view.resize(800, 600);
        view.show();
    }

    QString componentPath(DEFAULT_COMPONENTS_PATH);
    qDebug() << "Load components from:" << componentPath + QString("/components") + QString("/EmbedLiteBinComponents.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/components") + QString("/EmbedLiteBinComponents.manifest"));
    qDebug() << "Load components from:" << componentPath + QString("/components") + QString("/EmbedLiteJSComponents.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/components") + QString("/EmbedLiteJSComponents.manifest"));
    qDebug() << "Load components from:" << componentPath + QString("/chrome") + QString("/EmbedLiteJSScripts.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/chrome") + QString("/EmbedLiteJSScripts.manifest"));
    qDebug() << "Load components from:" << componentPath + QString("/chrome") + QString("/EmbedLiteOverrides.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/chrome") + QString("/EmbedLiteOverrides.manifest"));

    QTimer::singleShot(0, QMozContext::GetInstance(), SLOT(runEmbedding()));
    QObject::connect(&app, SIGNAL(lastWindowClosed()), QMozContext::GetInstance(), SLOT(stopEmbedding()));

    return app.exec();
}
