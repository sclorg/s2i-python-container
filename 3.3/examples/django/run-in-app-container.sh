#!/bin/bash

# Use this script to run one-off commands inside a container of a frontend pod
# (where you application code lives in)
#
# Examples:
# ./run-in-app-container.sh date
# ./run-in-app-container.sh env
# ./run-in-app-container.sh ./manage.py migrate

quoted_args="$(printf " %q" "$@")"
osc exec -p $(osc get pods -l name=frontend -t '{{ with index .items 0 }}{{ .metadata.name }}{{ end }}') -it -- bash -c "cd \$HOME && scl enable python33 \"$quoted_args\""
