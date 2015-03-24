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

USER default

EXPOSE 8080
