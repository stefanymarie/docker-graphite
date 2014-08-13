FROM ubuntu:trusty
MAINTAINER acaleph "admin@acale.ph"
# Thanks to Nick Stenning for the original graphite docker work

RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list
RUN apt-get -y update

# Install required packages
RUN apt-get -y install software-properties-common python-ldap python-cairo python-simplejson python-memcache python-pysqlite2 python-support python-pip python-dev gunicorn supervisor nginx-light memcached
RUN pip install whisper 'twisted<12.0' 'django<1.6.0' django-tagging
RUN pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
RUN pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# Install statsd
# RUN add-apt-repository ppa:chris-lea/node.js
# RUN apt-get -y update
# RUN apt-get -y install nodejs git
# RUN mkdir /src
# RUN git clone https://github.com/etsy/statsd.git /src/statsd
# ADD ./config.js /src/statsd/config.js



# ADD system service config
ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf



# ADD graphite config
ADD ./initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json
ADD ./local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
ADD ./carbon.conf /var/lib/graphite/conf/carbon.conf
ADD ./storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
RUN mkdir -p /var/lib/graphite/storage/whisper
RUN touch /var/lib/graphite/storage/graphite.db /var/lib/graphite/storage/index
RUN chown -R www-data /var/lib/graphite/storage
RUN chmod 0775 /var/lib/graphite/storage /var/lib/graphite/storage/whisper
RUN chmod 0664 /var/lib/graphite/storage/graphite.db
RUN cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput

ADD ./run.sh /var/lib/graphite/run.sh
RUN chmod 777 /var/lib/graphite/run.sh

# Nginx
EXPOSE 80
# Carbon line receiver port
EXPOSE 2003
# Carbon pickle receiver port
EXPOSE 2004
# Carbon cache query port
EXPOSE 7002

# Statsd UDP port
EXPOSE 8125/udp
# Statsd Management port
EXPOSE 8126

VOLUME ["/var/lib/graphite/storage/whisper"]
ENTRYPOINT ["/var/lib/graphite/run.sh"]
