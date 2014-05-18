#!/bin/sh
#
# AppDynamics Machine Agent init script
#
# chkconfig: - 98 3
# description: AppDynamics Machine Agent

# Source function library.
. /etc/init.d/functions
. /etc/profile

RETVAL=0

JAVA="/usr/java/latest/bin/java"

AGENT_HOME="/opt/appdynamics/machineagent"
AGENT="$AGENT_HOME/machineagent.jar"

AGENT_OPTIONS="$AGENT_OPTIONS -Xmx10m"

AGENT_LOG="$AGENT_HOME/machineagent.log"

prog="AppDynamics Machine Agent"

start() {
        # Start daemon.
        echo -n $"Starting $prog"
        daemon --user=appdynamics "$JAVA $AGENT_OPTIONS -jar $AGENT > $AGENT_LOG 2>&1 &"
        RETVAL=$?
        [ $RETVAL -eq 0 ]
        return $RETVAL
}

stop() {
        # Stop daemon.
        action  $"Shutting down $prog: " pkill -f machineagent.jar
        RETVAL=$?
        [ $RETVAL -eq 0 ]
        return $RETVAL
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart|reload)
        stop
        sleep 5s
        start
        RETVAL=$?
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac

exit $RETVAL
