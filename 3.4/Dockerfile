FROM openshift/base-centos7

# This image provides a Python 3.4 environment you can use to run your Python
# applications.

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

ENV PYTHON_VERSION=3.4 \
    PATH=$HOME/.local/bin/:$PATH

LABEL io.k8s.description="Platform for building and running Python 3.4 applications" \
      io.k8s.display-name="Python 3.4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python34,rh-python34"

RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/rh-python34/epel-7-x86_64/download/rhscl-python34-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus rh-python34 rh-python34-python-devel rh-python34-python-setuptools rh-python34-python-pip epel-release && \
    yum install -y --setopt=tsflags=nodocs install nss_wrapper && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
