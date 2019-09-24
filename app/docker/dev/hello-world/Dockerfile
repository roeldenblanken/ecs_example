FROM alpine AS build-tools

# Set proxy of host in docker container:
ARG http_proxy
ENV http_proxy ${http_proxy:-""} 
ENV https_proxy=$http_proxy
ENV HTTP_PROXY=$http_proxy
ENV HTTPS_PROXY=$http_proxy
ENV ftp_proxy=$http_proxy
ENV rsync_proxy=$http_proxy
ENV socks_proxy=$http_proxy
ENV all_proxy=$http_proxy
ENV no_proxy="localhost,127.0.0.1,0.0.0.0,.intranet,.ing.nl,ing.net,192.168.99.100"
ENV NO_PROXY="localhost,127.0.0.1,0.0.0.0,.intranet,.ing.nl,ing.net,192.168.99.100"

# Install build tools
RUN apk add --no-cache --virtual .build-deps                         \
        build-base                                                   \
        gnupg                                                        \
        pcre-dev                                                     \
        wget                                                         \
        zlib-dev

FROM build-tools AS retrieve

# Define build argument for version
ARG VERSION
ENV VERSION ${VERSION:-1.17.3}

# Retrieve and verify Nginx source
RUN wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz   --no-check-certificate  && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz.asc --no-check-certificate

# Extract archive
RUN tar xf nginx-${VERSION}.tar.gz

FROM retrieve As build

WORKDIR nginx-${VERSION}

# Build and install nginx
RUN ./configure                                                      \
        --with-ld-opt="-static"                                      \
        --with-http_sub_module                                    && \
    make install                                                  && \
    strip /usr/local/nginx/sbin/nginx

FROM alpine

WORKDIR /usr/local/nginx/html

# Customise static content, and configuration
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY docker/dev/hello-world/assets /usr/local/nginx/html/
COPY docker/dev/hello-world/nginx.conf /usr/local/nginx/conf/

# Symlink access and error logs to /dev/stdout and /dev/stderr,
# in order to make use of Docker's logging mechanism
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log            && \
    ln -sf /dev/stderr /usr/local/nginx/logs/error.log

# Add entrypoint script
COPY docker/dev/hello-world/docker-entrypoint.sh /

# Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

# Expose port
EXPOSE 80

# Define entrypoint and default parameters
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
