FROM openshift/base-rhel7

# This image provides a Python 3.4 environment you can use to run your Python
# applications.

EXPOSE 8080

ENV PYTHON_VERSION=3.4 \
    PATH=$HOME/.local/bin/:$PATH

LABEL io.k8s.description="Platform for building and running Python 3.4 applications" \
      io.k8s.display-name="Python 3.4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python34,rh-python34"

# Labels consumed by Red Hat build service
LABEL Name="rhscl/python-34-rhel7" \
      BZComponent="rh-python34-docker" \
      Version="3.4" \
      Release="1" \
      Architecture="x86_64"

RUN yum-config-manager --enable rhel-server-rhscl-7-rpms \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --disable epel >/dev/null || : && \
    yum install -y --setopt=tsflags=nodocs rh-python34 rh-python34-python-devel rh-python34-python-setuptools rh-python34-python-pip nss_wrapper && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
