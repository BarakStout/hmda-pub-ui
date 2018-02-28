#!/bin/bash

get_baseurl () {
  local proto=$(echo ${1} | sed -e's,^\(.*://\).*,\1,g')
  local baseUrl=$(echo ${1} | awk -F/ '{print $3}')
  echo "${proto}${baseUrl}"
}

HMDA_API_SERVER=$(get_baseurl ${HMDA_API})

if [ -f ./reports/js/app.min.js.bak ]; then
  sed \
    -e "s@##APP_URL##@${APP_URL:-https://192.168.99.100}@"\
    -e "s@##HMDA_API##@${HMDA_API:-https://192.168.99.100:4443/hmda}@"\
    ./reports/js/app.min.js.bak > ./reports/js/app.min.js
else
  sed -i.bak \
    -e "s@##APP_URL##@${APP_URL:-https://192.168.99.100}@"\
    -e "s@##HMDA_API##@${HMDA_API:-https://192.168.99.100:4443/hmda}@"\
    ./reports/js/app.min.js
fi

if [ -f /etc/nginx/nginx.tmpl ]; then
  sed \
  -e "s@##APP_SERVER##@${APP_URL:-https://192.168.99.100}@g"\
  -e "s@##HMDA_API_SERVER##@${HMDA_API_SERVER:-https://192.168.99.100:4443}@g"\
  /etc/nginx/nginx.tmpl > /etc/nginx/nginx.conf
fi
