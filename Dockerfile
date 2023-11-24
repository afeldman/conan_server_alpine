FROM python:3.7-alpine

LABEL org.opencontainers.image.authors="anton feldmann <anton.feldmann@gmail.com>"
LABEL version="1.1"
LABEL description="conan server in docker container"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        git \
        apache2-mod-wsgi \
        openssl-dev \
        openldap-dev \ 
        build-base \
        make \
        bash \
        findutils \
        envsubst

# build project source is recomended for stable
RUN pip install --upgrade pip && \
    pip install conan-server && \
    pip install conan_ldap_authentication && \
    pip install conan && \
    pip install gunicorn

ARG USERNAME="conan_user"
ENV HOME="/home/${USERNAME}"

RUN adduser --uid 1001 ${USERNAME} --home ${HOME} --system --disabled-password && \
	chmod a+x ${HOME}

COPY conan_server /sbin/conan-server
RUN chmod +x /sbin/conan-server

USER ${USERNAME}

ENV CONAN_SERVER_HOME="${HOME}/.conan_server"

COPY server.tmpl /tmp/server.tmpl
COPY ldap_authentication.tmpl /tmp/ldap_authentication.tmpl

ENTRYPOINT "/sbin/conan-server"
