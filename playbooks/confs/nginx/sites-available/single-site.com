server {
	# Ports to listen on
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;

	# Server name to listen for
	server_name protocoloipe.com;

	# Path to document root
	root /sites/protocoloipe.com/public;

	# Paths to certificate files.
	ssl_certificate /etc/letsencrypt/live/protocoloipe.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/protocoloipe.com/privkey.pem;

	# File to be used as index
	index index.html index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/protocoloipe.com/logs/access.log;
	error_log /sites/protocoloipe.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	# SSL rules
	include global/server/ssl.conf;

	# Advertises support for HTTP/3
	add_header Alt-Svc 'h3=":443"; ma=86400' always;
}

# Redirect http to https
server {
	listen 80;
	listen [::]:80;
	server_name protocoloipe.com www.protocoloipe.com;

	return 301 https://protocoloipe.com$request_uri;
}

# Redirect www to non-www
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;
	
	server_name www.protocoloipe.com;

	# Advertises support for HTTP/3
	add_header Alt-Svc 'h3=":443"; ma=86400';

	return 301 https://protocoloipe.com$request_uri;
}
