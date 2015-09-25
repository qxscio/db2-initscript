#!/bin/bash
#
# Author: ruggero DOT marchei AT daemonzone DOT net
# Version: 1.00
#
# chkconfig: - 30 70
# description:  start/stop a db2 instance

# Source function library.
[[ -f /etc/init.d/functions ]] || exit 1
. /etc/init.d/functions


##########################################################

# Set the Instance owner:
DB2USER=

# [OPTIONAL] Set the db2nodes.cfg (DB2 ESE only):
DB2NODES_CFG="0 ${HOSTNAME} 0"

##########################################################

# Exit if the Instance owner is not set
[[ -n ${DB2USER} ]] || { echo "Instance owner not set" && exit 1; }



HOSTNAME=$(hostname -f)

RETVAL=0

find_homedir() {
    getent passwd $1 | cut -d":" -f 6
}

start() {
    LOGFILE=$(mktemp)
    INSTHOME="$(find_homedir ${DB2USER})/sqllib"
    [[ -n ${DB2NODES_CFG} ]] && echo ${DB2NODES_CFG} > ${INSTHOME}/db2nodes.cfg
    echo -n $"Starting IBM DB2 instance [${DB2USER}]"
    daemon --user=${DB2USER} "source ${INSTHOME}/db2profile && db2start" \
        >${LOGFILE} 2>&1 && success || failure
    RETVAL=$?
    [[ $RETVAL -ne 0 ]] && cat ${LOGFILE}
    rm -f ${LOGFILE}
    echo ""
}

status() {
    INSTHOME="$(find_homedir ${DB2USER})/sqllib"
    su - ${DB2USER} -c \
        "source ${INSTHOME}/db2profile && db2gcf -s" > /dev/null 2>&1
    RETVAL=$?
}

stop() {
    LOGFILE=$(mktemp)
    INSTHOME="$(find_homedir ${DB2USER})/sqllib"

    echo -n $"Stopping IBM DB2 instance [${DB2USER}]"

    # Is DB2 already stopped?
    status
    if [ $RETVAL -ne 0 ]; then
        # Already stopped return 0
        success
        RETVAL=0
        echo ""
    else
        daemon --user=${DB2USER} \
            "source ${INSTHOME}/db2profile && db2stop force" \
            >${LOGFILE} 2>&1 && success || failure
        RETVAL=$?
        if [ $RETVAL -ne 0 ]; then
        daemon --user=${DB2USER} \
            "source ${INSTHOME}/db2profile && db2_kill" \
            >>${LOGFILE} 2>&1 && success || failure
        fi
        echo ""
    fi
    [[ $RETVAL -ne 0 ]] && cat ${LOGFILE}
    rm -f ${LOGFILE}
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop 
        ;;

    status)
        status
        if [ $RETVAL -gt 0 ]; then
            echo "DB2 instance ${DB2USER} is not running"
        else
            echo "DB2 instance ${DB2USER} is running"
        fi
        ;;

    restart)
        stop
        sleep 3
        start
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|status}"
        RETVAL=1
        ;;
esac

exit $RETVAL
