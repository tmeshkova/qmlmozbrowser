/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-*/
/* vim: set ts=2 sw=2 et tw=79: */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef qmlhelpertools_h
#define qmlhelpertools_h

#include <QObject>
#include <QClipboard>
#include <QDir>
#include <QFileInfo>
#include <QVariant>
#include <QFileInfoList>
#include <QDesktopServices>

class QmlHelperTools : public QObject
{
    Q_OBJECT
public:
    QmlHelperTools(QObject* parent = 0);
    virtual ~QmlHelperTools() {}

private:
    QClipboard* clipboard;

public:
    Q_INVOKABLE void setClipboard(QString text);
    Q_INVOKABLE QString getClipboard();
    Q_INVOKABLE QList<QVariant> getFolderModel(QString path);
    Q_INVOKABLE QString getFolderCleanPath(QString path);
    Q_INVOKABLE QString getStorageLocation(int location);
    Q_INVOKABLE void processEvents();
    Q_INVOKABLE void openFileBySystem(QString path);
    Q_INVOKABLE QString getFaviconFromUrl(QString url);
};

#endif /* qmlhelpertools_h */
