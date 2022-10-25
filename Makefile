# Variables are documented in common/build.sh.
BASE_IMAGE_NAME = python
VERSIONS = 2.7 3.6 3.8 3.9 3.9-minimal 3.10
SKIP_GENERATOR_FOR = 3.9-minimal
OPENSHIFT_NAMESPACES = 
DOCKER_BUILD_CONTEXT = ..

# HACK:  Ensure that 'git pull' for old clones doesn't cause confusion.
# New clones should use '--recursive'.
.PHONY: $(shell test -f common/common.mk || echo >&2 'Please do "git submodule update --init" first.')

include common/common.mk
