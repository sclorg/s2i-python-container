Python for OpenShift - Docker images
========================================

This repository contains sources of the images for building various versions
of Python applications as reproducible Docker images using
[source-to-image](https://github.com/openshift/source-to-image).
User can choose between RHEL and CentOS based builder images.
The resulting image can be run using [Docker](http://docker.io).


Versions
---------------
Python versions currently provided are:
* python-3.3

RHEL versions currently supported are:
* RHEL7

CentOS versions currently supported are:
* CentOS7


Installation
---------------
To build Python image, choose between CentOS or RHEL based image:
*  **RHEL based image**

    To build a rhel-based python-3.3 image, you need to run the build on a properly
    subscribed RHEL machine.

    ```
    $ git clone https://github.com/openshift/sti-python.git
    $ cd sti-python
    $ make build TARGET=rhel7 VERSION=3.3
    ```

*  **CentOS based image**

    This image is available on DockerHub. To download it use:

    ```
    $ docker pull openshift/python-33-centos7
    ```

    To build Python image from scratch use:

    ```
    $ git clone https://github.com/openshift/sti-python.git
    $ cd sti-python
    $ make build VERSION=3.3
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all provided versions of Python. Since we are now providing only version `3.3`,
you can omit this parameter.**


Usage
---------------------
To build a simple [python-sample-app](https://github.com/openshift/sti-python/tree/master/3.3/test/setup-test-app) application,
using standalone [STI](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

*  **For RHEL based image**
    ```
    $ sti build https://github.com/openshift/sti-python.git --context-dir=3.3/test/setup-test-app/ openshift/python-33-rhel7 python-sample-app
    $ docker run -p 8080:8080 python-sample-app
    ```

*  **For CentOS based image**
    ```
    $ sti build https://github.com/openshift/sti-python.git --context-dir=3.3/test/setup-test-app/ openshift/python-33-centos7 python-sample-app
    $ docker run -p 8080:8080 python-sample-app
    ```

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```


Test
---------------------
This repository also provides [STI](https://github.com/openshift/source-to-image) test framework,
which launches tests to check functionality of a simple python application built on top of sti-python image.

User can choose between testing python test application based on RHEL or CentOS image.

*  **RHEL based image**

    To test a rhel7-based python-3.3 image, you need to run the test on a properly subscribed RHEL machine.

    ```
    $ cd sti-python
    $ make test TARGET=rhel7 VERSION=3.3
    ```

*  **CentOS based image**

    ```
    $ cd sti-python
    $ make test VERSION=3.3
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all provided versions of Python. Since we are now providing only version `3.3`
you can omit this parameter.**


Repository organization
------------------------
* **`<python-version>`**

    * **Dockerfile**

        CentOS based Dockerfile.

    * **Dockerfile.rhel7**

        RHEL based Dockerfile. In order to perform build or test actions on this
        Dockerfile you need to run the action on a properly subscribed RHEL machine.

    * **`.sti/bin/`**

        This folder contains scripts that are run by [STI](https://github.com/openshift/source-to-image):

        *   **assemble**

            Is used to install the sources into location from where the application
            will be run and prepare the application for deployment (eg. installing
            dependencies, etc.)

        *   **run**

            This script is responsible for running the application, by using the
            application web server.

        *   **usage***

            This script prints the usage of this image.

    * **`contrib/`**

        This folder contains file with commonly used modules.

    * **`test/`**

        This folder is containing [STI](https://github.com/openshift/source-to-image)
        test framework with simple server.

        * **`setup-test-app/`**

            Simple gunicorn application used for testing purposes in the [STI](https://github.com/openshift/source-to-image) test framework.

        * **`standalone-test-app/`**

            Simple standalone application used for testing purposes in the [STI](https://github.com/openshift/source-to-image) test framework.

        * **run**

            Script that runs the [STI](https://github.com/openshift/source-to-image) test framework.

* **`hack/`**

    Folder contains scripts which are responsible for build and test actions performed by the `Makefile`.


Image name structure
------------------------
##### Structure: openshift/1-2-3

1. Platform name - python
2. Platform version(without dots)
3. Base builder image - centos7/rhel7

Examples: `openshift/python-33-centos7`, `openshift/python-33-rhel7`


Environment variables
---------------------

To set these environment variables, you can place them into `.sti/environment`
file inside your source code repository.

* **APP_FILE**

    This variable specifies file name (defaults to `app.py`) passed to the python interpreter which is
    responsible for launching application.

* **APP_MODULE**

    This variable specifies WSGI callable. It is of the pattern `$(MODULE_NAME):$(VARIABLE_NAME)`,
    where module name is a full dotted path and the variable name refers to a inside the specified module.
    If using `setup.py` for installing the application the module name can be read from that file and variable
    will default to `application`, eg. see [setup-test-app](https://github.com/openshift/sti-python/tree/master/3.3/test/setup-test-app).

* **APP_CONFIG**

    This variable indicates path to a module which contains [gunicorn configuration](http://docs.gunicorn.org/en/latest/configure.html).
