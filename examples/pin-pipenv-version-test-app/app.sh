#!/bin/bash

echo "Testing PIN_PIPENV_VERSION (set in .s2i/environment) ..."
pipenv_version=`pipenv --version`
expected="pipenv, version 2021.5.29"
if [ "$pipenv_version" != "$expected" ]; then
  echo "ERROR: pipenv version is different than expected."
  echo "Expected: ${expected}"
  echo "Actual: ${pipenv_version}"
  exit 1
fi

# Test the uwsgi server
exec uwsgi \
    --http-socket :8080 \
    --die-on-term \
    --master \
    --single-interpreter \
    --enable-threads \
    --threads=5 \
    --thunder-lock \
    --module wsgi
