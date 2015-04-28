FROM openshift/base-centos7

# This image provides a Python 3.3 environment you can use to run your Python
# applications.

MAINTAINER Maciej Szulik <maszulik@redhat.com>

# Image metadata
ENV PYTHON_VERSION        3.3
ENV IMAGE_DESCRIPTION     Python 3.3
ENV IMAGE_TAGS            python,python33
ENV IMAGE_EXPOSE_SERVICES 8080:http

RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/python33/epel-7-x86_64/download/rhscl-python33-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs python33 python33-python-devel python33-python-setuptools && \
    yum clean all -y && \
    scl enable python33 "easy_install pip"

ENV PATH .local/bin/:$PATH

EXPOSE 8080

# Copy the STI scripts from the specific language image to /usr/local/sti
COPY ./.sti/bin/ /usr/local/sti

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/openshift

RUN chown -R default:default /opt/openshift

USER default

# Set the default CMD to print the usage of the language image
CMD ["usage"]
