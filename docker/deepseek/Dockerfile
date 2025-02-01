FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0:11434

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl python3 python3-pip pciutils && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


COPY install_and_run.sh /usr/local/bin/install_and_run.sh
RUN chmod +x /usr/local/bin/install_and_run.sh

EXPOSE 11434

VOLUME /data

ENTRYPOINT ["/usr/local/bin/install_and_run.sh"]
