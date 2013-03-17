/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-*/
/* vim: set ts=2 sw=2 et tw=79: */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <QApplication>
#include "qmlhelpertools.h"

void
QmlHelperTools::setClipboard(QString text)
{
    clipboard->setText(text);
}

QString
QmlHelperTools::getClipboard()
{
    return clipboard->text();
}

QString
QmlHelperTools::getFolderCleanPath(QString path)
{
    return QDir::cleanPath(path);
}

QList<QVariant>
QmlHelperTools::getFolderModel(QString path)
{
    QList<QVariant> result;
    QDir dir(path);
    QStringList entryList = dir.entryList(QDir::NoFilter, QDir::DirsFirst | QDir::Name | QDir::IgnoreCase);
    QFileInfoList infoList = dir.entryInfoList(QDir::NoFilter, QDir::DirsFirst | QDir::Name | QDir::IgnoreCase);
    for (int i=0; i<entryList.count(); i++) {
        if (entryList.at(i) == ".") {
            continue;
        }
        if (dir.isRoot() && entryList.at(i) == "..") {
            continue;
        }
        QList<QVariant> resultItem;
        resultItem.append(entryList.at(i));
        QFileInfo itemInfo = infoList.at(i);
        if (itemInfo.isDir()) {
            resultItem.append(0);
        }
        else {
            resultItem.append(1);
        }
        result.append(QVariant(resultItem));
    }
    return result;
}

QmlHelperTools::QmlHelperTools(QObject* parent)
  : QObject(parent)
{
    clipboard = QApplication::clipboard();
} 
