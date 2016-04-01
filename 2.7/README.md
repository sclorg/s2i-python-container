Python Docker image
===================

This repository contains the source for building various versions of
the Python application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
Users can choose between RHEL and CentOS based builder images.
The resulting image can be run using [Docker](http://docker.io).


Usage
---------------------
To build a simple [python-sample-app](https://github.com/openshift/sti-python/tree/master/2.7/test/setup-test-app) application
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

*  **For RHEL based image**
    ```
    $ s2i build https://github.com/openshift/sti-python.git --context-dir=2.7/test/setup-test-app/ rhscl/python-27-rhel7 python-sample-app
    $ docker run -p 8080:8080 python-sample-app
    ```

*  **For CentOS based image**
    ```
    $ s2i build https://github.com/openshift/sti-python.git --context-dir=2.7/test/setup-test-app/ centos/python-27-centos7 python-sample-app
    $ docker run -p 8080:8080 python-sample-app
    ```

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```


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


Environment variables
---------------------

To set these environment variables, you can place them as a key value pair into
a `.s2i/environment` file inside your source code repository.

* **APP_FILE**

    Used to run the application from a Python script.
    This should be a path to a Python file (defaults to `app.py`) that will be
    passed to the Python interpreter to start the application.

* **APP_MODULE**

    Used to run the application with Gunicorn, as documented
    [here](http://docs.gunicorn.org/en/latest/run.html#gunicorn).
    This variable specifies a WSGI callable with the pattern
    `MODULE_NAME:VARIABLE_NAME`, where `MODULE_NAME` is the full dotted path
    of a module, and `VARIABLE_NAME` refers to a WSGI callable inside the
    specified module.
    Gunicorn will look for a WSGI callable named `application` if not specified.

    If `APP_MODULE` is not provided, the `run` script will look for a `wsgi.py`
    file in your project and use it if it exists.

    If using `setup.py` for installing the application, the `MODULE_NAME` part
    can be read from there. For an example, see
    [setup-test-app](https://github.com/openshift/sti-python/tree/master/2.7/test/setup-test-app).

* **APP_CONFIG**

    Path to a valid Python file with a
    [Gunicorn configuration](http://docs.gunicorn.org/en/latest/configure.html#configuration-file) file.

* **DISABLE_COLLECTSTATIC**

    Set this variable to a non-empty value to inhibit the execution of
    'manage.py collectstatic' during the build. This only affects Django projects.

* **DISABLE_MIGRATE**

    Set this variable to a non-empty value to inhibit the execution of 'manage.py migrate'
    when the produced image is run. This only affects Django projects.

Source repository layout
------------------------

You do not need to change anything in your existing Python project's repository.
However, if these files exist they will affect the behavior of the build process:

* **requirements.txt**

  List of dependencies to be installed with `pip`. The format is documented
  [here](https://pip.pypa.io/en/latest/user_guide.html#requirements-files).


* **setup.py**

  Configures various aspects of the project, including installation of
  dependencies, as documented
  [here](https://packaging.python.org/en/latest/distributing.html#setup-py).
  For most projects, it is sufficient to simply use `requirements.txt`.


Run strategies
--------------

The Docker image produced by sti-python executes your project in one of the
following ways, in precedence order:

* **Gunicorn**

  The Gunicorn WSGI HTTP server is used to serve your application in the case that it
  is installed. It can be installed by listing it either in the `requirements.txt`
  file or in the `install_requires` section of the `setup.py` file.

  If a file named `wsgi.py` is present in your repository, it will be used as
  the entry point to your application. This can be overridden with the
  environment variable `APP_MODULE`.
  This file is present in Django projects by default.

  If you have both Django and Gunicorn in your requirements, your Django project
  will automatically be served using Gunicorn.

* **Django development server**

  If you have Django in your requirements but don't have Gunicorn, then your
  application will be served using Django's development web server. However, this is not
  recommended for production environments.

* **Python script**

  This is the most general way of executing your application. It will be used
  in the case where you specify a path to a Python script via the `APP_FILE` environment
  variable, defaulting to a file named `app.py` if it exists. The script is
  passed to a regular Python interpreter to launch your application.

Hot deploy
---------------------

If you are using Django, hot deploy will work out of the box.

To enable hot deploy while using Gunicorn, make sure you have a Gunicorn
configuration file inside your repository with the
[`reload`](https://gunicorn-docs.readthedocs.org/en/latest/settings.html#reload)
option set to `true`. Make sure to specify your config via the `APP_CONFIG`
environment variable.

To change your source code in running container, use Docker's
[exec](https://docs.docker.com/reference/commandline/exec/) command:

```
docker exec -it <CONTAINER_ID> /bin/bash
```

After you enter into the running container, your current directory is set
to `/opt/app-root/src`, where the source code is located.
