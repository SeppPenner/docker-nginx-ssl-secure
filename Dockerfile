FROM nginx:latest
MAINTAINER SeppPenner

RUN apt-get update; \
	apt-get install -y wget; \
	apt-get install -y unzip; \
	apt-get install -y openssl

RUN wget https://www.phpbb.com/files/release/phpBB-3.2.2.zip

RUN mkdir -p /usr/share/nginx/html

RUN unzip phpBB-3.2.2.zip -d /usr/share/nginx/html; \
	rm phpBB-3.2.2.zip

RUN cd /usr/share/nginx/html/phpBB3; \
	chmod 666 config.php; \
	chmod 777 store/; \
	chmod 777 cache/; \
	chmod 777 files/; \
	chmod 777 images/avatars/upload/

ENV LANG C.UTF-8

RUN rm -rf /etc/nginx/conf.d/*;

RUN sed -i 's/access_log.*/access_log \/dev\/stdout;/g' /etc/nginx/nginx.conf; \
    sed -i 's/error_log.*/error_log \/dev\/stdout info;/g' /etc/nginx/nginx.conf; \
    sed -i 's/^pid/daemon off;\npid/g' /etc/nginx/nginx.conf

ADD basic.conf /etc/nginx/conf.d/basic.conf
ADD ssl.conf /etc/nginx/conf.d/ssl.conf

ADD entrypoint.sh /opt/entrypoint.sh
RUN chmod a+x /opt/entrypoint.sh

VOLUME /usr/share/nginx/html

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["nginx"]