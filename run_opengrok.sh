#!/bin/sh

set -x

INOTIFY_CMD="inotifywait -mr -e CLOSE_WRITE $OPENGROK_SRC_ROOT"
REINDEX_GRACE_PERIOD=10  # [secs]
REINDEX_INTERVAL=20  # [secs]


catalina.sh run &

echo "----- source code indexing -----" 1>&2
${OPENGROK_INSTANCE_BASE}/bin/OpenGrok index $OPENGROK_SRC_ROOT

while true; do
    $INOTIFY_CMD | while read _; do
        echo "----- reindex grace period: $REINDEX_GRACE_PERIOD secs -----" 1>&2
        sleep $REINDEX_GRACE_PERIOD

        echo "----- reindexing: $(date --rfc-3339=seconds) -----" 1>&2
        ${OPENGROK_INSTANCE_BASE}/bin/OpenGrok index $OPENGROK_SRC_ROOT

        # discard changes during the grace period and the reindexing
        break
    done

    echo "----- reindex interval: $REINDEX_INTERVAL secs -----" 1>&2
    sleep $REINDEX_INTERVAL
done
