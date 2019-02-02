#!/bin/bash
#
# Functions for tests for the Python image in OpenShift.
#
# IMAGE_NAME specifies a name of the candidate image used for testing.
# The image has to be available before this script is executed.
#

THISDIR=$(dirname ${BASH_SOURCE[0]})

source ${THISDIR}/test-lib.sh
source ${THISDIR}/test-lib-openshift.sh

function test_python_integration() {
  local image_name=$1
  local version=$2
  local import_image=$3
  VERSION=$version ct_os_test_s2i_app "${image_name}" \
                                      "https://github.com/sclorg/django-ex.git" \
                                      . \
                                      "Welcome to your Django application on OpenShift" \
                                      8080 http 200 \
                                      "-p SOURCE_REPOSITORY_REF=master -p PYTHON_VERSION=${VERSION} -p POSTGRESQL_VERSION=9.6" \
                                      "${import_image}"
}

# vim: set tabstop=2:shiftwidth=2:expandtab:
