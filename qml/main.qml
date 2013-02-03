/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.0

FocusScope {
    id: appWindow
    x: 0; y: 0
    width: 100; height: 100
    anchors.fill: parent
    MainPage {
    }
}
