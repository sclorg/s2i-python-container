FROM #IMAGE_NAME# # Replaced by sed in ct_test_app_dockerfile

ENV UPGRADE_PIP_TO_LATEST=1

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src
# Install packages necessary for compiling uwsgi from source
RUN microdnf install -y gcc python39-devel which
USER 1001

# Install the dependencies
RUN /usr/libexec/s2i/assemble

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
