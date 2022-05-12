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
                                     8080 http 200 "-p SOURCE_REPOSITORY_REF=master -p PYTHON_VERSION=${VERSION} -p POSTGRESQL_VERSION=10 -p NAME=python-testing" \
                                     "quay.io/centos7/postgresql-10-centos7|postgresql:10"
}
function test_python_s2i_app_ex_standalone() {
  ct_os_test_s2i_app "${IMAGE_NAME}" \
        "https://github.com/sclorg/s2i-python-container.git" \
        "examples/standalone-test-app" \
        "Hello World from standalone WSGI application!"
}
function test_python_s2i_app_ex() {
  if [[ ${VERSION} == "2.7" ]] || docker inspect ${IMAGE_NAME} --format "{{.Config.Env}}" | tr " " "\n" | grep -q "^PLATFORM=el7"; then
    django_example_repo_url="https://github.com/sclorg/django-ex.git"
  else
    django_example_repo_url="https://github.com/sclorg/django-ex.git#2.2.x"
  fi
  ct_os_test_s2i_app "${IMAGE_NAME}" \
        "${django_example_repo_url}" \
        . \
        'Welcome to your Django application on OpenShift'
}


function test_python_s2i_templates() {
  if [ -z "${EPHEMERAL_TEMPLATES:-}" ]; then
      EPHEMERAL_TEMPLATES="
https://raw.githubusercontent.com/sclorg/django-ex/master/openshift/templates/django-postgresql.json \
https://raw.githubusercontent.com/openshift/origin/master/examples/quickstarts/django-postgresql.json"
  fi
  for template in $EPHEMERAL_TEMPLATES; do
      if [[ ${VERSION} == "2.7" ]] || docker inspect ${IMAGE_NAME} --format "{{.Config.Env}}" | tr " " "\n" | grep -q "^PLATFORM=el7"; then
        branch="master"
      else
        branch="2.2.x"
      fi
      ct_os_test_template_app "$IMAGE_NAME" \
                              "$template" \
                              python \
                              'Welcome to your Django application on OpenShift' \
                              8080 http 200 "-p SOURCE_REPOSITORY_REF=$branch -p PYTHON_VERSION=${VERSION} -p POSTGRESQL_VERSION=10 -p NAME=python-testing" \
                              "quay.io/centos7/postgresql-10-centos7|postgresql:10"
  done
}

# vim: set tabstop=2:shiftwidth=2:expandtab:

