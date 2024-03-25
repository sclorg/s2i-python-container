#!/bin/bash

echo "Testing pello package installed version..."

if pip freeze | grep Pello==1.0.3; then
	echo "Pello 1.0.3 is installed, starting webserver..."
	exec python app.py
else
	echo "Pello 1.0.3 wasn't installed, exiting..."
	exit 1
fi
