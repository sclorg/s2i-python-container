# Set of functions for testing docker images in OpenShift using 'oc' command

# ct_os_get_status
# --------------------
# Returns status of all objects to make debugging easier.
function ct_os_get_status() {
  oc get all
  oc status
}

# ct_os_print_logs
# --------------------
# Returns status of all objects and logs from all pods.
function ct_os_print_logs() {
  ct_os_get_status
  while read pod_name; do
    echo "INFO: printing logs for pod ${pod_name}"
    oc logs ${pod_name}
  done < <(oc get pods --no-headers=true -o custom-columns=NAME:.metadata.name)
}

# ct_os_enable_print_logs
# --------------------
# Enables automatic printing of pod logs on ERR.
function ct_os_enable_print_logs() {
  set -E
  trap ct_os_print_logs ERR
}

# ct_get_public_ip
# --------------------
# Returns best guess for the IP that the node is accessible from other computers.
# This is a bit funny heuristic, simply goes through all IPv4 addresses that
# hostname -I returns and de-prioritizes IP addresses commonly used for local
# addressing. The rest of addresses are taken as public with higher probability.
function ct_get_public_ip() {
  local hostnames=$(hostname -I)
  local public_ip=''
  local found_ip
  for guess_exp in '127\.0\.0\.1' '192\.168\.[0-9\.]*' '172\.[0-9\.]*' \
                   '10\.[0-9\.]*' '[0-9\.]*' ; do
    found_ip=$(echo "${hostnames}" | grep -oe "${guess_exp}")
    if [ -n "${found_ip}" ] ; then
      hostnames=$(echo "${hostnames}" | sed -e "s/${found_ip}//")
      public_ip="${found_ip}"
    fi
  done
  if [ -z "${public_ip}" ] ; then
    echo "ERROR: public IP could not be guessed." >&2
    return 1
  fi
  echo "${public_ip}"
}

# ct_os_run_in_pod POD_NAME CMD
# --------------------
# Runs [cmd] in the pod specified by prefix [pod_prefix].
# Arguments: pod_name - full name of the pod
# Arguments: cmd - command to be run in the pod
function ct_os_run_in_pod() {
  local pod_name="$1" ; shift

  oc exec "$pod_name" -- "$@"
}

# ct_os_get_service_ip SERVICE_NAME
# --------------------
# Returns IP of the service specified by [service_name].
# Arguments: service_name - name of the service
function ct_os_get_service_ip() {
  local service_name="${1}" ; shift
  oc get "svc/${service_name}" -o yaml | grep clusterIP | \
     cut -d':' -f2 | grep -oe '172\.30\.[0-9\.]*'
}


# ct_os_get_all_pods_status
# --------------------
# Returns status of all pods.
function ct_os_get_all_pods_status() {
  oc get pods -o custom-columns=Ready:status.containerStatuses[0].ready,NAME:.metadata.name
}

# ct_os_get_all_pods_name
# --------------------
# Returns the full name of all pods.
function ct_os_get_all_pods_name() {
  oc get pods --no-headers -o custom-columns=NAME:.metadata.name
}

# ct_os_get_pod_status POD_PREFIX
# --------------------
# Returns status of the pod specified by prefix [pod_prefix].
# Note: Ignores -build and -deploy pods
# Arguments: pod_prefix - prefix or whole ID of the pod
function ct_os_get_pod_status() {
  local pod_prefix="${1}" ; shift
  ct_os_get_all_pods_status | grep -e "${pod_prefix}" | grep -Ev "(build|deploy)$" \
                            | awk '{print $1}' | head -n 1
}

# ct_os_get_pod_name POD_PREFIX
# --------------------
# Returns the full name of pods specified by prefix [pod_prefix].
# Note: Ignores -build and -deploy pods
# Arguments: pod_prefix - prefix or whole ID of the pod
function ct_os_get_pod_name() {
  local pod_prefix="${1}" ; shift
  ct_os_get_all_pods_name | grep -e "^${pod_prefix}" | grep -Ev "(build|deploy)$"
}

