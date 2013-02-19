QT += opengl declarative
SOURCES += main.cpp qmlapplicationviewer.cpp
HEADERS += qmlapplicationviewer.h 

QML_FILES = qml/*.qml
RESOURCES += qmlMozEmbedTest.qrc

TEMPLATE = app
CONFIG -= app_bundle
CONFIG += link_pkgconfig
TARGET = qmlMozEmbedTest

isEmpty(QTEMBED_LIB) {
PKGCONFIG += qtembedwidget x11
} else {
LIBS+=$$QTEMBED_LIB
}

isEmpty(DEFAULT_COMPONENT_PATH) {
DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"/usr/lib/mozembedlite/components/\\\"\"
} else {
DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"$$DEFAULT_COMPONENT_PATH\\\"\"
}

PREFIX = /usr

contains(QT_MAJOR_VERSION, 4) {
  PKGCONFIG += QJson
}

isEmpty(OBJ_DEB_DIR) {
  OBJ_DEB_DIR=obj-$$OBJ_ARCH-dir
}

OBJECTS_DIR += ./$$OBJ_DEB_DIR
DESTDIR = ./$$OBJ_DEB_DIR
MOC_DIR += ./$$OBJ_DEB_DIR/tmp/moc/release_static
RCC_DIR += ./$$OBJ_DEB_DIR/tmp/rcc/release_static

target.path = $$PREFIX/bin
INSTALLS += target

contains(CONFIG,qdeclarative-boostable):contains(MEEGO_EDITION,harmattan) {
    DEFINES += HARMATTAN_BOOSTER
}
