import QtQuick
import TopBar.Clients

Item {
    id: root

    property alias github: githubLoader.item

    Loader {
        id: githubLoader

        active: Config.services.github

        sourceComponent: GitHub {
            enabled: true
        }
    }

    Binding {
        target: States
        property: "githubClient"
        value: githubLoader.item
    }
}
