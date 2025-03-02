FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    gnucobol \
    gcc \
    && apt-get clean

WORKDIR /app

COPY ProcessTSV.cbl /app/
COPY run.sh /app/

RUN chmod +x /app/run.sh

ENTRYPOINT ["/app/run.sh"]
