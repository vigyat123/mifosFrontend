#!/bin/bash

set -e

sudo su
chmod 755 /etc/nginx/nginx.conf

if [[ -f /etc/nginx/nginx.conf ]]; then
    rm /etc/nginx/nginx.conf
fi
cat > /etc/nginx/nginx.conf <<'EOF'

#user  nobody;

#Defines which Linux system user will own and run the Nginx server


#Referes to single threaded process. Generally set to be equal to the number of CPUs or cores.
worker_processes  1;

#Specifies the file where server logs. 
#error_log  logs/error.log; #error_log  logs/error.log  notice;

#nginx will write its master process ID(PID).
#pid        logs/nginx.pid;

events {
    # worker_processes and worker_connections allows you to calculate maxclients value: 
    # max_clients = worker_processes * worker_connections
    worker_connections  1024;
}


http {
    # anything written in /opt/nginx/conf/mime.types is interpreted as if written inside the http { } block
    include       mime.types;
    
    default_type  application/octet-stream;
    #access_log  logs/access.log  main;
    
    # If serving locally stored static files, sendfile is essential to speed up the server,
    # But if using as reverse proxy one can deactivate it
    sendfile        on;
    
    # works opposite to tcp_nodelay. Instead of optimizing delays, it optimizes the amount of data sent at once.  
    tcp_nopush     on;
    
    # timeout during which a keep-alive client connection will stay open.
    keepalive_timeout  65;
    
    # tells the server to use on-the-fly gzip compression.
    #gzip  on;
    
    server {
        # You would want to make a separate file with its own server block for each virtual domain
        # on your server and then include them.
        # listen       443;
        #tells Nginx the hostname and the TCP port where it should listen for HTTP connections.
        # listen 80; is equivalent to listen *:80;
        
        # server_name  _;
        # Lets you doname-based virtual hosting
        # charset koi8-r;
        # access_log  logs/host.access.log  main;
        
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name ec2-54-236-182-186.compute-1.amazonaws.com;
        return 302 https://$server_name$request_uri;
                 
    }
    
    
    # HTTPS server
    server {
        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;
        server_name  ec2-54-236-182-186.compute-1.amazonaws.com;
        root   /tmp/codedeploy-deployment-staging-area-angular/community-app;
        index  index.html index.htm;
        ssl_certificate      softcell_openssl_ss.crt;
        ssl_certificate_key  softcell_openssl_pub.key;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
        ssl_protocols TLSv1.1 TLSv1.2;
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
        ssl_prefer_server_ciphers on;
        
# Try Files Directive needs to be investigated. (Check CFM & VCM Applicaion)
        #location /fineract-provider/api/v1 {
        #    proxy_redirect https://ec2-34-229-232-200.compute-1.amazonaws.com;
        #}
       location = /50x.html {
           root   html;
      }
  }
}
EOF
service nginx start
