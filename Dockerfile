# build universal ctags --------------------------------------------
FROM thombashi/universal-ctags-installer:latest AS ctags-builder

WORKDIR /dist
RUN universal_ctags_installer /dist


# launch opengrok --------------------------------------------
FROM tomcat:8.5-jre8-slim
LABEL maintainer="Tsuyoshi Hombashi <tsuyoshi.hombashi@gmail.com>"

COPY --from=ctags-builder /dist/bin/ctags /usr/local/bin/ctags

ENV OPENGROK_VERSION 1.0
ENV OPENGROK_INSTANCE_BASE /opengrok
ENV OPENGROK_SRC_ROOT /src
ENV OPENGROK_TOMCAT_BASE /usr/local/tomcat

ENV CATALINA_BASE /usr/local/tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_TMPDIR /usr/local/tomcat/temp
ENV JRE_HOME /usr
ENV CLASSPATH /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    inotify-tools \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $OPENGROK_INSTANCE_BASE
RUN set -eux ; \
    mkdir data etc ; \
    OPENGROK_ARCHIVE_FILE=opengrok-${OPENGROK_VERSION}.tar.gz ; \
    OPENGROK_ARCHIVE_URL=https://github.com/oracle/opengrok/releases/download/${OPENGROK_VERSION}/${OPENGROK_ARCHIVE_FILE} ; \
    wget --quiet -O - $OPENGROK_ARCHIVE_URL | tar zxf - ; \
    mv opengrok-${OPENGROK_VERSION}/* . ; \
    ./bin/OpenGrok deploy ;

COPY run_opengrok.sh /usr/local/bin/run_opengrok
RUN chmod 544 /usr/local/bin/run_opengrok

ENTRYPOINT ["run_opengrok"]

EXPOSE 8080
