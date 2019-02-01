FROM ubuntu:12.04

# Install dependencies Change6
RUN apt-get update -y
RUN apt-get install -y git curl apache2 php5 libapache2-mod-php5 php5-mcrypt php5-mysql

# Install app
RUN rm -rf /var/www/*
ADD src /var/www
RUN mkdir -p /usr/local/etc/php/conf.d/	
RUN curl -L https://download.newrelic.com/php_agent/release/newrelic-php5-8.5.0.235-linux.tar.gz | tar -C /tmp -zx && \	
    export NR_INSTALL_USE_CP_NOT_LN=1 && \	
     export NR_INSTALL_SILENT=1 && \	
      /tmp/newrelic-php5-*/newrelic-install install && \	
       rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \	
        sed -i -e 's/"REPLACE_WITH_REAL_KEY"/"eu01xxd6f74796b9d6f1e33484dbcce588f539ff"/' \	
         -e 's/newrelic.appname = "PHP Application"/newrelic.appname = "CICD App"/' \	
           /etc/php5/cli/conf.d/newrelic.ini 	
RUN curl -X POST 'https://api.eu.newrelic.com/v2/applications/1481766/deployments.json' -H 'X-Api-Key:2d81334d6c3e1992f8e39bb4e8512491fb2cc9be8f539ff' -i -H 'Content-Type: application/json' -d '{  "deployment": {    "revision": "ADDITION",    "changelog": "Modified: index.php, Removed: None",    "description": "Production Deployment",    "user": "shaaloua@amazon.com"  }}'
# Configure apache
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D",  "FOREGROUND"]
