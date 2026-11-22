#include "ipc.hpp"

#include <QDebug>
#include <QSocketNotifier>
#include <QString>
#include <cerrno>
#include <cstdint>
#include <cstring>
#include <qlogging.h>
#include <qloggingcategory.h>
#include <wayland-client-core.h>
#include <wayland-client-protocol.h>
#include <wayland-nullspace-controller-v1-client-protocol.h>

namespace {
Q_LOGGING_CATEGORY(logNullspaceIpc, "topbar.nullspace", QtInfoMsg)
}

namespace topbar::nullspace {

namespace {
// NOLINTBEGIN(misc-include-cleaner)
constexpr int RECONNECT_INTERVAL_MS = 3000;
} // namespace

const wl_registry_listener &IpcClient::registryListener() {
    static const wl_registry_listener l = {
        .global = &IpcClient::onRegistryGlobal,
        .global_remove = &IpcClient::onRegistryGlobalRemove,
    };

    return l;
}

const nullspace_controller_v1_listener &IpcClient::controllerListener() {
    static const nullspace_controller_v1_listener l = {
        .config_value = &IpcClient::onConfigValue,
        .config_key = &IpcClient::onConfigKey,
        .space_info = &IpcClient::onSpaceInfo,
        .layout_info = &IpcClient::onLayoutInfo,
        .window_removed = &IpcClient::onWindowRemoved,
        .error = &IpcClient::onError,
        .done = &IpcClient::onDone,
        .window_detail = &IpcClient::onWindowDetail,
        .device_info = &IpcClient::onDeviceInfo,
        .display_info = &IpcClient::onDisplayInfo,
        .layer_info = &IpcClient::onLayerInfo,
    };

    return l;
}

IpcClient::IpcClient(QObject *parent) : QObject(parent) {
    this->mReconnectTimer.setSingleShot(true);
    QObject::connect(
        &this->mReconnectTimer, &QTimer::timeout, this, &IpcClient::tryReconnect
    );

    QTimer::singleShot(0, this, &IpcClient::connectSocket);
}

IpcClient::~IpcClient() { this->teardown(); }

std::uint32_t IpcClient::nextSerial() {
    const std::uint32_t s = this->mNextSerial++;
    if (this->mNextSerial == 0) this->mNextSerial = 1;
    return s;
}

void IpcClient::connectSocket() {
    if (this->mDisplay) return;

    this->mDisplay = wl_display_connect(nullptr);
    if (!this->mDisplay) {
        qCWarning(logNullspaceIpc) << "Wayland connect failed; retrying in"
                                   << RECONNECT_INTERVAL_MS << "ms";

        this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
        return;
    }

    this->mRegistry = wl_display_get_registry(this->mDisplay);
    wl_registry_add_listener(this->mRegistry, &registryListener(), this);

    if (wl_display_roundtrip(this->mDisplay) < 0
        || wl_display_roundtrip(this->mDisplay) < 0) {
        qCWarning(logNullspaceIpc) << "Wayland roundtrip failed";
        this->teardown();
        this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
        return;
    }

    if (!this->mController) {
        qCWarning(logNullspaceIpc)
            << "Compositor does not advertise controller";

        this->teardown();
        this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
        return;
    }

    const int fd = wl_display_get_fd(this->mDisplay);
    this->mNotifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);
    QObject::connect(
        this->mNotifier, &QSocketNotifier::activated, this,
        &IpcClient::onReadable
    );

    nullspace_controller_v1_dump_config(this->mController, this->nextSerial());

    nullspace_controller_v1_list_spaces(this->mController, this->nextSerial());

    this->flush();

    this->mConnected = true;
    qCInfo(logNullspaceIpc) << "Connected to controller";
    emit this->connectedChanged();
}

