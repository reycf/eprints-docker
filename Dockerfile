FROM buildpack-deps:jessie

RUN apt-get update \
    && apt-get install -y --force-yes \
    vim \
    expect \

    perl libncurses5 apache2-mpm-prefork libapache2-mod-perl2 \
    libxml-libxml-perl libunicode-string-perl libterm-readkey-perl \
    libmime-lite-perl libmime-types-perl libxml-libxslt-perl \
    libdigest-sha-perl libdbd-mysql-perl libxml-parser-perl libxml2-dev \
    libxml-twig-perl libarchive-any-perl libjson-perl lynx wget \
    ghostscript xpdf antiword elinks pdftk texlive-base texlive-base-bin \
    psutils imagemagick mysql-client libsearch-xapian-perl \
    libcgi-pm-perl \

    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure Apache mods
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork

# configure users and groups
RUN addgroup eprints && \
    adduser --system --home /usr/share/eprints3 --shell /bin/bash --group eprints && \
    adduser www-data eprints && \
    adduser eprints www-data

# fetch EPrints source
USER eprints
RUN cd /usr/share/eprints3 && \
    curl -L -O -f http://files.eprints.org/1073/2/eprints-3.3.15.tar.gz && \
    tar xfz eprints-3.3.15.tar.gz && \
    rm eprints-3.3.15.tar.gz

# install EPrints (default : /opt/eprints3)
RUN cd /usr/share/eprints3/eprints-3.3.15 && \
    ./configure

USER root
RUN cd /usr/share/eprints3/eprints-3.3.15 && \
    chmod a+x install.pl && \
    ./install.pl

# postinst
RUN echo "Include /opt/eprints3/cfg/apache.conf" > /etc/apache2/sites-available/eprints && \
    ln -fs /etc/apache2/sites-available/eprints /etc/apache2/sites-available/eprints.conf && \
    ln -fs /opt/eprints3/bin/epindexer /etc/init.d/epindexer && \
    update-rc.d epindexer defaults 99 99 && \
    chown eprints:www-data /opt/eprints3 -R && \
    chmod g+w /opt/eprints3/lib -R && \
	chmod g+w /opt/eprints3/var

#RUN mkdir -p /usr/share/eprints3/scripts
COPY ./scripts /usr/share/eprints3/scripts
RUN chmod a+x /usr/share/eprints3/scripts/*

USER eprints
RUN /usr/share/eprints3/scripts/epadmin_create

USER root
RUN a2ensite eprints && \
    service apache2 stop
