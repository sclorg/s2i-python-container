# Variables are documented in hack/build.sh.
BASE_IMAGE_NAME = python
VERSIONS = 2.7 3.3 3.4
OPENSHIFT_NAMESPACES = 3.3

# Include common Makefile code.
include hack/common.mk
