TEMPLATE = lib
CONFIG = staticlib qt
SOURCES += qmlhelpertools.cpp DBusAdaptor.cpp
HEADERS += qmlhelpertools.h DBusAdaptor.h
QT += opengl dbus gui
!isEmpty(BUILD_QT5QUICK1) {
  QT += declarative
}
*-g++*: QMAKE_CXXFLAGS += -fPIC

include(common.pri)
