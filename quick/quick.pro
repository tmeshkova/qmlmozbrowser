CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTestQt5
SOURCES += mainqt5.cpp

QT += dbus quick
!isEmpty(BUILD_QT5QUICK1) {
  QT += declarative
}

QML_FILES = qml/*.qml
RESOURCES += qmlMozEmbedTestQt5.qrc

TEMPLATE = app
CONFIG -= app_bundle

include(../common/common.pri)

target.path = $$PREFIX/bin
INSTALLS += target
