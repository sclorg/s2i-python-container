FROM openshift/base-centos7

# This image provides a Python 2.7 environment you can use to run your Python
# applications.

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

ENV PYTHON_VERSION=2.7 \
    PATH=$HOME/.local/bin/:$PATH

LABEL io.k8s.description="Platform for building and running Python 2.7 applications" \
      io.k8s.display-name="Python 2.7" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python27,rh-python27"

RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/python27/epel-7-x86_64/download/rhscl-python27-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus python27 python27-python-devel python27-python-setuptools python27-python-pip epel-release && \
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
