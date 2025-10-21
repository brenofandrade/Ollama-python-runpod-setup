FROM ubuntu:22.04

RUN apt update && apt install -y vim htop curl tar gzip 

RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /

RUN mkdir workspace

COPY start.sh /start.sh
COPY post_start.sh /post_start.sh
RUN chmod +x /start.sh /post_start.sh

CMD ["/start.sh"]
