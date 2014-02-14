TEMPLATE = subdirs
SUBDIRS = common
!isEmpty(BUILD_QT5QUICK1) {
  SUBDIRS += declarative
  declarative.depends = common
}
SUBDIRS += quick
quick.depends = common
