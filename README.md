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

    Used to run the application from a Python script.
    This should be a path to a Python file (defaults to `app.py`) that will be
    passed to the Python interpreter to start the application.

* **APP_MODULE**

    Used to run the application with gunicorn, as documented
    [here](http://docs.gunicorn.org/en/latest/run.html#gunicorn).
    This variable specifies a WSGI callable with the pattern
    `MODULE_NAME:VARIABLE_NAME`, where `MODULE_NAME` is a full dotted path
    of a module, and `VARIABLE_NAME` refers to a WSGI callable inside the
    specified module.
    Gunicorn will look for a WSGI callable named `application` if not specified.

    If `APP_MODULE` is not provided, the `run` script will look for a `wsgi.py`
    file in your project and use it if it exists.

    If using `setup.py` for installing the application, the `MODULE_NAME` part
    can be read from there. For example, see
    [setup-test-app](https://github.com/openshift/sti-python/tree/master/3.3/test/setup-test-app).

* **APP_CONFIG**

    Path to a valid Python file with
    [gunicorn configuration](http://docs.gunicorn.org/en/latest/configure.html#configuration-file).

* **DISABLE_COLLECTSTATIC**

    Set it to a nonempty value to inhibit the execution of
    'manage.py collectstatic' during the build. Only affects Django projects.

* **DISABLE_MIGRATE**

    Set it to a nonempty value to inhibit the execution of 'manage.py migrate'
    when the produced image is run. Only affects Django projects.

Source repository layout
------------------------

You need not change anything in your existing Python project's repository.
However, if these files exist they affect the behavior of the build process:

* **requirements.txt**

  List of dependencies to be installed with `pip`. The format is documented
  [here](https://pip.pypa.io/en/latest/user_guide.html#requirements-files).


* **setup.py**

  Configuration of various aspects of the project, including installation
  dependencies, as documented
  [here](https://packaging.python.org/en/latest/distributing.html#setup-py).
  For most projects, it is sufficient to use `requirements.txt`.


Run strategies
--------------

The Docker image produced by sti-python executes your project in one of these
ways, in precedence order:

* **Gunicorn**

  The Gunicorn WSGI HTTP server is used to serve your application in case it is
  installed. It can be installed by listing it either in the `requirements.txt`
  file or in the `install_requires` section of the `setup.py` file.

  If a file named `wsgi.py` is present in your repository, it will be used as
  the entry point to your application. This can be overridden with the
  environment variable `APP_MODULE`.
  This file is present in Django projects by default.

  If you have both Django and Gunicorn in your requirements, your Django project
  will be automatically served with Gunicorn.

* **Django development server**

  If you have Django in your requirements, but don't have Gunicorn, then your
  application will be served with Django's development web server. This is not,
  however, a recommended way to serve your application in production.

* **Python script**

  This is the most general way of executing your application. It will be used
  in case you specify a path to a Python script via the `APP_FILE` environment
  variable, defaulting to a file named `app.py` if it exists. The script is
  passed to a regular Python interpreter to launch your application.
