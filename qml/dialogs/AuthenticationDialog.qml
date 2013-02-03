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

    title: "Authentication required." 
    message: "Page" + " requires authentication."
    property alias username: input.text
    property alias password: passwordInput.text

    function show(atitle, amsg, defaultValue, awinid)
    {
        message = amsg;
        title = atitle;
        winid = awinid;
        username = defaultValue;
        accepted = false;
        visible = true;
        print("topdialog.width:" + topdialog.width);
    }

    function handle(aAccepted)
    {
        print("Handle accepted:" + aAccepted);
        accepted = aAccepted;
        topdialog.handled();
        message = ""
        title = ""
        winid = 0;
        username = ""
        accepted = false
        password = ""
        visible = false;
    }

    height: 350

    DialogLineInput {
        id: input
        width: 300 - 30

        onAccepted: topdialog.handle(true)
    }

    DialogLineInput {
        id: passwordInput
        text: "" 
        width: 300 - 30
        echoMode: TextInput.PasswordEchoOnEdit

        onAccepted: topdialog.handle(true)
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
