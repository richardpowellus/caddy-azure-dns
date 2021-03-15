FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/azure \
    --with github.com/greenpau/caddy-auth-portal \
    --with github.com/greenpau/caddy-auth-jwt

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
