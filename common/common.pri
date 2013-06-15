isEmpty(OBJ_DEB_DIR) {
  OBJ_DEB_DIR=../$$OBJ_BUILD_PATH
}

isEmpty(DEFAULT_COMPONENT_PATH) {
  DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"/usr/lib/mozembedlite/\\\"\"
} else {
  DEFINES += DEFAULT_COMPONENTS_PATH=\"\\\"$$DEFAULT_COMPONENT_PATH\\\"\"
}

PREFIX = /usr

target.path = $$PREFIX/bin
INSTALLS += target

contains(CONFIG,qdeclarative-boostable):contains(MEEGO_EDITION,harmattan) {
    DEFINES += HARMATTAN_BOOSTER
}

!isEmpty(OBJ_DEB_DIR) {
  OBJECTS_DIR += $$OBJ_DEB_DIR
  DESTDIR = $$OBJ_DEB_DIR
  MOC_DIR += $$OBJ_DEB_DIR/tmp/moc/release_static
  RCC_DIR += $$OBJ_DEB_DIR/tmp/rcc/release_static
  LIBS += -L$$OBJ_DEB_DIR -lcommon
} else {
  LIBS += -L../common -lcommon
}
INCLUDEPATH += ../common

isEmpty(QTEMBED_LIB) {
  PKGCONFIG += qtembedwidget
} else {
  LIBS+=$$QTEMBED_LIB
}

contains(QT_MAJOR_VERSION, 4) {
  isEmpty(QTEMBED_LIB) {
    PKGCONFIG += x11
  } else {
    LIBS+=-lX11
  }
}
