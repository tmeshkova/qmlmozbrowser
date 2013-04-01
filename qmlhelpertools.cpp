/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-*/
/* vim: set ts=2 sw=2 et tw=79: */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <QApplication>
#include <QUrl>
#include "qmlhelpertools.h"

void
QmlHelperTools::openFileBySystem(QString path)
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void
QmlHelperTools::processEvents()
{
    QCoreApplication::processEvents();
}

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

//QDesktopServices::DesktopLocation   0   Returns the user's desktop directory.
//QDesktopServices::DocumentsLocation 1   Returns the user's document.
//QDesktopServices::FontsLocation 2   Returns the user's fonts.
//QDesktopServices::ApplicationsLocation  3   Returns the user's applications.
//QDesktopServices::MusicLocation 4   Returns the users music.
//QDesktopServices::MoviesLocation    5   Returns the user's movies.
//QDesktopServices::PicturesLocation  6   Returns the user's pictures.
//QDesktopServices::TempLocation  7   Returns the system's temporary directory.
//QDesktopServices::HomeLocation  8   Returns the user's home directory.
//QDesktopServices::DataLocation  9   Returns a directory location where persistent application data can be stored. QCoreApplication::applicationName and QCoreApplication::organizationName should work on all platforms.
//QDesktopServices::CacheLocation 10  Returns a directory location where user-specific non-essential (cached) data should be written.

QString
QmlHelperTools::getStorageLocation(int location)
{
    return QDesktopServices::storageLocation((QDesktopServices::StandardLocation)location);
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

QString
QmlHelperTools::getFaviconFromUrl(QString url)
{
    QUrl mUrl(url);
    mUrl.setPath("/favicon.ico");
    return mUrl.toString();
}

QmlHelperTools::QmlHelperTools(QObject* parent)
  : QObject(parent)
{
    clipboard = QApplication::clipboard();
} 
