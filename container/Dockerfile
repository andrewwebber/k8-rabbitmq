FROM rabbitmq:management
RUN apt-get update -y
RUN apt-get install curl -y
COPY ./cluster.sh /opt/bin/cluster.sh
RUN chmod +x /opt/bin/cluster.sh
ENTRYPOINT ["/opt/bin/cluster.sh"]
CMD [""]
