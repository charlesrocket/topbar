if (PCH)
    add_library(topbar-pch INTERFACE)
    target_precompile_headers(topbar-pch INTERFACE
        <cstdint>
        <cstring>
        <qobject.h>
        <qfile.h>
        <qqmlintegration.h>
        <qqmlcomponent.h>
        <qqmlengine.h>
        <qlogging.h>
        <qloggingcategory.h>
        <qprocess.h>
        <qproperty.h>
        <qstring.h>
        <qvariant.h>
        <qtimer.h>
        <qtmetamacros.h>
        <qdir.h>
        <qlist.h>
        <qsocketnotifier.h>
        <qstringlist.h>
        <qpointer.h>
    )
endif()
