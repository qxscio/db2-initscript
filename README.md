db2-initscript
==============

IBM DB2 initscript for RedHat/CentOS 5 and 6 useful when creating an active/passive cluster with Red Hat Cluster Suite.


Copy the script to `/etc/init.d/` and give it execute permissions:

    # cp db2 /etc/init.d/
    # chmod +x /etc/init.d/db2

Set the instance owner variable in the script (i.e. db2inst1):

    DB2USER=db2inst1

and optionally rename it to `db2-$DB2USER`(in case of multiple instances):

    # cp /etc/init.d/db2 /etc/init.d/db2-db2inst1

Usage:

    service db2 {start|stop|restart|status}