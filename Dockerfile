FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    bash git curl wget build-essencial \
    nano vim tzdata htop nvtop \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY start.sh /start.sh
COPY post_start.sh /post_start.sh
RUN chmod +x /start.sh /post_start.sh

CMD ["/start.sh"]