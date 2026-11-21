#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <cstdint>

class QSocketNotifier;
struct nullspace_controller_v1;
struct nullspace_controller_v1_listener;
struct wl_display;
struct wl_registry;
struct wl_registry_listener;

namespace topbar::nullspace {

class IpcClient : public QObject {
    Q_OBJECT

  public:
    explicit IpcClient(QObject *parent = nullptr);
    ~IpcClient() override;

    [[nodiscard]] bool isConnected() const { return this->mConnected; }

    void switchSpace(quint32 space);
    void moveFocusedToSpace(quint32 space);
    void cycleLayout();
    void setConfig(const QString &key, const QString &value);
    void closeFocused();

  signals:
    void connectedChanged();
    void eventReceived(const QString &key, const QString &value);
    void errorReceived(quint32 code, const QString &message);

  private slots:
    void tryReconnect();
    void onReadable();

  private:
    void connectSocket();
    void teardown();
    void flush();

    std::uint32_t nextSerial();

    static const wl_registry_listener &registryListener();
    static const nullspace_controller_v1_listener &controllerListener();

    static void onRegistryGlobal(
        void *data, wl_registry *reg, std::uint32_t name, const char *iface,
        std::uint32_t version
    );

    static void
    onRegistryGlobalRemove(void *data, wl_registry *r, std::uint32_t name);

    static void onConfigValue(
        void *data, nullspace_controller_v1 *c, const char *key,
        const char *value
    );

    static void onConfigKey(
        void *data, nullspace_controller_v1 *c, const char *key,
        std::uint32_t type, std::uint32_t access, const char *range,
        const char *desc
    );

    static void onSpaceInfo(
        void *data, nullspace_controller_v1 *c, std::uint32_t index,
        std::uint32_t count, std::uint32_t urgent, std::uint32_t active
    );

    static void onLayoutInfo(
        void *data, nullspace_controller_v1 *c, const char *name,
        const char *desc, std::uint32_t active
    );

    static void
    onWindowRemoved(void *data, nullspace_controller_v1 *c, std::uint32_t id);

    static void onError(
        void *data, nullspace_controller_v1 *c, std::uint32_t serial,
        std::uint32_t code, const char *message
    );

    static void
    onDone(void *data, nullspace_controller_v1 *c, std::uint32_t serial);

    static void onWindowDetail(
        void *data, nullspace_controller_v1 *c, std::uint32_t id,
        std::int32_t pid, const char *ftlId, const char *appId,
        const char *title, const char *monitor, std::int32_t space,
        std::int32_t x, std::int32_t y, std::int32_t width, std::int32_t height,
        std::uint32_t state, const char *contentType, std::uint32_t effectState
    );

    static void onDeviceInfo(
        void *data, nullspace_controller_v1 *c, const char *type,
        const char *name
    );

    static void onDisplayInfo(
        void *data, nullspace_controller_v1 *c, const char *name,
        const char *make, const char *model, const char *serial, std::int32_t x,
        std::int32_t y, std::int32_t width, std::int32_t height,
        std::int32_t physWidth, std::int32_t physHeight, const char *scale,
        std::int32_t refresh, std::uint32_t enabled, std::int32_t space,
        std::int32_t areaX, std::int32_t areaY, std::int32_t areaWidth,
        std::int32_t areaHeight
    );

    static void onLayerInfo(
        void *data, nullspace_controller_v1 *c, const char *layerNamespace,
        const char *layer, const char *output, std::uint32_t mapped,
        std::int32_t x, std::int32_t y, std::uint32_t width,
        std::uint32_t height, std::int32_t exclusiveZone, const char *keyboard
    );

    wl_display *mDisplay = nullptr;
    wl_registry *mRegistry = nullptr;
    nullspace_controller_v1 *mController = nullptr;
    QSocketNotifier *mNotifier = nullptr;
    QTimer mReconnectTimer;
    bool mConnected = false;
    std::uint32_t mNextSerial = 1;
};

} // namespace topbar::nullspace
