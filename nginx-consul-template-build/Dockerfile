FROM nginx:alpine

ARG CONSUL_TEMPLATE_VERSION

ENV CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION:-0.18.1}
ENV CONSUL_ADDRESS=${CONSUL_ADDRESS:-localhost:8500}

WORKDIR /tmp

CMD ["./entrypoint.sh"]

RUN apk update && \
    apk add --update openssl && \
    apk add --update ca-certificates

RUN wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    sha256sum -c consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS 2>&1 | grep OK && \    
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template /usr/local/bin/consul-template && \
    rm -rf /tmp/*

COPY entrypoint.sh .
COPY nginx-consul-template-config.conf /etc/consul-template-configs/
COPY nginx-default.ctmpl /ctemplates/