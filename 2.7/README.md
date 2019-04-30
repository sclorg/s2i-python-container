Python 2.7 container image
===================

This container image includes Python 2.7 as a [S2I](https://github.com/openshift/source-to-image) base image for your Python 2.7 applications.
Users can choose between RHEL and CentOS based builder images.
The RHEL images are available in the [Red Hat Container Catalog](https://access.redhat.com/containers/),
the CentOS images are available on [Docker Hub](https://hub.docker.com/r/centos/),
and the Fedora images are available in [Fedora Registry](https://registry.fedoraproject.org/).
The resulting image can be run using [podman](https://github.com/containers/libpod) or
[docker](http://docker.io).

Note: while the examples in this README are calling `podman`, you can replace any such calls by `docker` with the same arguments

Description
-----------

Python 2.7 available as container is a base platform for 
building and running various Python 2.7 applications and frameworks. 
Python is an easy to learn, powerful programming language. It has efficient high-level 
data structures and a simple but effective approach to object-oriented programming. 
Python's elegant syntax and dynamic typing, together with its interpreted nature, 
make it an ideal language for scripting and rapid application development in many areas 
on most platforms.

This container image includes an npm utility, so users can use it to install JavaScript
modules for their web applications. There is no guarantee for any specific npm or nodejs
version, that is included in the image; those versions can be changed anytime and
the nodejs itself is included just to make the npm work.

Usage
---------------------

For this, we will assume that you are using the `rhscl/python-27-rhel7 image`, available via `python:2.7` imagestream tag in Openshift.
Building a simple [python-sample-app](https://github.com/sclorg/s2i-python-container/tree/master/2.7/test/setup-test-app) application
in Openshift can be achieved with the following step:

    ```
    oc new-app python:3.6~https://github.com/sclorg/s2i-python-container.git --context-dir=2.7/test/setup-test-app/
    ```

The same application can also be built using the standalone [S2I](https://github.com/openshift/source-to-image) application on systems that have it available:

    ```
    $ s2i build https://github.com/sclorg/s2i-python-container.git --context-dir=2.7/test/setup-test-app/ rhscl/python-27-rhel7 python-sample-app
    ```

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```

Environment variables
---------------------

To set these environment variables, you can place them as a key value pair into a `.s2i/environment`
file inside your source code repository.

* **APP_SCRIPT**

    Used to run the application from a script file.
    This should be a path to a script file (defaults to `app.sh` unless set to null) that will be
    run to start the application.

* **APP_FILE**

    Used to run the application from a Python script.
    This should be a path to a Python file (defaults to `app.py` unless set to null) that will be
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
    [setup-test-app](https://github.com/sclorg/s2i-python-container/tree/master/2.7/test/setup-test-app).

* **APP_HOME**

    This variable can be used to specify a sub-directory in which the application to be run is contained.
    The directory pointed to by this variable needs to contain `wsgi.py` (for Gunicorn) or `manage.py` (for Django).

    If `APP_HOME` is not provided, the `assemble` and `run` scripts will use the application's root
    directory.

* **APP_CONFIG**

    Path to a valid Python file with a
    [Gunicorn configuration](http://docs.gunicorn.org/en/latest/configure.html#configuration-file) file.

* **DISABLE_MIGRATE**

    Set this variable to a non-empty value to inhibit the execution of 'manage.py migrate'
    when the produced image is run. This only affects Django projects. See
    "Handling Database Migrations" section of [Django blogpost on OpenShift blog](
    https://blog.openshift.com/migrating-django-applications-openshift-3/) on suggestions
    how/when to run DB migrations in OpenShift environment. Most importantly,
    note that running DB migrations from two or more pods might corrupt your database.

* **DISABLE_COLLECTSTATIC**

    Set this variable to a non-empty value to inhibit the execution of
    'manage.py collectstatic' during the build. This only affects Django projects.

* **DISABLE_SETUP_PY_PROCESSING**

    Set this to a non-empty value to skip processing of setup.py script if you
    use `-e .` in requirements.txt to trigger its processing or you don't want
    your application to be installed into site-packages directory.

* **ENABLE_PIPENV**

    Set this variable to use [Pipenv](https://github.com/kennethreitz/pipenv),
    the higher-level Python packaging tool, to manage dependencies of the application.
    This should be used only if your project contains properly formated Pipfile
    and Pipfile.lock. (Implies `UPGRADE_PIP_TO_LATEST` to satisfy dependencies of
    Pipenv.)

* **ENABLE_INIT_WRAPPER**

    Set this variable to a non-empty value to make use of an init wrapper.
    This is useful for servers that are not capable of reaping zombie
    processes, such as Django development server or Tornado. This option can
    be used together with **APP_SCRIPT** or **APP_FILE**. It never applies
    to Gunicorn used through **APP_MODULE** as Gunicorn reaps zombie
    processes correctly.

* **PIP_INDEX_URL**

    Set this variable to use a custom index URL or mirror to download required packages
    during build process. This only affects packages listed in requirements.txt.
    Pipenv ignores this variable.

* **UPGRADE_PIP_TO_LATEST**

    Set this variable to a non-empty value to have the 'pip' program and related
    python packages (setuptools and wheel) be upgraded to the most recent version
    before any Python packages are installed. If not set it will use whatever
    the default version is included by the platform for the Python version being used.

* **WEB_CONCURRENCY**

    Set this to change the default setting for the number of
    [workers](http://docs.gunicorn.org/en/stable/settings.html#workers). By
    default, this is set to the number of available cores times 2, capped
    at 12.


Source repository layout
------------------------

You do not need to change anything in your existing Python project's repository.
However, if these files exist they will affect the behavior of the build process:

* **requirements.txt**

  List of dependencies to be installed with `pip`. The format is documented
  [here](https://pip.pypa.io/en/latest/user_guide.html#requirements-files).


* **Pipfile**

  The replacement for requirements.txt, project is currently under active
  design and development, as documented [here](https://github.com/pypa/pipfile).
  Set `ENABLE_PIPENV` environment variable to true in order to process this file.


* **setup.py**

  Configures various aspects of the project, including installation of
  dependencies, as documented
  [here](https://packaging.python.org/en/latest/distributing.html#setup-py).
  For most projects, it is sufficient to simply use `requirements.txt` or
  `Pipfile`. Set `DISABLE_SETUP_PY_PROCESSING` environment variable to true
  in order to skip processing of this file.

Run strategies
--------------

The container image produced by s2i-python executes your project in one of the
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

  This would be used where you provide a Python code file for running you
  application. It will be used in the case where you specify a path to a
  Python script via the `APP_FILE` environment variable, defaulting to a
  file named `app.py` if it exists. The script is passed to a regular
  Python interpreter to launch your application.

* **Application script file**

  This is the most general way of executing your application. It will be
  used in the case where you specify a path to an executable script file
  via the `APP_SCRIPT` environment variable, defaulting to a file named
  `app.sh` if it exists. The script is executed directly to launch your
  application.

Hot deploy
---------------------

If you are using Django, hot deploy will work out of the box.

To enable hot deploy while using Gunicorn, make sure you have a Gunicorn
configuration file inside your repository with the
[`reload`](https://gunicorn-docs.readthedocs.org/en/latest/settings.html#reload)
option set to `true`. Make sure to specify your config via the `APP_CONFIG`
environment variable.

To change your source code in running container, use podman's (or docker's)
[exec](https://github.com/containers/libpod/blob/master/docs/podman-exec.1.md) command:

```
podman exec -it <CONTAINER_ID> /bin/bash
```

After you enter into the running container, your current directory is set
to `/opt/app-root/src`, where the source code is located.


See also
--------
Dockerfile and other sources are available on https://github.com/sclorg/s2i-python-container.
In that repository you also can find another versions of Python environment Dockerfiles.
Dockerfile for CentOS is called `Dockerfile`, Dockerfile for RHEL7 is called `Dockerfile.rhel7`,
for RHEL8 it's `Dockerfile.rhel8` and the Fedora Dockerfile is called `Dockerfile.fedora`.
