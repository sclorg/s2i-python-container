FROM openshift/base-centos7

# This image provides a Python 3.3 environment you can use to run your Python
# applications.

MAINTAINER Maciej Szulik <maszulik@redhat.com>

EXPOSE 8080

ENV PYTHON_VERSION=3.3 \
    PATH=.local/bin/:$PATH

LABEL k8s.io/description="Platform for building and running Python 3.3 applications" \
      k8s.io/display-name="Python 3.3" \
      openshift.io/expose-services="8080:http" \
      openshift.io/tags="builder,python,python33"

# Copy the STI scripts from the specific language image to /usr/local/sti
COPY ./.sti/bin/ /usr/local/sti

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/python33/epel-7-x86_64/download/rhscl-python33-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus python33 python33-python-devel python33-python-setuptools epel-release && \
    yum install -y --setopt=tsflags=nodocs install nss_wrapper && \
    yum clean all -y && \
    # FIXME remove this line when pip will be part of python33 package
    scl enable python33 "easy_install pip==1.5.6" && \
    chown -R default:default /opt/app-root && \
    chmod -R og+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD ["usage"]
