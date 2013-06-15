TEMPLATE = subdirs
SUBDIRS = common declarative
declarative.depends = common
contains(QT_MAJOR_VERSION, 5) {
  SUBDIRS += quick
  quick.depends = common
}