# ct_os_get_pod_ip POD_NAME
# --------------------
# Returns the ip of the pod specified by [pod_name].
# Arguments: pod_name - full name of the pod
function ct_os_get_pod_ip() {
  local pod_name="${1}"
  oc get pod "$pod_name" --no-headers -o custom-columns=IP:status.podIP
}

# ct_os_check_pod_readiness POD_PREFIX STATUS
# --------------------
# Checks whether the pod is ready.
# Arguments: pod_prefix - prefix or whole ID of the pod
# Arguments: status - expected status (true, false)
function ct_os_check_pod_readiness() {
  local pod_prefix="${1}" ; shift
  local status="${1}" ; shift
  test "$(ct_os_get_pod_status ${pod_prefix})" == "${status}"
}

# ct_os_wait_pod_ready POD_PREFIX TIMEOUT
# --------------------
# Wait maximum [timeout] for the pod becomming ready.
# Arguments: pod_prefix - prefix or whole ID of the pod
# Arguments: timeout - how many seconds to wait seconds
function ct_os_wait_pod_ready() {
  local pod_prefix="${1}" ; shift
  local timeout="${1}" ; shift
  SECONDS=0
  echo -n "Waiting for ${pod_prefix} pod becoming ready ..."
  while ! ct_os_check_pod_readiness "${pod_prefix}" "true" ; do
    echo -n "."
    [ ${SECONDS} -gt ${timeout} ] && echo " FAIL" && return 1
    sleep 3
  done
  echo " DONE"
}

# ct_os_wait_rc_ready POD_PREFIX TIMEOUT
# --------------------
# Wait maximum [timeout] for the rc having desired number of replicas ready.
# Arguments: pod_prefix - prefix of the replication controller
# Arguments: timeout - how many seconds to wait seconds
function ct_os_wait_rc_ready() {
  local pod_prefix="${1}" ; shift
  local timeout="${1}" ; shift
  SECONDS=0
  echo -n "Waiting for ${pod_prefix} pod becoming ready ..."
  while ! test "$((oc get --no-headers statefulsets; oc get --no-headers rc) 2>/dev/null \
                 | grep "^${pod_prefix}" | awk '$2==$3 {print "ready"}')" == "ready" ; do
    echo -n "."
    [ ${SECONDS} -gt ${timeout} ] && echo " FAIL" && return 1
    sleep 3
  done
  echo " DONE"
}

# ct_os_deploy_pure_image IMAGE [ENV_PARAMS, ...]
# --------------------
# Runs [image] in the openshift and optionally specifies env_params
# as environment variables to the image.
# Arguments: image - prefix or whole ID of the pod to run the cmd in
# Arguments: env_params - environment variables parameters for the images.
function ct_os_deploy_pure_image() {
  local image="${1}" ; shift
  # ignore error exit code, because oc new-app returns error when image exists
  oc new-app ${image} "$@" || :
  # let openshift cluster to sync to avoid some race condition errors
  sleep 3
}

# ct_os_deploy_s2i_image IMAGE APP [ENV_PARAMS, ... ]
# --------------------
# Runs [image] and [app] in the openshift and optionally specifies env_params
# as environment variables to the image.
# Arguments: image - prefix or whole ID of the pod to run the cmd in
# Arguments: app - url or local path to git repo with the application sources.
# Arguments: env_params - environment variables parameters for the images.
function ct_os_deploy_s2i_image() {
  local image="${1}" ; shift
  local app="${1}" ; shift
  # ignore error exit code, because oc new-app returns error when image exists
  oc new-app "${image}~${app}" "$@" || :

  # let openshift cluster to sync to avoid some race condition errors
  sleep 3
}

# ct_os_deploy_template_image TEMPLATE [ENV_PARAMS, ...]
# --------------------
# Runs template in the openshift and optionally gives env_params to use
# specific values in the template.
# Arguments: template - prefix or whole ID of the pod to run the cmd in
# Arguments: env_params - environment variables parameters for the template.
# Example usage: ct_os_deploy_template_image mariadb-ephemeral-template.yaml \
#                                            DATABASE_SERVICE_NAME=mysql-57-centos7 \
#                                            DATABASE_IMAGE=mysql-57-centos7 \
#                                            MYSQL_USER=testu \
#                                            MYSQL_PASSWORD=testp \
#                                            MYSQL_DATABASE=testdb
function ct_os_deploy_template_image() {
  local template="${1}" ; shift
  oc process -f "${template}" "$@" | oc create -f -
  # let openshift cluster to sync to avoid some race condition errors
  sleep 3
}

