#!/bin/bash

# First test virtualenv environment and pip upgrade

# Get the latest stable version of the package released on PyPI
function get_latest_stable_version() {
  echo $(curl -s 'https://pypi.python.org/pypi/'$1'/json' | python -c \
"""
import sys
import json
from pip._vendor.packaging.version import parse
versions = [parse(v) for v in json.load(sys.stdin)['releases'].keys()]
print(str((sorted([v for v in versions if not v.is_prerelease])[-1])))
""")
}

# Get version of the package installed on the system
function get_installed_version() {
  echo $(pip3 freeze --all | grep $1 | cut -d"=" -f3)
}

echo "Testing that the virtual environment's Python is being used ..."
if [ "$(which python)" != "/opt/app-root/bin/python" ]; then
    echo "ERROR: Initialization of the virtual environment failed."
    exit 1
fi

echo "Testing UPGRADE_PIP_TO_LATEST=1 (set in .s2i/environment) ..."
packages=("pip" "setuptools" "wheel")
for pkg in ${packages[@]}; do
  if [ $(get_latest_stable_version $pkg) != $(get_installed_version $pkg) ]; then
    echo "ERROR: Failed to upgrade '$pkg' to the latest version."
    exit 1
  fi
done


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
