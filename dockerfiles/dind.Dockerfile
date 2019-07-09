ARG DOCKER_VERSION
FROM docker:${DOCKER_VERSION}-dind

###
# Install docker-compose
# https://github.com/wernight/docker-compose
###

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    # Install glibc on Alpine (required by docker-compose) from
    # https://github.com/sgerrand/alpine-pkg-glibc
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk && \
    apk add glibc-2.29-r0.apk && \
    rm glibc-2.29-r0.apk && \
    apk del --purge .deps

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib:/usr/lib

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    # Required dependencies.
    apk add --no-cache zlib libgcc && \
    # Install docker-compose.
    # https://docs.docker.com/compose/install/
    DOCKER_COMPOSE_URL=https://github.com$(wget -q -O- https://github.com/docker/compose/releases/latest \
        | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' \
        | sed 's/^href="//' \
        | head -n1) && \
    wget -q -O /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    \
    # Clean-up
    apk del --purge .deps && \
    \
    # Basic check it works
    docker-compose version

ARG RAPIDS_HOME
ENV RAPIDS_HOME="$RAPIDS_HOME"
ENV RMM_HOME="$RAPIDS_HOME/rmm"
ENV CUDF_HOME="$RAPIDS_HOME/cudf"
ENV COMPOSE_HOME="$RAPIDS_HOME/compose"
ENV CUGRAPH_HOME="$RAPIDS_HOME/cugraph"
ENV CUSTRINGS_HOME="$RAPIDS_HOME/custrings"
ENV NOTEBOOKS_HOME="$RAPIDS_HOME/notebooks"
ENV NOTEBOOKS_EXTENDED_HOME="$RAPIDS_HOME/notebooks-extended"

ENV _UID=1000
ENV _GID=1000

ENV CUDA_VERSION=10.0
ENV LINUX_VERSION=ubuntu18.04

ENV PYTHON_VERSION=3.7
ENV RAPIDS_VERSION=latest
ENV RAPIDS_NAMESPACE=anon

WORKDIR "$RAPIDS_HOME"

COPY etc/dind/.dockerignore .dockerignore

ENTRYPOINT ["$RAPIDS_HOME/compose/etc/dind/build.sh"]

CMD [""]
