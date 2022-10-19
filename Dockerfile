FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/greenpau/caddy-security

FROM caddy

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash && \
    apk add --no-cache nano && \
    rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
