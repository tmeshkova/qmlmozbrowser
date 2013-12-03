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
#include <QGLWidget>
#include <QDebug>
#include <QStringList>
#include <QDir>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QTimer>
#include "qmlapplicationviewer.h"
#include "qdeclarativemozview.h"
#include "qgraphicsmozview.h"
#include <QtDeclarative>
#if defined(Q_WS_X11)
#include <X11/Xlib.h>
#endif
#include "qmozcontext.h"
#include "WindowCreator.h"
#include "DBusAdaptor.h"

#define OBJECT_NAME "/"
#define SERVICE_NAME "org.mozilla.mozembed"

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
#ifdef HARMATTAN_BOOSTER
    application = MDeclarativeCache::qApplication(argc, argv);
#else
    qWarning() << Q_FUNC_INFO << "Warning! Running without booster. This may be a bit slower.";
    QApplication stackApp(argc, argv);
    application = &stackApp;
#endif

    application->setQuitOnLastWindowClosed(true);

    QString path;
    QString urlstring;
    QString qmlstring;
#ifdef __arm__
    bool glwidget = true;
    bool isFullscreen = true;
#else
    bool glwidget = true; // dont have GLX renderer yet
    bool isFullscreen = false;
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
    qmlRegisterType<QDeclarativeMozView>("QtMozilla", 1, 0, "QmlMozView");

    MozWindowCreator winCreator(qmlstring, glwidget, isFullscreen);
    QDeclarativeView *view = winCreator.CreateNewWindow(urlstring);
    winCreator.mWindowStack.append(view);

    DBusAdaptor* adaptor = new DBusAdaptor();
    if (QDBusConnection::sessionBus().registerService(SERVICE_NAME) &&
        QDBusConnection::sessionBus().registerObject(OBJECT_NAME, adaptor, QDBusConnection::ExportScriptableSlots)) {
        qDebug() << "DBus service started!";
        QObject::connect(adaptor, SIGNAL(newWindowUrl(QString, unsigned, QNewWindowResponse*)),
                     &winCreator, SLOT(newWindowRequested(const QString&, const unsigned&, QNewWindowResponse*)));
        QObject::connect(adaptor, SIGNAL(bringToFront()),
                     &winCreator, SLOT(bringToFront()));
    }
    else {
        qDebug() << "Object already exists. Another instance running?";
        if ((urlstring.length() == 0) || (urlstring == QString("about:blank"))) {
            QDBusInterface("org.mozilla.mozembed", "/", "org.mozilla.mozembed",
                       QDBusConnection::sessionBus()).call("show");
        }
        else {
            QDBusInterface("org.mozilla.mozembed", "/", "org.mozilla.mozembed",
                       QDBusConnection::sessionBus()).call("newUrl", urlstring);
        }
        return 0;
    }

    if (isFullscreen)
        view->showFullScreen();
    else
        view->show();

    qDebug() << "Starting Application!!!";

    QMozContext::GetInstance()->setViewCreator(&winCreator);

    QString componentPath(DEFAULT_COMPONENTS_PATH);
    qDebug() << "Load components from:" << componentPath + QString("/components") + QString("/EmbedLiteBinComponents.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/components") + QString("/EmbedLiteBinComponents.manifest"));
    qDebug() << "Load components from:" << componentPath + QString("/components") + QString("/EmbedLiteJSComponents.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/components") + QString("/EmbedLiteJSComponents.manifest"));
    qDebug() << "Load components from:" << componentPath + QString("/chrome") + QString("/EmbedLiteJSScripts.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/chrome") + QString("/EmbedLiteJSScripts.manifest"));
    qDebug() << "Load components from:" << componentPath + QString("/chrome") + QString("/EmbedLiteOverrides.manifest");
    QMozContext::GetInstance()->addComponentManifest(componentPath + QString("/chrome") + QString("/EmbedLiteOverrides.manifest"));

//    QMozContext::GetInstance()->addObserver("history:checkurivisited");
//    QMozContext::GetInstance()->addObserver("history:markurivisited");

    QObject::connect(application, SIGNAL(lastWindowClosed()),
                     QMozContext::GetInstance(), SLOT(stopEmbedding()));
    QTimer::singleShot(0, QMozContext::GetInstance(), SLOT(runEmbedding()));
    int retval = application->exec();
    qDebug() << "Exiting from Application!!!";
    QDBusConnection::sessionBus().unregisterObject(OBJECT_NAME);
    QDBusConnection::sessionBus().unregisterService(SERVICE_NAME);
    return retval;
}
