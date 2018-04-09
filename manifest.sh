# Manifest for Dockerfiles creation
# every dest path will be prefixed by $DESTDIR/$version

DISTGEN_MULTI_RULES="
    src=src/Dockerfile.template
    dest=Dockerfile;

    src=src/Dockerfile.template
    dest=Dockerfile.rhel7;

    src=src/Dockerfile.template
    dest=Dockerfile.fedora
"
