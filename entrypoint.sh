#!/bin/bash

set -eof pipefail

#chown -R munge:munge /etc/munge
#chmod 400 /etc/munge/munge.key
#chmod 700 /etc/munge
#/sbin/runuser munge -s /bin/bash -c /usr/sbin/munged
/bin/bash -c "java -jar /opt/cromwell/cromwell.jar $1"

