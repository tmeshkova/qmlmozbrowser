/*
 * Copyright (C) 2011 Robin Burchell <robin+mer@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

#include <QApplication>
#include <QDeclarativeView>
#include <QGLWidget>
#include <QDebug>
#include <QUrl>
#include <QDir>
#include <QDeclarativeEngine>
#ifdef HAS_BOOSTER
#include <applauncherd/MDeclarativeCache>
#endif
#include "qmlapplicationviewer.h"
#include "qdeclarativemozview.h"
#include "qgraphicsmozview.h"
#include <QtDeclarative>
#if defined(Q_WS_X11)
#include <X11/Xlib.h>
#endif
//#include <qjson/qjson.h>

#ifdef HAS_BOOSTER
Q_DECL_EXPORT
#endif
int main(int argc, char *argv[])
{
#if defined(Q_WS_X11)
#if QT_VERSION >= 0x040800
    QApplication::setAttribute(Qt::AA_X11InitThreads, true);
#else
    XInitThreads();
    QApplication::setAttribute(static_cast<Qt::ApplicationAttribute>(10), true);
#endif
#endif

    QApplication *application;
    QDeclarativeView *view;
#ifdef HARMATTAN_BOOSTER
    application = MDeclarativeCache::qApplication(argc, argv);
    view = MDeclarativeCache::qDeclarativeView();
#else
    qWarning() << Q_FUNC_INFO << "Warning! Running without booster. This may be a bit slower.";
    QApplication stackApp(argc, argv);
    QmlApplicationViewer stackView;
    application = &stackApp;
    view = &stackView;
    stackView.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#endif
    application->setQuitOnLastWindowClosed(true);

//    qmlRegisterType<QJson>("QJson", 1, 0, "QJson");

    QString path;
    QString urlstring;
    QString qmlstring;
#ifdef __arm__
    bool isFullscreen = true;
#else
    bool isFullscreen = false;
#endif
#if !defined(Q_WS_MAEMO_5)
    bool glwidget = true;
#else
    bool glwidget = false;
#endif
    QStringList arguments = application->arguments();
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
        } else if (parameter == "-no-glwidget") {
            glwidget = false;
        } else if (parameter == "-glwidget") {
            glwidget = true;
        } else if (parameter == "-help") {
            qDebug() << "EMail application";
            qDebug() << "-fullscreen   - show QML fullscreen";
            qDebug() << "-path         - path to cd to before launching -url";
            qDebug() << "-qml          - file to launch (default: main.qml inside -path)";
            qDebug() << "-url          - url to load";
            qDebug() << "-no-glwidget  - Don't use QGLWidget viewport";
            exit(0);
        } 
    }

    if (!path.isEmpty())
        QDir::setCurrent(path);

    qmlRegisterType<QGraphicsMozView>("QtMozilla", 1, 0, "QGraphicsMozView");
    qmlRegisterType<QDeclarativeMozView>("QtMozilla", 1, 0, "QDeclarativeMozView");

    QUrl qml;
    if (qmlstring.isEmpty())
#if defined(__arm__) && !defined(Q_WS_MAEMO_5)
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

    view->setSource(qml);
    view->rootContext()->setContextProperty("startURL", QVariant(urlstring));
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

    if (isFullscreen)
        view->showFullScreen();
    else
        view->show();

    qDebug() << "Starting Application!!!";

    int retval = application->exec();
    qDebug() << "Exiting from Application!!!";
    return retval;
}
