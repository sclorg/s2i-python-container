#!/bin/bash -e
# This script is used to build, test and squash the OpenShift Docker images.
#
# $1 - Specifies distribution - "rhel7" or "centos7"
# $2 - Specifies the image version - (must match with subdirectory in repo)
# TEST_MODE - If set, build a candidate image and test it
# VERSIONS - Must be set to a list with possible versions (subdirectories)

OS=$1
VERSION=$2

DOCKERFILE_PATH=""
BASE_DIR_NAME=$(echo $(basename `pwd`) | sed -e 's/-[0-9]*$//g')
BASE_IMAGE_NAME="openshift/${BASE_DIR_NAME#sti-}"

# Cleanup the temporary Dockerfile created by docker build with version
trap 'remove_tmp_dockerfile' SIGINT SIGQUIT EXIT
function remove_tmp_dockerfile {
  if [[ ! -z "${DOCKERFILE_PATH}.version" ]]; then
    rm -f "${DOCKERFILE_PATH}.version"
  fi
}

# Perform docker build but append the LABEL with GIT commit id at the end
function docker_build_with_version {
  local dockerfile="$1"
  # Use perl here to make this compatible with OSX
  DOCKERFILE_PATH=$(perl -MCwd -e 'print Cwd::abs_path shift' $dockerfile)
  cp ${DOCKERFILE_PATH} "${DOCKERFILE_PATH}.version"
  git_version=$(git rev-parse --short HEAD)
  echo "LABEL io.openshift.builder-version=\"${git_version}\"" >> "${dockerfile}.version"
  docker build -t ${IMAGE_NAME} -f "${dockerfile}.version" .
  if [[ "${SKIP_SQUASH}" != "1" ]]; then
    squash "${dockerfile}.version"
  fi
}

# Install the docker squashing tool[1] and squash the result image
# [1] https://github.com/goldmann/docker-scripts
function squash {
  # FIXME: We have to use the exact versions here to avoid Docker client
  #        compatibility issues
  easy_install -q --user docker_py==1.2.3 docker-scripts==0.4.2
  base=$(awk '/^FROM/{print $2}' $1)
  ${HOME}/.local/bin/docker-scripts squash -f $base ${IMAGE_NAME}
}

# Versions are stored in subdirectories. You can specify VERSION variable
# to build just one single version. By default we build all versions
dirs=${VERSION:-$VERSIONS}

for dir in ${dirs}; do
  IMAGE_NAME="${BASE_IMAGE_NAME}-${dir//./}-${OS}"

  if [[ -v TEST_MODE ]]; then
    IMAGE_NAME+="-candidate"
  fi

  echo "-> Building ${IMAGE_NAME} ..."

  pushd ${dir} > /dev/null
  if [ "$OS" == "rhel7" -o "$OS" == "rhel7-candidate" ]; then
    docker_build_with_version Dockerfile.rhel7
  else
    docker_build_with_version Dockerfile
  fi

  if [[ -v TEST_MODE ]]; then
    IMAGE_NAME=${IMAGE_NAME} test/run
  fi

  popd > /dev/null
done
