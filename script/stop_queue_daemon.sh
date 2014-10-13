DAEMON_PID=`cat log/queue_daemon_pid`
echo Killing process ${DAEMON_PID}.
kill $DAEMON_PID
echo Process killed.