import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config

Scope {
    Connections {
        function onTreeLoaded(self): void {
            if (GlobalConfig.utilities.toasts.configLoaded)
                Toaster.toast(qsTr("Config loaded"), qsTr("Config loaded successfully!"), "rule_settings");
        }

        function onTreeLoadFailed(self, error: string): void {
            Toaster.toast(qsTr("Failed to parse config"), error, "settings_alert", Toast.Warning);
        }

        function onTreeSaveFailed(self, error: string): void {
            Toaster.toast(qsTr("Failed to save config"), error, "settings_alert", Toast.Error);
        }

        target: GlobalConfig
    }

    Connections {
        function onTreeLoadFailed(self, error: string): void {
            Toaster.toast(qsTr("Failed to parse token config"), error, "settings_alert", Toast.Warning);
        }

        target: TokenConfig
    }
}
