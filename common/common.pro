TEMPLATE = lib
CONFIG = staticlib qt
SOURCES += qmlhelpertools.cpp DBusAdaptor.cpp
HEADERS += qmlhelpertools.h DBusAdaptor.h
QT += opengl declarative dbus gui
*-g++*: QMAKE_CXXFLAGS += -fPIC

include(common.pri)
