# The lowercase "from" is a dirty hack! TODO: Fix it!
# It's needed because ct_test_app_dockerfile changes the source image
# to the one currently in the testing and we need to avoid that here
# so we can prepare our own dockerfile with two different source images.
from #FULL_IMAGE_NAME# as builder

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src
USER 1001

# Install the application's dependencies from PyPI
RUN /usr/libexec/s2i/assemble

from #IMAGE_NAME#

# Copy app sources together with the whole virtual environment from the builder image
COPY --from=builder $APP_ROOT $APP_ROOT

# Install httpd and echant packages - runtime dependencies of our application
USER 0
RUN microdnf install -y httpd enchant
USER 1001

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
