CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTest
SOURCES += main.cpp

QT += opengl declarative
PKGCONFIG += QJson

QML_FILES = qml/*.qml
RESOURCES += qmlMozEmbedTest.qrc

TEMPLATE = app
CONFIG -= app_bundle

isEmpty(QTEMBED_LIB) {
  PKGCONFIG += qtembedwidget x11
} else {
  LIBS+=$$QTEMBED_LIB -lX11
}

PREFIX = /usr

isEmpty(OBJ_DEB_DIR) {
  OBJ_DEB_DIR=$$OBJ_BUILD_PATH
}

OBJECTS_DIR += ./$$OBJ_DEB_DIR
DESTDIR = ./$$OBJ_DEB_DIR
MOC_DIR += ./$$OBJ_DEB_DIR/tmp/moc/release_static
RCC_DIR += ./$$OBJ_DEB_DIR/tmp/rcc/release_static

target.path = $$PREFIX/bin
INSTALLS += target
