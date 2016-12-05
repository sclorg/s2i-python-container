#!/bin/bash

exec uwsgi \
    --http-socket :8080 \
    --die-on-term \
    --master \
    --single-interpreter \
    --enable-threads \
    --threads=5 \
    --thunder-lock \
    --module wsgi
