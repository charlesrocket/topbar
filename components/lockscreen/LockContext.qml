import Quickshell
import Quickshell.Services.Pam

import QtQuick

Scope {
    id: root

    signal unlocked
    signal failed

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText === "")
            return;

        root.unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam

        // TODO improve config handling
        configDirectory: "/usr/local/etc/pam.d"
        config: "unix-selfauth"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }

            root.unlockInProgress = false;
        }
    }
}
