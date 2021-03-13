FROM caddy:builder AS builder

RUN xcaddy build \
    --with https://github.com/caddy-dns/azure 

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
