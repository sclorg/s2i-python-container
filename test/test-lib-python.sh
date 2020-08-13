#!/bin/bash
#
# Functions for tests for the Python image in OpenShift.
#
# IMAGE_NAME specifies a name of the candidate image used for testing.
# The image has to be available before this script is executed.
#

THISDIR=$(dirname ${BASH_SOURCE[0]})

source "${THISDIR}/test-lib.sh"
source "${THISDIR}/test-lib-openshift.sh"

# Check the imagestream
function test_python_imagestream() {
  case ${OS} in
    rhel7|centos7) ;;
    *) echo "Imagestream testing not supported for $OS environment." ; return 0 ;;
  esac

  ct_os_test_image_stream_quickstart "${THISDIR}/imagestreams/python-${OS%[0-9]*}.json" \
                                     'https://raw.githubusercontent.com/sclorg/django-ex/master/openshift/templates/django-postgresql.json' \
                                     "${IMAGE_NAME}" \
                                     'python' \
                                     'Welcome to your Django application on OpenShift' \
                                     8080 http 200 "-p SOURCE_REPOSITORY_REF=master -p PYTHON_VERSION=${VERSION} -p POSTGRESQL_VERSION=9.6 -p NAME=python-testing" \
                                     "centos/postgresql-96-centos7|postgresql:9.6"
}

# vim: set tabstop=2:shiftwidth=2:expandtab:

