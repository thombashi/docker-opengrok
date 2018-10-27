#!/bin/sh

set -x

INOTIFY_CMD="inotifywait --recursive --event close_write $OPENGROK_SRC_ROOT"
REINDEX_GRACE_PERIOD=10  # [secs]
REINDEX_INTERVAL=20  # [secs]

DATE_CMD="date --rfc-3339=seconds"

catalina.sh run &

echo "----- $($DATE_CMD): source code indexing -----" 1>&2
${OPENGROK_INSTANCE_BASE}/bin/OpenGrok index $OPENGROK_SRC_ROOT

while true; do
    while $INOTIFY_CMD ; do
        echo "----- $($DATE_CMD): reindex grace period: $REINDEX_GRACE_PERIOD secs -----" 1>&2
        sleep $REINDEX_GRACE_PERIOD

        echo "----- $($DATE_CMD): reindexing -----" 1>&2
        ${OPENGROK_INSTANCE_BASE}/bin/OpenGrok index $OPENGROK_SRC_ROOT

        # discard changes during the grace period and the reindexing
        break
    done

    echo "----- $($DATE_CMD): reindex interval: $REINDEX_INTERVAL secs -----" 1>&2
    sleep $REINDEX_INTERVAL
done
