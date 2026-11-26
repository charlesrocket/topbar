import QtQuick

import TopBar.Nullspace

Item {
    id: root

    function pushGaps() {
        const p = Config.bar.padding;
        NullspaceIpc.setGapOuterH(p);
        NullspaceIpc.setGapOuterV(p);
        NullspaceIpc.setGapInnerH(p);
        NullspaceIpc.setGapInnerV(p);
    }

    function pushAnimDuration() {
        const v = String(Config.appearance.animDuration);
        NullspaceIpc.setConfig("animations_duration_move", v);
        NullspaceIpc.setConfig("animations_duration_open", v);
        NullspaceIpc.setConfig("animations_duration_close", v);
        NullspaceIpc.setConfig("animations_duration_space", v);
    }

    function pushRoundedCorners() {
        NullspaceIpc.setConfig("rounded_corners_enabled",
                               Config.appearance.roundedCorners ? "true" :
                                                                  "false");
        NullspaceIpc.setConfig("rounded_corners_radius", String(
                                   Config.appearance.cornerRadius));
    }

    function pushBlur() {
        const v = Config.appearance.blur ? "true" : "false";
        //NullspaceIpc.setConfig("window_blur", v);
        NullspaceIpc.setConfig("wallpaper_blur_enabled", v);
    }

    function pushShadows() {
        //NullspaceIpc.setConfig("window_shadow_enabled", Config.appearance.shadows ? "true" : "false");
    }

    function pushWallpaper() {
        const p = Utils.expandPath(Config.general.wallpaper);
        if (p.startsWith("/"))
            NullspaceIpc.setConfig("wallpaper_path", p);
    }

    function pushAll() {
        if (!NullspaceIpc.available)
            return;
        root.pushGaps();
        root.pushAnimDuration();
        root.pushRoundedCorners();
        root.pushBlur();
        root.pushShadows();
        root.pushWallpaper();
    }

    Component.onCompleted: {
        if (NullspaceIpc.available)
            root.pushAll();
    }

    Connections {
        function onAvailableChanged() {
            if (NullspaceIpc.available)
                root.pushAll();
        }

        target: NullspaceIpc
    }

    Connections {
        function onPaddingChanged() {
            if (NullspaceIpc.available)
                root.pushGaps();
        }

        target: Config.bar
    }

    Connections {
        function onAnimDurationChanged() {
            if (NullspaceIpc.available)
                root.pushAnimDuration();
        }

        function onRoundedCornersChanged() {
            if (NullspaceIpc.available)
                root.pushRoundedCorners();
        }

        function onCornerRadiusChanged() {
            if (NullspaceIpc.available)
                root.pushRoundedCorners();
        }

        function onBlurChanged() {
            if (NullspaceIpc.available)
                root.pushBlur();
        }

        function onShadowsChanged() {
            if (NullspaceIpc.available)
                root.pushShadows();
        }

        target: Config.appearance
    }

    Connections {
        function onWallpaperChanged() {
            if (NullspaceIpc.available)
                root.pushWallpaper();
        }

        target: Config.general
    }
}
