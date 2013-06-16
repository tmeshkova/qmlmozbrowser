CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTest
SOURCES += main.cpp qmlapplicationviewer.cpp WindowCreator.cpp
HEADERS += qmlapplicationviewer.h WindowCreator.h

QT += opengl declarative dbus
contains(QT_MAJOR_VERSION, 4) {
  PKGCONFIG += QJson
}

QML_FILES = ../qml/*.qml
RESOURCES += ../qmlMozEmbedTest.qrc

TEMPLATE = app
CONFIG -= app_bundle

include(../common/common.pri)

target.path = $$PREFIX/bin
INSTALLS += target
