FROM #FULL_IMAGE_NAME# as builder

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src
USER 1001

# Install the application's dependencies from PyPI
RUN /usr/libexec/s2i/assemble

FROM #IMAGE_NAME#

# Copy app sources together with the whole virtual environment from the builder image
COPY --from=builder $APP_ROOT $APP_ROOT

# Install httpd package - runtime dependency of our application
USER 0
RUN microdnf install -y httpd
USER 1001

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
