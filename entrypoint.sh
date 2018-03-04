#!/bin/bash

cat <<EOF
Welcome to the marvambass/nginx-ssl-secure container

IMPORTANT:
  IF you use SSL inside your personal NGINX-config,
  you should add the Strict-Transport-Security header like:

    # only this domain
    add_header Strict-Transport-Security "max-age=31536000";
    # apply also on subdomains
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

  to your config.
  After this you should gain a A+ Grade on the Qualys SSL Test

EOF

if [ -z ${DH_SIZE+x} ]
then
  >&2 echo ">> no \$DH_SIZE specified using default" 
  DH_SIZE="2048"
fi


DH="/usr/share/nginx/html/dh.pem"

if [ ! -e "$DH" ]
then
  echo ">> seems like the first start of nginx"
  echo ">> doing some preparations..."
  echo ""

  echo ">> generating $DH with size: $DH_SIZE"
  openssl dhparam -out "$DH" $DH_SIZE
fi

if [ ! -e "/usr/share/nginx/html/cert.pem" ] || [ ! -e "/usr/share/nginx/html/key.pem" ]
then
  echo ">> generating self signed cert"
  openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
  -keyout "/usr/share/nginx/html/key.pem" \
  -out "/usr/share/nginx/html/cert.pem" \
  -days 3650 -nodes -sha256
fi

echo ">> copy /usr/share/nginx/html/*.conf files to /etc/nginx/conf.d/"
cp /usr/share/nginx/html/*.conf /etc/nginx/conf.d/ 2> /dev/null > /dev/null

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
