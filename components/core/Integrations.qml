import QtQuick
import TopBar.Clients

Item {
    id: root

    property alias codeberg: codebergLoader.item
    property alias github: githubLoader.item

    Loader {
        id: codebergLoader

        active: Config.services.codeberg

        sourceComponent: Codeberg {
            enabled: true
        }
    }

    Loader {
        id: githubLoader

        active: Config.services.github

        sourceComponent: GitHub {
            enabled: true
        }
    }

    Binding {
        target: States
        property: "codebergClient"
        value: codebergLoader.item
    }

    Binding {
        target: States
        property: "githubClient"
        value: githubLoader.item
    }
}
