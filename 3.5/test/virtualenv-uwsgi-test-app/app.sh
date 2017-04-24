#!/bin/bash

# First test virtualenv environment and pip upgrade

echo "Testing that the virtual environment's Python is being used ..."
if [ "$(which python)" != "/opt/app-root/bin/python" ]; then
    echo "ERROR: Initialization of the virtual environment failed."
    exit 1
fi

echo "Testing UPGRADE_PIP_TO_LATEST=1 (set in .s2i/environment) ..."
pip_major_version=$(pip --version | cut -d" " -f2 | cut -d"." -f1)
if [ -z "$pip_major_version" ] || [ "$pip_major_version" -lt "9" ]; then
    echo "ERROR: Failed to upgrade pip to version 9 or later."
    exit 1
fi


# Now test the uwsgi server

exec uwsgi \
    --http-socket :8080 \
    --die-on-term \
    --master \
    --single-interpreter \
    --enable-threads \
    --threads=5 \
    --thunder-lock \
    --module wsgi
