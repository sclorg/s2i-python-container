#
# Test a container image.
#
# Always use sourced from a specific container testfile 
#
# reguires definition of CID_FILE_DIR
# CID_FILE_DIR=$(mktemp --suffix=<container>_test_cidfiles -d)
# reguires definition of TEST_LIST 
# TEST_LIST="\
# ctest_container_creation
# ctest_doc_content"

# Container CI tests
# abbreviated as "ct"

# may be redefined in the specific container testfile
EXPECTED_EXIT_CODE=0

# ct_cleanup
# --------------------
# Cleans up containers used during tests. Stops and removes all containers
# referenced by cid_files in CID_FILE_DIR. Dumps logs if a container exited
# unexpectedly. Removes the cid_files and CID_FILE_DIR as well.
# Uses: $CID_FILE_DIR - path to directory containing cid_files
# Uses: $EXPECTED_EXIT_CODE - expected container exit code
function ct_cleanup() {
  for cid_file in $CID_FILE_DIR/* ; do
    local container=$(cat $cid_file)

    : "Stopping and removing container $container..."
    docker stop $container
    exit_status=$(docker inspect -f '{{.State.ExitCode}}' $container)
    if [ "$exit_status" != "$EXPECTED_EXIT_CODE" ]; then
      : "Dumping logs for $container"
      docker logs $container
    fi
    docker rm -v $container
    rm $cid_file
  done
  rmdir $CID_FILE_DIR
  : "Done."
}

# ct_enable_cleanup
# --------------------
# Enables automatic container cleanup after tests.
function ct_enable_cleanup() {
  trap ct_cleanup EXIT SIGINT
}

# ct_get_cid [name]
# --------------------
# Prints container id from cid_file based on the name of the file.
# Argument: name - name of cid_file where the container id will be stored
# Uses: $CID_FILE_DIR - path to directory containing cid_files
function ct_get_cid() {
  local name="$1" ; shift || return 1
  echo $(cat "$CID_FILE_DIR/$name")
}

# ct_get_cip [id]
# --------------------
# Prints container ip address based on the container id.
# Argument: id - container id
function ct_get_cip() {
  local id="$1" ; shift
  docker inspect --format='{{.NetworkSettings.IPAddress}}' $(ct_get_cid "$id")
}

# ct_wait_for_cid [cid_file]
# --------------------
# Holds the execution until the cid_file is created. Usually run after container
# creation.
# Argument: cid_file - name of the cid_file that should be created
function ct_wait_for_cid() {
  local cid_file=$1
  local max_attempts=10
  local sleep_time=1
  local attempt=1
  local result=1
  while [ $attempt -le $max_attempts ]; do
    [ -f $cid_file ] && [ -s $cid_file ] && return 0
    : "Waiting for container start..."
    attempt=$(( $attempt + 1 ))
    sleep $sleep_time
  done
  return 1
}

# ct_assert_container_creation_fails [container_args]
# --------------------
# The invocation of docker run should fail based on invalid container_args
# passed to the function. Returns 0 when container fails to start properly.
# Argument: container_args - all arguments are passed directly to dokcer run
# Uses: $CID_FILE_DIR - path to directory containing cid_files
function ct_assert_container_creation_fails() {
  local ret=0
  local max_attempts=10
  local attempt=1
  local cid_file=assert
  set +e
  local old_container_args="${CONTAINER_ARGS-}"
  CONTAINER_ARGS="$@"
  ct_create_container $cid_file
  if [ $? -eq 0 ]; then
    local cid=$(ct_get_cid $cid_file)

    while [ "$(docker inspect -f '{{.State.Running}}' $cid)" == "true" ] ; do
      sleep 2
      attempt=$(( $attempt + 1 ))
      if [ $attempt -gt $max_attempts ]; then
        docker stop $cid
        ret=1
        break
      fi
    done
    exit_status=$(docker inspect -f '{{.State.ExitCode}}' $cid)
    if [ "$exit_status" == "0" ]; then
      ret=1
    fi
    docker rm -v $cid
    rm $CID_FILE_DIR/$cid_file
  fi
  [ ! -z $old_container_args ] && CONTAINER_ARGS="$old_container_args"
  set -e
  return $ret
}

# ct_create_container [name, command]
# --------------------
# Creates a container using the IMAGE_NAME and CONTAINER_ARGS variables. Also
# stores the container id to a cid_file located in the CID_FILE_DIR, and waits
# for the creation of the file.
# Argument: name - name of cid_file where the container id will be stored
# Argument: command - optional command to be executed in the container
# Uses: $CID_FILE_DIR - path to directory containing cid_files
# Uses: $CONTAINER_ARGS - optional arguments passed directly to docker run
# Uses: $IMAGE_NAME - name of the image being tested
function ct_create_container() {
  local cid_file="$CID_FILE_DIR/$1" ; shift
  # create container with a cidfile in a directory for cleanup
  docker run --cidfile="$cid_file" -d ${CONTAINER_ARGS:-} $IMAGE_NAME "$@"
  ct_wait_for_cid $cid_file || return 1
  : "Created container $(cat $cid_file)"
}

# ct_scl_usage_old [name, command, expected]
# --------------------
# Tests three ways of running the SCL, by looking for an expected string
# in the output of the command
# Argument: name - name of cid_file where the container id will be stored
# Argument: command - executed inside the container
# Argument: expected - string that is expected to be in the command output
# Uses: $CID_FILE_DIR - path to directory containing cid_files
# Uses: $IMAGE_NAME - name of the image being tested
function ct_scl_usage_old() {
  local name="$1"
  local command="$2"
  local expected="$3"
  local out=""
  : "  Testing the image SCL enable"
  out=$(docker run --rm ${IMAGE_NAME} /bin/bash -c "${command}")
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[/bin/bash -c "${command}"] Expected '${expected}', got '${out}'" >&2
    return 1
  fi
  out=$(docker exec $(ct_get_cid $name) /bin/bash -c "${command}" 2>&1)
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[exec /bin/bash -c "${command}"] Expected '${expected}', got '${out}'" >&2
    return 1
  fi
  out=$(docker exec $(ct_get_cid $name) /bin/sh -ic "${command}" 2>&1)
  if ! echo "${out}" | grep -q "${expected}"; then
    echo "ERROR[exec /bin/sh -ic "${command}"] Expected '${expected}', got '${out}'" >&2
    return 1
  fi
}

# ct_doc_content_old [strings]
# --------------------
# Looks for occurence of stirngs in the documentation files and checks
# the format of the files. Files examined: help.1
# Argument: strings - strings expected to appear in the documentation
# Uses: $IMAGE_NAME - name of the image being tested
function ct_doc_content_old() {
  local tmpdir=$(mktemp -d)
  local f
  : "  Testing documentation in the container image"
  # Extract the help files from the container
  for f in help.1 ; do
    docker run --rm ${IMAGE_NAME} /bin/bash -c "cat /${f}" >${tmpdir}/$(basename ${f})
    # Check whether the files contain some important information
    for term in $@ ; do
      if ! cat ${tmpdir}/$(basename ${f}) | grep -F -q -e "${term}" ; then
        echo "ERROR: File /${f} does not include '${term}'." >&2
        return 1
      fi
    done
    # Check whether the files use the correct format
    for term in TH PP SH ; do
      if ! grep -q "^\.${term}" ${tmpdir}/help.1 ; then
        echo "ERROR: /help.1 is probably not in troff or groff format, since '${term}' is missing." >&2
        return 1
      fi
    done
  done
  : "  Success!"
}


# ct_npm_works
# --------------------
# Checks existance of the npm tool and runs it.
function ct_npm_works() {
  local tmpdir=$(mktemp -d)
  : "  Testing npm in the container image"
  docker run --rm ${IMAGE_NAME} /bin/bash -c "npm --version" >${tmpdir}/version

  if [ $? -ne 0 ] ; then
    echo "ERROR: 'npm --version' does not work inside the image ${IMAGE_NAME}." >&2
    return 1
  fi

  docker run --rm ${IMAGE_NAME} /bin/bash -c "npm install jquery && test -f node_modules/jquery/src/jquery.js"
  if [ $? -ne 0 ] ; then
    echo "ERROR: npm could not install jquery inside the image ${IMAGE_NAME}." >&2
    return 1
  fi

  : "  Success!"
}


# ct_path_append PATH_VARNAME DIRECTORY
# -------------------------------------
# Append DIRECTORY to VARIABLE of name PATH_VARNAME, the VARIABLE must consist
# of colon-separated list of directories.
ct_path_append ()
{
    if eval "test -n \"\${$1-}\""; then
        eval "$1=\$2:\$$1"
    else
        eval "$1=\$2"
    fi
}


# ct_path_foreach PATH ACTION [ARGS ...]
# --------------------------------------
# For each DIR in PATH execute ACTION (path is colon separated list of
# directories).  The particular calls to ACTION will look like
# '$ ACTION directory [ARGS ...]'
ct_path_foreach ()
{
    local dir dirlist action save_IFS
    save_IFS=$IFS
    IFS=:
    dirlist=$1
    action=$2
    shift 2
    for dir in $dirlist; do "$action" "$dir" "$@" ; done
    IFS=$save_IFS
}


# ct_run_test_list
# --------------------
# Execute the tests specified by TEST_LIST
# Uses: $TEST_LIST - list of test names
function ct_run_test_list() {
  for test_case in $TEST_LIST; do
    : "Running test $test_case"
    [ -f test/$test_case ] && source test/$test_case
    [ -f ../test/$test_case ] && source ../test/$test_case
    $test_case
  done;
}

# ct_gen_self_signed_cert_pem
# ---------------------------
# Generates a self-signed PEM certificate pair into specified directory.
# Argument: output_dir - output directory path
# Argument: base_name - base name of the certificate files
# Resulted files will be those:
#   <output_dir>/<base_name>-cert-selfsigned.pem -- public PEM cert
#   <output_dir>/<base_name>-key.pem -- PEM private key
ct_gen_self_signed_cert_pem() {
  local output_dir=$1 ; shift
  local base_name=$1 ; shift
  mkdir -p ${output_dir}
  openssl req -newkey rsa:2048 -nodes -keyout ${output_dir}/${base_name}-key.pem -subj '/C=GB/ST=Berkshire/L=Newbury/O=My Server Company' > ${base_name}-req.pem
  openssl req -new -x509 -nodes -key ${output_dir}/${base_name}-key.pem -batch > ${output_dir}/${base_name}-cert-selfsigned.pem
}

# ct_obtain_input FILE|DIR|URL
# --------------------
# Either copies a file or a directory to a tmp location for local copies, or
# downloads the file from remote location.
# Resulted file path is printed, so it can be later used by calling function.
# Arguments: input - local file, directory or remote URL
function ct_obtain_input() {
  local input=$1
  local extension="${input##*.}"

  # Try to use same extension for the temporary file if possible
  [[ "${extension}" =~ ^[a-z0-9]*$ ]] && extension=".${extension}" || extension=""

  local output=$(mktemp "/var/tmp/test-input-XXXXXX$extension")
  if [ -f "${input}" ] ; then
    cp "${input}" "${output}"
  elif [ -d "${input}" ] ; then
    rm -f "${output}"
    cp -r -LH "${input}" "${output}"
  elif echo "${input}" | grep -qe '^http\(s\)\?://' ; then
    curl "${input}" > "${output}"
  else
    echo "ERROR: file type not known: ${input}" >&2
    return 1
  fi
  echo "${output}"
}

# ct_test_response
# ----------------
# Perform GET request to the application container, checks output with
# a reg-exp and HTTP response code.
# Argument: url - request URL path
# Argument: expected_code - expected HTTP response code
# Argument: body_regexp - PCRE regular expression that must match the response body
# Argument: max_attempts - Optional number of attempts (default: 20), three seconds sleep between
# Argument: ignore_error_attempts - Optional number of attempts when we ignore error output (default: 10)
ct_test_response() {
  local url="$1"
  local expected_code="$2"
  local body_regexp="$3"
  local max_attempts=${4:-20}
  local ignore_error_attempts=${5:-10}

  : "  Testing the HTTP(S) response for <${url}>"
  local sleep_time=3
  local attempt=1
  local result=1
  local status
  local response_code
  local response_file=$(mktemp /tmp/ct_test_response_XXXXXX)
  while [ ${attempt} -le ${max_attempts} ]; do
    curl --connect-timeout 10 -s -w '%{http_code}' "${url}" >${response_file} && status=0 || status=1
    if [ ${status} -eq 0 ]; then
      response_code=$(cat ${response_file} | tail -c 3)
      if [ "${response_code}" -eq "${expected_code}" ]; then
        result=0
      fi
      cat ${response_file} | grep -qP -e "${body_regexp}" || result=1;
      # Some services return 40x code until they are ready, so let's give them
      # some chance and not end with failure right away
      # Do not wait if we already have expected outcome though
      if [ ${result} -eq 0 -o ${attempt} -gt ${ignore_error_attempts} -o ${attempt} -eq ${max_attempts} ] ; then
        break
      fi
    fi
    attempt=$(( ${attempt} + 1 ))
    sleep ${sleep_time}
  done
  rm -f ${response_file}
  return ${result}
}

# ct_registry_from_os OS
# ----------------
# Transform operating system string [os] into registry url
# Argument: OS - string containing the os version
ct_registry_from_os() {
  local registry=""
  case $1 in
    rhel7)
        registry=registry.access.redhat.com
        ;;
    *)
        registry=docker.io
        ;;
    esac
  echo "$registry"
}

# ct_assert_cmd_success CMD
# ----------------
# Evaluates [cmd] and fails if it does not succeed.
# Argument: CMD - Command to be run
function ct_assert_cmd_success() {
  echo "Checking '$*' for success ..."
  if ! eval "$@" &>/dev/null; then
    echo " FAIL"
    return 1
  fi
  echo " PASS"
  return 0
}

# ct_assert_cmd_failure CMD
# ----------------
# Evaluates [cmd] and fails if it succeeds.
# Argument: CMD - Command to be run
function ct_assert_cmd_failure() {
  echo "Checking '$*' for failure ..."
  if eval "$@" &>/dev/null; then
    echo " FAIL"
    return 1
  fi
  echo " PASS"
  return 0
}


# ct_random_string [LENGTH=10]
# ----------------------------
# Generate pseudorandom alphanumeric string of LENGTH bytes, the
# default length is 10.  The string is printed on stdout.
ct_random_string()
(
   export LC_ALL=C
   dd if=/dev/urandom count=1 bs=10k 2>/dev/null \
       | tr -dc 'a-z0-9' \
       | fold -w "${1-10}" \
       | head -n 1
)
