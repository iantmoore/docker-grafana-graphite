
FROM     ubuntu:14.04

# ---------------- #
#   Installation   #
# ---------------- #

ENV DEBIAN_FRONTEND noninteractive

# Install all prerequisites
RUN     apt-get -y install software-properties-common
RUN     add-apt-repository -y ppa:chris-lea/node.js
RUN     apt-get -y update
RUN     apt-get -y install python-django-tagging python-simplejson python-memcache python-ldap python-cairo python-pysqlite2 python-support \
                           python-pip gunicorn supervisor nginx-light nodejs git wget curl openjdk-7-jre build-essential python-dev

RUN     apt-get -y install nano                           

RUN     pip install Twisted==11.1.0
RUN     pip install Django==1.5
RUN     pip install pytz
RUN     npm install ini chokidar

# Checkout the stable branches of Graphite, Carbon and Whisper and install from there
# RUN     mkdir /src
# RUN     git clone https://github.com/graphite-project/whisper.git /src/whisper            &&\
#        cd /src/whisper                                                                   &&\
#        git checkout 0.9.x                                                                &&\
#        python setup.py install

# RUN     git clone https://github.com/graphite-project/carbon.git /src/carbon              &&\
#        cd /src/carbon                                                                    &&\
#        git checkout 0.9.x                                                                &&\
#        python setup.py install


# RUN     git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web  &&\
#        cd /src/graphite-web                                                              &&\
#        git checkout 0.9.x                                                                &&\
#        python setup.py install

# Install StatsD
# RUN     git clone https://github.com/etsy/statsd.git /src/statsd                                                                        &&\
#        cd /src/statsd                                                                                                                  &&\
#        git checkout v0.7.2



# Install collectd
# RUN     apt-get install -y collectd

RUN    apt-get install -y librrd4



RUN    wget https://pkg.ci.collectd.org/deb/dists/wheezy/collectd-5.5/binary-amd64/collectd_5.5.1.108.gae5cca2-1~wheezy_amd64.deb https://pkg.ci.collectd.org/deb/dists/wheezy/collectd-5.5/binary-amd64/collectd-core_5.5.1.108.gae5cca2-1~wheezy_amd64.deb http://fr.archive.ubuntu.com/ubuntu/pool/main/u/udev/libudev0_175-0ubuntu9_amd64.deb &&\
       dpkg -i collectd-core_5.5.1.108.gae5cca2-1~wheezy_amd64.deb &&\
       dpkg -i collectd_5.5.1.108.gae5cca2-1~wheezy_amd64.deb &&\
       dpkg -i libudev0_175-0ubuntu9_amd64.deb

#COPY  collectd_5.5.1-3_amd64.deb /collectd_5.5.1-3_amd64.deb


# INSTALL collectd from src
# RUN     mkdir /collectd-src && cd /collectd-src && wget https://collectd.org/files/collectd-5.5.0.tar.gz &&\
#          tar -xvzf collectd-5.5.0.tar.gz &&\
#          cd collectd-5.5.0 &&\
#          ./configure &&\
#          make all install 


# Install influx
Run     wget https://s3.amazonaws.com/influxdb/influxdb_0.11.0-1_amd64.deb  &&\
        sudo dpkg -i influxdb_0.11.0-1_amd64.deb



# Install Grafana
# RUN     mkdir /src/grafana                                                                                    &&\
#        mkdir /opt/grafana                                                                                    &&\
#        wget https://grafanarel.s3.amazonaws.com/builds/grafana-2.1.3.linux-x64.tar.gz -O /src/grafana.tar.gz &&\
#        tar -xzf /src/grafana.tar.gz -C /opt/grafana --strip-components=1                                     &&\
#        rm /src/grafana.tar.gz

RUN  wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.6.0_amd64.deb &&\
    apt-get install -y adduser libfontconfig &&\
    dpkg -i grafana_2.6.0_amd64.deb

# ----------------- #
#   Configuration   #
# ----------------- #

# Confiure StatsD
# ADD     ./statsd/config.js /src/statsd/config.js

# Configure Whisper, Carbon and Graphite-Web
# ADD     ./graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
# ADD     ./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
# ADD     ./graphite/carbon.conf /opt/graphite/conf/carbon.conf
# ADD     ./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
# ADD     ./graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
# RUN     mkdir -p /opt/graphite/storage/whisper
# RUN     touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
# RUN     chown -R www-data /opt/graphite/storage
# RUN     chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
# RUN     chmod 0664 /opt/graphite/storage/graphite.db
# RUN     cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput

# Configure Grafana
ADD     ./grafana/grafana.ini /etc/grafana/grafana.ini

# Add the default dashboards
# RUN     mkdir /src/dashboards
# ADD     ./grafana/dashboards/* /src/dashboards/
# RUN     mkdir /src/dashboard-loader
# ADD     ./grafana/dashboard-loader/dashboard-loader.js /src/dashboard-loader/

# Configure nginx and supervisord
ADD     ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD     ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# add collectd config
ADD     ./collectd/collectd.conf /etc/collectd/collectd.conf
RUN     mkdir /etc/collectd.d

# add influx config
ADD     /influxdb/influxdb.conf /etc/influxdb/influxdb.conf


# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana
EXPOSE  80

# StatsD / collectd UDP port
EXPOSE  8125/udp

# StatsD Management port
EXPOSE  8126

# Graphite web port
EXPOSE 81

# influx db port
EXPOSE 8086

# -------- #
#   Run!   #
# -------- #

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
