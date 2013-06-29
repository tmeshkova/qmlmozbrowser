TEMPLATE = subdirs
SUBDIRS = common
contains(QT_MAJOR_VERSION, 4) {
  SUBDIRS += declarative
  declarative.depends = common
}
contains(QT_MAJOR_VERSION, 5) {
  !isEmpty(BUILD_QT5QUICK1) {
    SUBDIRS += declarative
    declarative.depends = common
  }
  SUBDIRS += quick
  quick.depends = common
}
