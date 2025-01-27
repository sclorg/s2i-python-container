#!/bin/bash

# Test virtualenv environment and pip upgrade

echo "Testing that the virtual environment's Python is being used ..."
if [ "$(which python)" != "/opt/app-root/bin/python" ]; then
    echo "ERROR: Initialization of the virtual environment failed."
    exit 1
fi


echo "Testing that the virtual environment is active ..."
if ! export | grep -q 'VIRTUAL_ENV="/opt/app-root"'; then
    echo "VIRTUAL_ENV is not set properly!"
    export
    exit 1
fi


echo "Testing UPGRADE_PIP_TO_LATEST=1 (set in .s2i/environment) ..."
packages=("pip" "setuptools" "wheel")
for pkg in ${packages[@]}; do
  # grep returns exit code 1 if the output contains only one line starting
  # with "Requirement already …" which means that the package is updated
  python -m pip install -U --no-deps $pkg 2>&1 | grep -Ev "^Requirement already (up-to-date|satisfied): "
  if [ $? -eq 0 ]; then
    echo "ERROR: Failed to upgrade '$pkg' to the latest version."
    exit 1
  fi
done

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
