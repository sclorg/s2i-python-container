Python Docker images
====================

This repository contains the source for building various versions of
the Python application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
Users can choose between RHEL and CentOS based builder images.
The resulting image can be run using [Docker](http://docker.io).

For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.openshift.org/latest/using_images/s2i_images/python.html).

Versions
---------------
Python versions currently provided are:
* python-2.7
* python-3.4
* python-3.5

RHEL versions currently supported are:
* RHEL7

CentOS versions currently supported are:
* CentOS7


Installation
---------------
To build a Python image, choose either the CentOS or RHEL based image:
*  **RHEL based image**

    To build a RHEL based Python image, you need to run the build on a properly
    subscribed RHEL machine.

    ```
    $ git clone https://github.com/sclorg/s2i-python-container.git
    $ cd s2i-python-container
    $ make build TARGET=rhel7 VERSION=3.5
    ```

*  **CentOS based image**

    This image is available on DockerHub. To download it run:

    ```
    $ docker pull centos/python-35-centos7
    ```

    To build a Python image from scratch run:

    ```
    $ git clone https://github.com/sclorg/s2i-python-container.git
    $ cd s2i-python-container
    $ make build TARGET=centos7 VERSION=3.5
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all provided versions of Python.**


Usage
---------------------------------

For information about usage of Dockerfile for Python 2.7,
see [usage documentation](2.7/README.md).

For information about usage of Dockerfile for Python 3.4,
see [usage documentation](3.4/README.md).

For information about usage of Dockerfile for Python 3.5,
see [usage documentation](3.5/README.md).


Test
---------------------
This repository also provides a [S2I](https://github.com/openshift/source-to-image) test framework,
which launches tests to check functionality of a simple Python application built on top of the s2i-python-container image.

Users can choose between testing a Python test application based on a RHEL or CentOS image.

*  **RHEL based image**

    To test a RHEL7-based Python image, you need to run the test on a properly subscribed RHEL machine.

    ```
    $ cd s2i-python-container
    $ make test TARGET=rhel7 VERSION=3.5
    ```

*  **CentOS based image**

    ```
    $ cd s2i-python-container
    $ make test TARGET=centos7 VERSION=3.5
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all provided versions of Python.**


Repository organization
------------------------
* **`<python-version>`**

    Dockerfile and scripts to build container images from.

* **`hack/`**

    Folder containing scripts which are responsible for build and test actions performed by the `Makefile`.


Image name structure
------------------------

1. Platform name (lowercase) - python
2. Platform version(without dots) - 35
3. Base builder image - centos7/rhel7

Examples: `python-35-centos7`, `python-35-rhel7`

