FROM #IMAGE_NAME# # Replaced by sed in ct_test_app_dockerfile

ENV UPGRADE_PIP_TO_LATEST=1

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src
# Install packages necessary for compiling uwsgi from source
# pkgconfig(python-3.9) is provided by both python3-devel in c9s
# and python39-devel in UBI8.
RUN microdnf install -y gcc "pkgconfig(python-3.9)" which
USER 1001

# Install the dependencies
RUN /usr/libexec/s2i/assemble

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
