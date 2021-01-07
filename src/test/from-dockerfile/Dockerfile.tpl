FROM #IMAGE_NAME# # Replaced by sed in tests, see test_from_dockerfile in test/run

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
# With a newer docker that supports --chown option for ADD statement, or with
# podman, we can replace the following four statements with
#   ADD --chown 1001:0 app-src /tmp/src
USER 0
ADD app-src /tmp/src
RUN chown -R 1001:0 /tmp/src
USER 1001

# Install the dependencies
RUN /usr/libexec/s2i/assemble

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
