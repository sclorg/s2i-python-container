FROM #IMAGE_NAME# # Replaced by sed in tests, see test_from_dockerfile in test/run

ENV ENABLE_MICROPIPENV=true
ENV DISABLE_SETUP_PY_PROCESSING=true

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src
# Install packages necessary for compiling mod_wsgi from source
RUN microdnf install -y gcc python39-devel httpd httpd-devel redhat-rpm-config
USER 1001

# Install the dependencies
RUN /usr/libexec/s2i/assemble

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
