#!/bin/bash
name="$1"
sshURL="$2"

nodePort=`cat env/nodePort`
export NODEPORT=$nodePort
forever stop $workingPath/node_rtc/app.js

rm -rf /var/www/gitwrapper/$name
rm /etc/apache2/sites-enabled/$name.conf


/usr/sbin/service apache2 restart

exit 0
