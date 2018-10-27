#!/bin/sh

set -x

INOTIFY_CMD="inotifywait -mr -e CLOSE_WRITE $OPENGROK_SRC_ROOT"
REINDEX_GRACE_PERIOD=10  # [secs]
REINDEX_INTERVAL=20  # [secs]

DATE_CMD="date --rfc-3339=seconds"

catalina.sh run &

${OPENGROK_INSTANCE_BASE}/bin/OpenGrok index $OPENGROK_SRC_ROOT
echo "----- $($DATE_CMD): source code indexing -----" 1>&2

while true; do
    $INOTIFY_CMD | while read _; do
        echo "----- $($DATE_CMD): reindex grace period: $REINDEX_GRACE_PERIOD secs -----" 1>&2
        sleep $REINDEX_GRACE_PERIOD

        ${OPENGROK_INSTANCE_BASE}/bin/OpenGrok index $OPENGROK_SRC_ROOT
        echo "----- $($DATE_CMD): reindexing -----" 1>&2

        # discard changes during the grace period and the reindexing
        break
    done

    echo "----- $($DATE_CMD): reindex interval: $REINDEX_INTERVAL secs -----" 1>&2
    sleep $REINDEX_INTERVAL
done
