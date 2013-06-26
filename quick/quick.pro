CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTestQt5
SOURCES += mainqt5.cpp

QT += opengl declarative dbus quick

QML_FILES = qml/*.qml
RESOURCES += qmlMozEmbedTest.qrc

TEMPLATE = app
CONFIG -= app_bundle

include(../common/common.pri)

target.path = $$PREFIX/bin
INSTALLS += target
