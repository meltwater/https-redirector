FROM centos:7

# Install Epel YUM repo
RUN yum -y install epel-release && \
	yum clean all

# Mako for config templates
RUN yum -y install python-mako && \
	yum clean all

# Install Nginx
RUN rpm -i "http://nginx.org/packages/rhel/7/noarch/RPMS/nginx-release-rhel-7-0.el7.ngx.noarch.rpm"
RUN yum -y install nginx && \
	yum clean all

# Clear the default config file
RUN echo "" > /etc/nginx/conf.d/default.conf

# Have Nginx determine number of worker processes automatically (using CPU count)
RUN sed -i 's/worker_processes .*/worker_processes auto\;/g' /etc/nginx/nginx.conf

# Delete log statements in favor of the ones from the template file
RUN sed -i 's/access_log .*/access_log \/proc\/self\/fd\/1 main\;/g' /etc/nginx/nginx.conf
RUN sed -i 's/error_log .*/error_log \/proc\/self\/fd\/2\;/g' /etc/nginx/nginx.conf

# The Timeout value must be greater than the front facing load balancers timeout value.
# Default is the deis recommended timeout value for ELB - 1200 seconds + 100s extra.
RUN sed -i 's/keepalive_timeout .*/keepalive_timeout 1300;/g' /etc/nginx/nginx.conf

# Run in foreground
RUN echo 'daemon off;' >> /etc/nginx/nginx.conf

COPY nginx.tpl /etc/nginx/conf.d/default.conf.tpl
COPY redirector.py redirector.sh /

ENTRYPOINT ["/redirector.sh"]