# _ct_os_get_uniq_project_name
# --------------------
# Returns a uniq name of the OpenShift project.
function _ct_os_get_uniq_project_name() {
  local r
  while true ; do
    r=${RANDOM}
    mkdir /var/tmp/os-test-${r} &>/dev/null && echo test-${r} && break
  done
}

# ct_os_new_project [PROJECT]
# --------------------
# Creates a new project in the openshfit using 'os' command.
# Arguments: project - project name, uses a new random name if omitted
# Expects 'os' command that is properly logged in to the OpenShift cluster.
# Not using mktemp, because we cannot use uppercase characters.
function ct_os_new_project() {
  local project_name="${1:-$(_ct_os_get_uniq_project_name)}" ; shift || :
  oc new-project ${project_name}
  # let openshift cluster to sync to avoid some race condition errors
  sleep 3
}

# ct_os_delete_project [PROJECT]
# --------------------
# Deletes the specified project in the openshfit
# Arguments: project - project name, uses the current project if omitted
function ct_os_delete_project() {
  local project_name="${1:-$(oc project -q)}" ; shift || :
  oc delete project "${project_name}"
}

# ct_os_docker_login
# --------------------
# Logs in into docker daemon
function ct_os_docker_login() {
  # docker login fails with "404 page not found" error sometimes, just try it more times
  for i in `seq 12` ; do
    docker login -u developer -p $(oc whoami -t) 172.30.1.1:5000 && return 0 || :
    sleep 5
  done
  return 1
}

