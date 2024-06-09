FROM ghcr.io/graalvm/jdk:java8

# https://github.com/quarkusio/quarkus-images/issues/112
# https://github.com/quarkusio/quarkus-images/pull/113

# Issues:
# 1.
# - getting null pointer exception when running benchmarks and creating images
# - https://github.com/AdoptOpenJDK/openjdk-docker/issues/75
# - https://github.com/docker-library/openjdk/issues/46
# - libfontconfig1 contained in fontconfig

RUN microdnf update libdnf && \
    microdnf install freetype.x86_64 fontconfig

ENTRYPOINT [ "bash" ]
