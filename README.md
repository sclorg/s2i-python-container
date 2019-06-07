Python container images
====================

This repository contains the source for building various versions of
the Python application as a reproducible container image using
[source-to-image](https://github.com/openshift/source-to-image).
Users can choose between RHEL, Fedora and CentOS based builder images.
The resulting image can be run using [podman](https://github.com/containers/libpod) or
[docker](http://docker.io).

For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.okd.io/latest/using_images/s2i_images/python.html).

For more information about concepts used in these container images, see the
[Landing page](https://github.com/sclorg/welcome).

Contributing
---------------
In this repository [distgen](https://github.com/devexp-db/distgen/) > 1.0 is used for generating directories for Python versions. Also make sure distgen imports the jinja2 package >= 2.10.

Files in directories for a specific Python version are generated from templates in the src directory with values from specs/multispec.yml.

A typical way how to contribute is:

1. Add a feature or fix a bug in templates (src directory) or values (specs/multispec.yml file).
1. Commit the changes.
1. Regenerate all files via `make generate-all`.
1. Commit generated files.
1. Test changes via `make test TARGET=fedora VERSIONS=3.7` which will `build`, `tag` and `test` an image in one step.
1. Open a pull request!

For more information about contributing, see
[the Contribution Guidelines](https://github.com/sclorg/welcome/blob/master/contribution.md).

Versions
---------------
Python versions currently provided are:
* [python-2.7](2.7)
* [python-3.5](3.5)
* [python-3.6](3.6)
* [python-3.7](3.7)

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
    $ podman pull registry.access.redhat.com/rhscl/python-36-rhel7
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
    $ podman pull centos/python-36-centos7
    ```

    To build a Python image from scratch run:

    ```
    $ git clone https://github.com/sclorg/s2i-python-container.git
    $ cd s2i-python-container
    $ make build TARGET=centos7 VERSIONS=3.6
    ```

Note: while the installation steps are calling `podman`, you can replace any such calls by `docker` with the same arguments.

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