void IpcClient::teardown() {
    if (this->mNotifier) {
        this->mNotifier->setEnabled(false);
        delete this->mNotifier;
        this->mNotifier = nullptr;
    }

    if (this->mController) {
        nullspace_controller_v1_destroy(this->mController);
        this->mController = nullptr;
    }

    if (this->mRegistry) {
        wl_registry_destroy(this->mRegistry);
        this->mRegistry = nullptr;
    }

    if (this->mDisplay) {
        wl_display_flush(this->mDisplay);
        wl_display_disconnect(this->mDisplay);
        this->mDisplay = nullptr;
    }

    if (this->mConnected) {
        this->mConnected = false;
        emit this->connectedChanged();
    }
}

void IpcClient::tryReconnect() { this->connectSocket(); }

void IpcClient::onReadable() {
    if (wl_display_dispatch(this->mDisplay) < 0) {
        qCWarning(logNullspaceIpc) << "Wayland dispatch failed; reconnecting";
        this->teardown();
        this->mReconnectTimer.start(RECONNECT_INTERVAL_MS);
    }
}

void IpcClient::flush() {
    if (!this->mDisplay) return;
    if (wl_display_flush(this->mDisplay) < 0 && errno != EAGAIN) {
        qCWarning(logNullspaceIpc) << "Wayland flush failed";
    }
}

void IpcClient::switchSpace(quint32 space) {
    if (!this->mController) return;
    nullspace_controller_v1_switch_space(
        this->mController, this->nextSerial(), space
    );

    this->flush();
}

void IpcClient::moveFocusedToSpace(quint32 space) {
    if (!this->mController) return;
    nullspace_controller_v1_move_to_space(
        this->mController, this->nextSerial(), space
    );

    this->flush();
}

void IpcClient::cycleLayout() {
    if (!this->mController) return;
    nullspace_controller_v1_cycle_layout(this->mController, this->nextSerial());

    this->flush();
}

void IpcClient::setConfig(const QString &key, const QString &value) {
    if (!this->mController) return;
    const QByteArray k = key.toUtf8();
    const QByteArray v = value.toUtf8();
    nullspace_controller_v1_set_config(
        this->mController, this->nextSerial(), k.constData(), v.constData()
    );

    this->flush();
}

void IpcClient::closeFocused() {
    if (!this->mController) return;
    nullspace_controller_v1_window_close_focused(
        this->mController, this->nextSerial()
    );

    this->flush();
}

void IpcClient::onRegistryGlobal(
    void *data, wl_registry *reg, std::uint32_t name, const char *iface,
    std::uint32_t version
) {
    (void)version;
    auto *self = static_cast<IpcClient *>(data);
    if (std::strcmp(iface, nullspace_controller_v1_interface.name) != 0) return;

    self->mController = static_cast<nullspace_controller_v1 *>(
        wl_registry_bind(reg, name, &nullspace_controller_v1_interface, 1)
    );

    nullspace_controller_v1_add_listener(
        self->mController, &controllerListener(), self
    );
}

void IpcClient::onRegistryGlobalRemove(
    void *data, wl_registry *r, std::uint32_t name
) {
    (void)data;
    (void)r;
    (void)name;
}

void IpcClient::onConfigValue(
    void *data, nullspace_controller_v1 *c, const char *key, const char *value
) {
    (void)c;

    auto *self = static_cast<IpcClient *>(data);
    emit self->eventReceived(QString::fromUtf8(key), QString::fromUtf8(value));
}

void IpcClient::onConfigKey(
    void *data, nullspace_controller_v1 *c, const char *key, std::uint32_t type,
    std::uint32_t access, const char *range, const char *desc
) {
    (void)data;
    (void)c;
    (void)key;
    (void)type;
    (void)desc;
    (void)access;
    (void)range;
}

void IpcClient::onSpaceInfo(
    void *data, nullspace_controller_v1 *c, std::uint32_t index,
    std::uint32_t count, std::uint32_t urgent, std::uint32_t active
) {
    (void)c;

    auto *self = static_cast<IpcClient *>(data);

    emit self->eventReceived(
        QStringLiteral("space_window_count"),
        QStringLiteral("%1 %2").arg(index).arg(count)
    );

    emit self->eventReceived(
        QStringLiteral("space_urgent"),
        QStringLiteral("%1 %2").arg(index).arg(
            urgent ? QStringLiteral("true") : QStringLiteral("false")
        )
    );

    if (active)
        emit self->eventReceived(
            QStringLiteral("current_space"), QString::number(index)
        );
}

