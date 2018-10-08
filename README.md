Python container images
====================

This repository contains the source for building various versions of
the Python application as a reproducible container image using
[source-to-image](https://github.com/openshift/source-to-image).
Users can choose between RHEL, Fedora and CentOS based builder images.
The resulting image can be run using [Docker](http://docker.io).

For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.okd.io/latest/using_images/s2i_images/python.html).

For more information about concepts used in these container images, see the
[Landing page](https://github.com/sclorg/welcome).

Contributing
---------------
In this repository [distgen](https://github.com/devexp-db/distgen/) > 1.0 is used for generating directories for Python versions. Also make sure distgen imports the jinja2 package >= 2.10. If you'd like to update some of the files, please make changes in specs/multispec.yml and/or templates under src/ and run `make generate-all`.

For more information about contributing, see
[the Contribution Guidelines](https://github.com/sclorg/welcome/blob/master/contribution.md).

Versions
---------------
Python versions currently provided are:
* [python-2.7](2.7)
* [python-3.5](3.5)
* [python-3.6](3.6)

RHEL versions currently supported are:
* RHEL7

CentOS versions currently supported are:
* CentOS7


Installation
---------------
To build a Python image, choose either the CentOS or RHEL based image:
*  **RHEL based image**

    These images are available in the [Red Hat Container Catalog](https://access.redhat.com/containers/#/registry.access.redhat.com/rhscl/python-36-rhel7).
    To download it run:

    ```
    $ docker pull registry.access.redhat.com/rhscl/python-36-rhel7
    ```

    To build a RHEL based Python image, you need to run the build on a properly
    subscribed RHEL machine.

    ```
    $ git clone https://github.com/sclorg/s2i-python-container.git
    $ cd s2i-python-container
    $ make build TARGET=rhel7 VERSIONS=3.6
    ```

*  **CentOS based image**

    This image is available on DockerHub. To download it run:

    ```
    $ docker pull centos/python-36-centos7
    ```

    To build a Python image from scratch run:

    ```
    $ git clone https://github.com/sclorg/s2i-python-container.git
    $ cd s2i-python-container
    $ make build TARGET=centos7 VERSIONS=3.6
    ```

**Notice: By omitting the `VERSIONS` parameter, the build/test action will be performed
on all provided versions of Python.**


Usage
---------------------------------

For information about usage of Dockerfile for Python 2.7,
see [usage documentation](2.7/README.md).

For information about usage of Dockerfile for Python 3.5,
see [usage documentation](3.5/README.md).

For information about usage of Dockerfile for Python 3.6,
see [usage documentation](3.6/README.md).


Test
---------------------
This repository also provides a [S2I](https://github.com/openshift/source-to-image) test framework,
which launches tests to check functionality of a simple Python application built on top of the s2i-python-container image.

Users can choose between testing a Python test application based on a RHEL or CentOS image.

*  **RHEL based image**

    To test a RHEL7-based Python image, you need to run the test on a properly subscribed RHEL machine.

    ```
    $ cd s2i-python-container
    $ make test TARGET=rhel7 VERSIONS=3.6
    ```

*  **CentOS based image**

    ```
    $ cd s2i-python-container
    $ make test TARGET=centos7 VERSIONS=3.6
    ```

**Notice: By omitting the `VERSIONS` parameter, the build/test action will be performed
on all provided versions of Python.**


Repository organization
------------------------
* **`<python-version>`**

    * **Dockerfile**

        CentOS based Dockerfile.

    * **Dockerfile.rhel7**

        RHEL based Dockerfile. In order to perform build or test actions on this
        Dockerfile you need to run the action on a properly subscribed RHEL machine.

    * **`s2i/bin/`**

        This folder contains scripts that are run by [S2I](https://github.com/openshift/source-to-image):

        *   **assemble**

            Used to install the sources into the location where the application
            will be run and prepare the application for deployment (eg. installing
            dependencies, etc.)

        *   **run**

            This script is responsible for running the application by using the
            application web server.

        *   **usage***

            This script prints the usage of this image.

    * **`contrib/`**

        This folder contains a file with commonly used modules.

    * **`test/`**

        This folder contains a [S2I](https://github.com/openshift/source-to-image)
        test framework with a simple server.

        * **`setup-test-app/`**

            Simple Gunicorn application used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

        * **`standalone-test-app/`**

            Simple standalone application used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

        * **run**

            Script that runs the [S2I](https://github.com/openshift/source-to-image) test framework.

