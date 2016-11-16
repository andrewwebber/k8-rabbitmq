#!/usr/bin/env bash

set -x

untilsuccessful() {
  "$@"
  status=$?
  while [ $status -ne 0 -a $status -ne 2 ]
  do
    echo Retrying... $status
    sleep 1
    "$@"
    status=$?
  done

  echo Success $status
}

function clean_up {

	# Perform program exit housekeeping
	echo "# Perform program exit housekeeping $(echo $C_PID)"
  kill -SIGTERM $C_PID
  wait $C_PID
	exit
}

trap 'clean_up' SIGHUP SIGINT SIGTERM SIGKILL TERM

ln -sf /dev/stdout /var/log/rabbitmq/rabbitmq.log
# ln -sf /dev/stderr /var/log/rabbitmq/rabbitmq.log

docker-entrypoint.sh rabbitmq-server > /var/log/rabbitmq/rabbitmq.log &

C_PID=$!
sleep 10
untilsuccessful curl localhost:15672
untilsuccessful rabbitmqctl set_policy ha-all "" '{"ha-mode":"all","ha-sync-mode":"automatic"}'

if [ "$HOSTNAME" = "rabbitmq1" ]; then
  echo "Master skipping clustering"
else
  echo "Auto Rebalanceing"
  untilsuccessful rabbitmqctl stop_app
  untilsuccessful curl rabbitmq1:15672
  untilsuccessful rabbitmqctl join_cluster rabbit@rabbitmq1
  untilsuccessful rabbitmqctl start_app
fi;

wait $C_PID
