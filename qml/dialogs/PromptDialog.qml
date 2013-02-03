/*
 * Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies)
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 1.1

Dialog {
    id: topdialog

    parent: mainScope
    height: 180
    signal handled
    property alias prompttext: input.text

    function show(atitle, amsg, defaultValue, awinid)
    {
        message = amsg;
        title = atitle;
        winid = awinid;
        input.text = defaultValue;
        accepted = false;
        visible = true;
        print("topdialog.width:" + topdialog.width);
    }
    function handle(aAccepted)
    {
        accepted = aAccepted;
        topdialog.handled()
        visible = false;
    }

    DialogLineInput {
        id: input
        width: 300 - 30
        text: ""
        onAccepted: topdialog.handled(true)
    }

    Row {
        id: buttonRow
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter

        DialogButton {
            text: "OK"
            onClicked: topdialog.handle(true)
        }

        DialogButton {
            text: "Cancel"
            onClicked: topdialog.handle(false)
        }
    }
}
