#!/bin/bash

# Test virtualenv environment and pip upgrade

echo "Testing that the virtual environment's Python is being used ..."
if [ "$(which python)" != "/opt/app-root/bin/python" ]; then
    echo "ERROR: Initialization of the virtual environment failed."
    exit 1
fi

echo "Testing UPGRADE_PIP_TO_LATEST=1 (set in .s2i/environment) ..."
packages=("pip" "setuptools" "wheel")
for pkg in ${packages[@]}; do
  # grep returns exit code 1 if the output contains only one line starting
  # with "Requirement already …" which means that the package is updated
  python -m pip install -U --no-python-version-warning $pkg 2>&1 | grep -v "^Requirement already up-to-date: "
  if [ $? -eq 0 ]; then
    echo "ERROR: Failed to upgrade '$pkg' to the latest version."
    exit 1
  fi
done


# Test that npm works correctly

# Create a package.json file so npm doesn't throw off warnings
echo "Initializing npm and testing the installation and use of a module ..."
npm init -y

# mkdirp chosen because it's on the list of 'most depended-upon packages':
#   https://www.npmjs.com/browse/depended
npm install mkdirp
if [ $? -ne 0 ]; then
    echo "ERROR: Installation of npm module 'mkdirp' failed"
    exit 1
fi

# Use the mkdirp module to create a directory and it's subdirectory
node -e "var mkdirp = require('mkdirp'); mkdirp('dir1/dir2')"
if [ $? -ne 0 ]; then
    echo "ERROR: Nodejs cannot use the freshly installed 'mkdirp' module."
    exit 1
fi

if [ "$(ls dir1)" != "dir2" ]; then
    echo "ERROR: The 'mkdirp' module could not create subdirectories at the current path."
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