# ct_os_upload_image IMAGE [IMAGESTREAM]
# --------------------
# Uploads image from local registry to the OpenShift internal registry.
# Arguments: image - image name to upload
# Arguments: imagestream - name and tag to use for the internal registry.
#                          In the format of name:tag ($image_name:latest by default)
function ct_os_upload_image() {
  local input_name="${1}" ; shift
  local image_name=${input_name##*/}
  local imagestream=${1:-$image_name:latest}
  local output_name="172.30.1.1:5000/$(oc project -q)/$imagestream"

  ct_os_docker_login
  docker tag ${input_name} ${output_name}
  docker push ${output_name}
}

# ct_os_install_in_centos
# --------------------
# Installs os cluster in CentOS
function ct_os_install_in_centos() {
  yum install -y centos-release-openshift-origin
  yum install -y wget git net-tools bind-utils iptables-services bridge-utils\
                 bash-completion origin-clients docker origin-clients
}

# ct_os_cluster_up [DIR, IS_PUBLIC, CLUSTER_VERSION]
# --------------------
# Runs the local OpenShift cluster using 'oc cluster up' and logs in as developer.
# Arguments: dir - directory to keep configuration data in, random if omitted
# Arguments: is_public - sets either private or public hostname for web-UI,
#                        use "true" for allow remote access to the web-UI,
#                        "false" is default
# Arguments: cluster_version - version of the OpenShift cluster to use, empty
#                              means default version of `oc`; example value: 3.7;
#                              also can be specified outside by OC_CLUSTER_VERSION
function ct_os_cluster_up() {
  ct_os_cluster_running && echo "Cluster already running. Nothing is done." && return 0
  mkdir -p /var/tmp/openshift
  local dir="${1:-$(mktemp -d /var/tmp/openshift/os-data-XXXXXX)}" ; shift || :
  local is_public="${1:-'false'}" ; shift || :
  local default_cluster_version=${OC_CLUSTER_VERSION:-}
  local cluster_version=${1:-${default_cluster_version}} ; shift || :
  if ! grep -qe '--insecure-registry.*172\.30\.0\.0' /etc/sysconfig/docker ; then
    sed -i "s|OPTIONS='|OPTIONS='--insecure-registry 172.30.0.0/16 |" /etc/sysconfig/docker
  fi

  systemctl stop firewalld
  setenforce 0
  iptables -F

  systemctl restart docker
  local cluster_ip="127.0.0.1"
  [ "${is_public}" == "true" ] && cluster_ip=$(ct_get_public_ip)

  if [ -n "${cluster_version}" ] ; then
    # if $cluster_version is not set, we simply use oc that is available
    ct_os_set_path_oc "${cluster_version}"
  fi

  mkdir -p ${dir}/{config,data,pv}
  oc cluster up --host-data-dir=${dir}/data --host-config-dir=${dir}/config \
                --host-pv-dir=${dir}/pv --use-existing-config --public-hostname=${cluster_ip}
  oc version
  oc login -u system:admin
  oc project default
  ct_os_wait_rc_ready docker-registry 180
  ct_os_wait_rc_ready router 30
  oc login -u developer -p developer
  # let openshift cluster to sync to avoid some race condition errors
  sleep 3
}

# ct_os_cluster_down
# --------------------
# Shuts down the local OpenShift cluster using 'oc cluster down'
function ct_os_cluster_down() {
  oc cluster down
}

# ct_os_cluster_running
# --------------------
# Returns 0 if oc cluster is running
function ct_os_cluster_running() {
  oc cluster status &>/dev/null
}

# ct_os_set_path_oc OC_VERSION
# --------------------
# This is a trick that helps using correct version of the `oc`:
# The input is version of the openshift in format v3.6.0 etc.
# If the currently available version of oc is not of this version,
# it first takes a look into /usr/local/oc-<ver>/bin directory,
# and if not found there it downloads the community release from github.
# In the end the PATH variable is changed, so the other tests can still use just 'oc'.
# Arguments: oc_version - X.Y part of the version of OSE (e.g. 3.9)
function ct_os_set_path_oc() {
  local oc_version=$(ct_os_get_latest_ver $1)
  local oc_path

  if oc version | grep -q "oc ${oc_version%.*}." ; then
    echo "Binary oc found already available in version ${oc_version}: `which oc` Doing noting."
    return 0
  fi

  # first check whether we already have oc available in /usr/local
  local installed_oc_path="/usr/local/oc-${oc_version%.*}/bin"

  if [ -x "${installed_oc_path}/oc" ] ; then
    oc_path="${installed_oc_path}"
    echo "Binary oc found in ${installed_oc_path}" >&2
  else
    # oc not available in /usr/local, try to download it from github (community release)
    oc_path="/tmp/oc-${oc_version}-bin"
    ct_os_download_upstream_oc "${oc_version}" "${oc_path}"
  fi
  if [ -z "${oc_path}/oc" ] ; then
    echo "ERROR: oc not found installed, nor downloaded" >&1
    return 1
  fi
  export PATH="${oc_path}:${PATH}"
  if ! oc version | grep -q "oc ${oc_version%.*}." ; then
    echo "ERROR: something went wrong, oc located at ${oc_path}, but oc of version ${oc_version} not found in PATH ($PATH)" >&1
    return 1
  else
    echo "PATH set correctly, binary oc found in version ${oc_version}: `which oc`"
  fi
}

# ct_os_get_latest_ver VERSION_PART_X
# --------------------
# Returns full version (vX.Y.Z) from part of the version (X.Y)
# Arguments: vxy - X.Y part of the version
# Returns vX.Y.Z variant of the version
function ct_os_get_latest_ver(){
  local vxy="v$1"
  for vz in {3..0} ; do
    curl -sif "https://github.com/openshift/origin/releases/tag/${vxy}.${vz}" >/dev/null && echo "${vxy}.${vz}" && return 0
  done
  echo "ERROR: version ${vxy} not found in https://github.com/openshift/origin/tags" >&2
  return 1
}

# ct_os_download_upstream_oc OC_VERSION OUTPUT_DIR
# --------------------
# Downloads a particular version of openshift-origin-client-tools from
# github into specified output directory
# Arguments: oc_version - version of OSE (e.g. v3.7.2)
# Arguments: output_dir - output directory
function ct_os_download_upstream_oc() {
  local oc_version=$1
  local output_dir=$2

  # check whether we already have the binary in place
  [ -x "${output_dir}/oc" ] && return 0

  mkdir -p "${output_dir}"
  # using html output instead of https://api.github.com/repos/openshift/origin/releases/tags/${oc_version},
  # because API is limited for number of queries if not authenticated
  tarball=$(curl -si "https://github.com/openshift/origin/releases/tag/${oc_version}" | grep -o -e "openshift-origin-client-tools-${oc_version}-[a-f0-9]*-linux-64bit.tar.gz" | head -n 1)

  # download, unpack the binaries and then put them into output directory
  echo "Downloading https://github.com/openshift/origin/releases/download/${oc_version}/${tarball} into ${output_dir}/" >&2
  curl -sL https://github.com/openshift/origin/releases/download/${oc_version}/"${tarball}" | tar -C "${output_dir}" -xz
  mv -f "${output_dir}"/"${tarball%.tar.gz}"/* "${output_dir}/"

  rmdir "${output_dir}"/"${tarball%.tar.gz}"
}


# ct_os_test_s2i_app_func IMAGE APP CONTEXT_DIR CHECK_CMD [OC_ARGS]
# --------------------
# Runs [image] and [app] in the openshift and optionally specifies env_params
# as environment variables to the image. Then check the container by arbitrary
# function given as argument (such an argument may include <IP> string,
# that will be replaced with actual IP).
# Arguments: image - prefix or whole ID of the pod to run the cmd in  (compulsory)
# Arguments: app - url or local path to git repo with the application sources  (compulsory)
# Arguments: context_dir - sub-directory inside the repository with the application sources (compulsory)
# Arguments: check_command - CMD line that checks whether the container works (compulsory; '<IP>' will be replaced with actual IP)
# Arguments: oc_args - all other arguments are used as additional parameters for the `oc new-app`
#            command, typically environment variables (optional)
function ct_os_test_s2i_app_func() {
  local image_name=${1}
  local app=${2}
  local context_dir=${3}
  local check_command=${4}
  local oc_args=${5:-}
  local image_name_no_namespace=${image_name##*/}
  local service_name="${image_name_no_namespace}-testing"
  local image_tagged="${image_name_no_namespace}:testing"

  if [ $# -lt 4 ] || [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" ]; then
    echo "ERROR: ct_os_test_s2i_app_func() requires at least 4 arguments that cannot be emtpy." >&2
    return 1
  fi

  ct_os_new_project
  # Create a specific imagestream tag for the image so that oc cannot use anything else
  ct_os_upload_image "${image_name}" "${image_tagged}"

  local app_param="${app}"
  if [ -d "${app}" ] ; then
    # for local directory, we need to copy the content, otherwise too smart os command
    # pulls the git remote repository instead
    app_param=$(ct_obtain_input "${app}")
  fi

  ct_os_deploy_s2i_image "${image_tagged}" "${app_param}" \
                          --context-dir="${context_dir}" \
                          --name "${service_name}" \
                          ${oc_args}

  if [ -d "${app}" ] ; then
    # in order to avoid weird race seen sometimes, let's wait shortly
    # before starting the build explicitly
    sleep 5
    oc start-build "${service_name}" --from-dir="${app_param}"
  fi

  ct_os_wait_pod_ready "${service_name}" 300

  local ip=$(ct_os_get_service_ip "${service_name}")
  local check_command_exp=$(echo "$check_command" | sed -e "s/<IP>/$ip/g")

  echo "  Checking APP using $check_command_exp ..."
  local result=0
  eval "$check_command_exp" || result=1

  if [ $result -eq 0 ] ; then
    echo "  Check passed."
  else
    echo "  Check failed."
  fi

  ct_os_delete_project
  return $result
}

# ct_os_test_s2i_app IMAGE APP CONTEXT_DIR EXPECTED_OUTPUT [PORT, PROTOCOL, RESPONSE_CODE, OC_ARGS, ... ]
# --------------------
# Runs [image] and [app] in the openshift and optionally specifies env_params
# as environment variables to the image. Then check the http response.
# Arguments: image - prefix or whole ID of the pod to run the cmd in (compulsory)
# Arguments: app - url or local path to git repo with the application sources (compulsory)
# Arguments: context_dir - sub-directory inside the repository with the application sources (compulsory)
# Arguments: expected_output - PCRE regular expression that must match the response body (compulsory)
# Arguments: port - which port to use (optional; default: 8080)
# Arguments: protocol - which protocol to use (optional; default: http)
# Arguments: response_code - what http response code to expect (optional; default: 200)
# Arguments: oc_args - all other arguments are used as additional parameters for the `oc new-app`
#            command, typically environment variables (optional)
function ct_os_test_s2i_app() {
  local image_name=${1}
  local app=${2}
  local context_dir=${3}
  local expected_output=${4}
  local port=${5:-8080}
  local protocol=${6:-http}
  local response_code=${7:-200}
  local oc_args=${8:-}

  if [ $# -lt 4 ] || [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" ]; then
    echo "ERROR: ct_os_test_s2i_app() requires at least 4 arguments that cannot be emtpy." >&2
    return 1
  fi

  ct_os_test_s2i_app_func "${image_name}" \
                          "${app}" \
                          "${context_dir}" \
                          "ct_test_response '${protocol}://<IP>:${port}' '${response_code}' '${expected_output}'" \
                          "${oc_args}"
}

# ct_os_test_template_app_func IMAGE APP IMAGE_IN_TEMPLATE CHECK_CMD [OC_ARGS]
# --------------------
# Runs [image] and [app] in the openshift and optionally specifies env_params
# as environment variables to the image. Then check the container by arbitrary
# function given as argument (such an argument may include <IP> string,
# that will be replaced with actual IP).
# Arguments: image_name - prefix or whole ID of the pod to run the cmd in  (compulsory)
# Arguments: template - url or local path to a template to use (compulsory)
# Arguments: name_in_template - image name used in the template
# Arguments: check_command - CMD line that checks whether the container works (compulsory; '<IP>' will be replaced with actual IP)
# Arguments: oc_args - all other arguments are used as additional parameters for the `oc new-app`
#            command, typically environment variables (optional)
# Arguments: other_images - some templates need other image to be pushed into the OpenShift registry,
#            specify them in this parameter as "<image>|<tag>", where "<image>" is a full image name
#            (including registry if needed) and "<tag>" is a tag under which the image should be available
#            in the OpenShift registry.
function ct_os_test_template_app_func() {
  local image_name=${1}
  local template=${2}
  local name_in_template=${3}
  local check_command=${4}
  local oc_args=${5:-}
  local other_images=${6:-}

  if [ $# -lt 4 ] || [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" ]; then
    echo "ERROR: ct_os_test_template_app_func() requires at least 4 arguments that cannot be emtpy." >&2
    return 1
  fi

  local service_name="${name_in_template}-testing"
  local image_tagged="${name_in_template}:${VERSION}"

  ct_os_new_project
  # Create a specific imagestream tag for the image so that oc cannot use anything else
  ct_os_upload_image "${image_name}" "${image_tagged}"

  # upload also other images, that template might need (list of pairs in the format <image>|<tag>
  local images_tags_a
  local i_t
  for i_t in ${other_images} ; do
    echo "${i_t}"
    IFS='|' read -ra image_tag_a <<< "${i_t}"
    docker pull "${image_tag_a[0]}"
    ct_os_upload_image "${image_tag_a[0]}" "${image_tag_a[1]}"
  done

  local local_template=$(ct_obtain_input "${template}")
  oc new-app ${local_template} \
             -p NAME="${service_name}" \
             -p NAMESPACE="$(oc project -q)" \
             ${oc_args}

  oc start-build "${service_name}"

  ct_os_wait_pod_ready "${service_name}" 300

  local ip=$(ct_os_get_service_ip "${service_name}")
  local check_command_exp=$(echo "$check_command" | sed -e "s/<IP>/$ip/g")

  echo "  Checking APP using $check_command_exp ..."
  local result=0
  eval "$check_command_exp" || result=1

  if [ $result -eq 0 ] ; then
    echo "  Check passed."
  else
    echo "  Check failed."
  fi

  ct_os_delete_project
  return $result
}

# params:
# ct_os_test_template_app IMAGE APP IMAGE_IN_TEMPLATE EXPECTED_OUTPUT [PORT, PROTOCOL, RESPONSE_CODE, OC_ARGS, ... ]
# --------------------
# Runs [image] and [app] in the openshift and optionally specifies env_params
# as environment variables to the image. Then check the http response.
# Arguments: image_name - prefix or whole ID of the pod to run the cmd in (compulsory)
# Arguments: template - url or local path to a template to use (compulsory)
# Arguments: name_in_template - image name used in the template
# Arguments: expected_output - PCRE regular expression that must match the response body (compulsory)
# Arguments: port - which port to use (optional; default: 8080)
# Arguments: protocol - which protocol to use (optional; default: http)
# Arguments: response_code - what http response code to expect (optional; default: 200)
# Arguments: oc_args - all other arguments are used as additional parameters for the `oc new-app`
#            command, typically environment variables (optional)
# Arguments: other_images - some templates need other image to be pushed into the OpenShift registry,
#            specify them in this parameter as "<image>|<tag>", where "<image>" is a full image name
#            (including registry if needed) and "<tag>" is a tag under which the image should be available
#            in the OpenShift registry.
function ct_os_test_template_app() {
  local image_name=${1}
  local template=${2}
  local name_in_template=${3}
  local expected_output=${4}
  local port=${5:-8080}
  local protocol=${6:-http}
  local response_code=${7:-200}
  local oc_args=${8:-}
  local other_images=${9:-}

  if [ $# -lt 4 ] || [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" ]; then
    echo "ERROR: ct_os_test_template_app() requires at least 4 arguments that cannot be emtpy." >&2
    return 1
  fi

  ct_os_test_template_app_func "${image_name}" \
                               "${template}" \
                               "${name_in_template}" \
                               "ct_test_response '${protocol}://<IP>:${port}' '${response_code}' '${expected_output}'" \
                               "${oc_args}" \
                               "${other_images}"
}

# ct_os_test_image_update IMAGE IS CHECK_CMD OC_ARGS
# --------------------
# Runs an image update test with [image] uploaded to [is] imagestream
# and checks the services using an arbitrary function provided in [check_cmd].
# Arguments: image - prefix or whole ID of the pod to run the cmd in (compulsory)
# Arguments: is - imagestream to upload the images into (compulsory)
# Arguments: check_cmd - command to be run to check functionality of created services (compulsory)
# Arguments: oc_args - arguments to use during oc new-app (compulsory)
ct_os_test_image_update() {
  local image_name=$1; shift
  local istag=$1; shift
  local check_function=$1; shift
  local service_name=${image_name##*/}
  local old_image="" ip="" check_command_exp="" registry=""
  registry=$(ct_registry_from_os "$OS")
  old_image="$registry/$image_name"

  echo "Running image update test for: $image_name"
  ct_os_new_project

  # Get current image from repository and create an imagestream
  docker pull "$old_image:latest" 2>/dev/null
  ct_os_upload_image "$old_image" "$istag"

  # Setup example application with curent image
  oc new-app "$@" --name "$service_name"
  ct_os_wait_pod_ready "$service_name" 60

  # Check application output
  ip=$(ct_os_get_service_ip "$service_name")
  check_command_exp=${check_function//<IP>/$ip}
  ct_assert_cmd_success "$check_command_exp"

  # Tag built image into the imagestream and wait for rebuild
  ct_os_upload_image "$image_name" "$istag"
  ct_os_wait_pod_ready "${service_name}-2" 60

  # Check application output
  ip=$(ct_os_get_service_ip "$service_name")
  check_command_exp=${check_function//<IP>/$ip}
  ct_assert_cmd_success "$check_command_exp"

  ct_os_delete_project
}
