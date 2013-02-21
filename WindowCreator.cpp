#include "WindowCreator.h"
#include <QDeclarativeView>
#include <QGraphicsObject>
#include <QVariant>
#include <QGLWidget>
#include <QDeclarativeContext>
#include <QDebug>
#include "qmlapplicationviewer.h"

MozWindowCreator::MozWindowCreator(const QString& aQmlstring, const bool& aGlwidget, const bool& aIsFullScreen)
{
    qmlstring = aQmlstring;
    glwidget = aGlwidget;
    mIsFullScreen = aIsFullScreen;
}

void MozWindowCreator::newWindowRequested(const QString& url)
{
    QDeclarativeView* view = CreateNewWindow(url);
    mWindowStack.append(view);
    if (mIsFullScreen)
        view->showFullScreen();
    else
        view->show();
}

QDeclarativeView*
MozWindowCreator::CreateNewWindow(const QString& url)
{
    QDeclarativeView *view;
#ifdef HARMATTAN_BOOSTER
    view = MDeclarativeCache::qDeclarativeView();
#else
    qWarning() << Q_FUNC_INFO << "Warning! Running without booster. This may be a bit slower.";
    QmlApplicationViewer* stackView = new QmlApplicationViewer();
    view = stackView;
    stackView->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#endif

    QUrl qml;
    if (qmlstring.isEmpty())
#if defined(__arm__) && !defined(Q_WS_MAEMO_5) && (QT_VERSION <= QT_VERSION_CHECK(5, 0, 0))
        qml = QUrl("qrc:/qml/main_meego.qml");
#else
        qml = QUrl("qrc:/qml/main.qml");
#endif
    else
        qml = QUrl::fromUserInput(qmlstring);

    // See NEMO#415 for an explanation of why this may be necessary.
    if (glwidget && !getenv("SWRENDER"))
        view->setViewport(new QGLWidget);
    else
        qDebug() << "Not using QGLWidget viewport";

    view->rootContext()->setContextProperty("startURL", QVariant(url));
    view->setSource(qml);
    QObject* item = view->rootObject()->findChild<QObject*>("mainScope");
    if (item) {
        QObject::connect(item, SIGNAL(pageTitleChanged(QString)), view, SLOT(setWindowTitle(QString)));
    }

    // Important - simplify qml and resize, make it works good..
    view->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    view->setAttribute(Qt::WA_OpaquePaintEvent);
    view->setAttribute(Qt::WA_NoSystemBackground);
#if defined(Q_WS_MAEMO_5)
    view->setAttribute(Qt::WA_Maemo5NonComposited);
#endif
    view->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    view->viewport()->setAttribute(Qt::WA_NoSystemBackground);
#if defined(Q_WS_MAEMO_5)
    view->viewport()->setAttribute(Qt::WA_Maemo5NonComposited);
#endif
    view->setWindowTitle("QtMozEmbedBrowser");
    view->setWindowFlags(Qt::Window | Qt::WindowTitleHint |
                         Qt::WindowMinMaxButtonsHint |
                         Qt::WindowCloseButtonHint);

    return view;
}