void IpcClient::onLayoutInfo(
    void *data, nullspace_controller_v1 *c, const char *name, const char *desc,
    std::uint32_t active
) {
    (void)c;
    (void)desc;

    if (!active) return;
    auto *self = static_cast<IpcClient *>(data);
    emit self->eventReceived(QStringLiteral("layout"), QString::fromUtf8(name));
}

void IpcClient::onWindowRemoved(
    void *data, nullspace_controller_v1 *c, std::uint32_t id
) {
    (void)data;
    (void)c;
    (void)id;
}

void IpcClient::onError(
    void *data, nullspace_controller_v1 *c, std::uint32_t serial,
    std::uint32_t code, const char *message
) {
    (void)c;

    auto *self = static_cast<IpcClient *>(data);
    qCWarning(logNullspaceIpc)
        << "controller error" << code << message << "(serial" << serial << ")";

    emit self->errorReceived(code, QString::fromUtf8(message));
}

void IpcClient::onDone(
    void *data, nullspace_controller_v1 *c, std::uint32_t serial
) {
    (void)c;
    (void)data;
    (void)serial;
}

void IpcClient::onWindowDetail(
    void *data, nullspace_controller_v1 *c, std::uint32_t id, std::int32_t pid,
    const char *ftlId, const char *appId, const char *title,
    const char *monitor, std::int32_t space, std::int32_t x, std::int32_t y,
    std::int32_t width, std::int32_t height, std::uint32_t state,
    const char *contentType, std::uint32_t effectState
) {
    (void)data;
    (void)c;
    (void)id;
    (void)pid;
    (void)ftlId;
    (void)monitor;
    (void)contentType;
    (void)effectState;
    (void)width;
    (void)height;
    (void)state;
    (void)title;
    (void)appId;
    (void)space;
    (void)x;
    (void)y;
}

void IpcClient::onDeviceInfo(
    void *data, nullspace_controller_v1 *c, const char *type, const char *name
) {
    (void)data;
    (void)c;
    (void)name;
    (void)type;
}

void IpcClient::onDisplayInfo(
    void *data, nullspace_controller_v1 *c, const char *name, const char *make,
    const char *model, const char *serial, std::int32_t x, std::int32_t y,
    std::int32_t width, std::int32_t height, std::int32_t physWidth,
    std::int32_t physHeight, const char *scale, std::int32_t refresh,
    std::uint32_t enabled, std::int32_t space, std::int32_t areaX,
    std::int32_t areaY, std::int32_t areaWidth, std::int32_t areaHeight
) {
    (void)data;
    (void)c;
    (void)name;
    (void)x;
    (void)y;
    (void)serial;
    (void)width;
    (void)height;
    (void)refresh;
    (void)areaHeight;
    (void)areaWidth;
    (void)areaX;
    (void)areaY;
    (void)physHeight;
    (void)physWidth;
    (void)scale;
    (void)space;
    (void)enabled;
    (void)make;
    (void)model;
}

void IpcClient::onLayerInfo(
    void *data, nullspace_controller_v1 *c, const char *layerNamespace,
    const char *layer, const char *output, std::uint32_t mapped, std::int32_t x,
    std::int32_t y, std::uint32_t width, std::uint32_t height,
    std::int32_t exclusiveZone, const char *keyboard
) {
    (void)data;
    (void)c;
    (void)layerNamespace;
    (void)layer;
    (void)width;
    (void)height;
    (void)exclusiveZone;
    (void)keyboard;
    (void)x;
    (void)y;
    (void)output;
    (void)mapped;
}

// NOLINTEND(misc-include-cleaner)
} // namespace topbar::nullspace
