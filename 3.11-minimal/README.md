Python 3.11 container image - minimal version
============================================

This container image is a special version of the [full Python 3.11 container image](https://github.com/sclorg/s2i-python-container/tree/master/3.11)
provided as a [S2I](https://github.com/openshift/source-to-image) base image for your Python 3.11 applications.

Because the minimal and full images work similarly, we document here only the differences and limitations
of the minimal container image. For the documentation of common features see the [full container image docs](https://github.com/sclorg/s2i-python-container/tree/master/3.11).

The Python 3.11 minimal container image is currently considered a tech-preview and only available on quay.io.
The image is built on top of the [official CentOS Stream base containers](quay.io/centos/centos).

To pull the Python 3.11 minimal container image to build on, run

```
podman pull quay.io/sclorg/python-311-minimal-c9s
```

Description
-----------

The full container image is a universal base image to build your containerized applications on top of. However, its universal nature
means that the resulting containers it produces consume a lot of disk space. This is caused mainly by the fact that the image contains
npm, compilers, header files and some other packages one might need to install and deploy their applications.

Because size does matter for us and our customers, we have prepared this minimal container image with very limited subset
of installed packages. There are no compilers, no header files, no npm etc and the yum package manager is replaced with a minimalistic
reimplementation called microdnf, making the resulting container images much smaller. This creates some limitations
but we provide ways to workaround them.

Limitations
-----------

1. There is only a very limited subset of packages installed. They are choosen carefully to satisfy most of the Python apps but your app might have some special needs.
1. There is no npm and nodejs.
1. There are no compilers and header files. Installation from Python wheels should still work but compilation from a source code is not supported out of the box.

In the next chapter, we provide three possible workarounds for the mentioned limitations of the minimal container image.

Possible solutions for the limitations
--------------------------------------

### Use the full container image

It's easy at that. If you don't want to write your own Dockerfile and disk space is not a problem, use
the full universal container image and you should be fine.

### Build your own container image on top of the minimal container image

Let's say that your application depends on uwsgi. uwsgi cannot be installed from Python wheel and has to be
compiled from source which requires some additional packages to be installed - namely gcc for the compilation
itself and python3.11-devel containing Python header files.

To solve that problem, you can use all the pieces provided by the minimal container image and just add one more
step to install the missing dependencies:

```
FROM python-311-minimal

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src

# Install packages necessary for compiling uwsgi from source
RUN microdnf install -y gcc python3.11-devel
USER 1001

# Install the dependencies
RUN /usr/libexec/s2i/assemble

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
```

If you do it this way, your problem with the missing packages is solved. But there is also one disadvantage: the resulting
runtime image contains unnecessary compiler and Python header files. How to solve this? Uninstalling them at the end
of the Dockerfile is not really a solution but we have one. Keep reading.

### Build on full image, run on minimal image

Did you know that you can copy files from one image to another one during a build? That's the feature we are gonna use now.
We use the full container image with all compilers and other usefull packages installed to build our app and its dependencies
and we then move the result including the whole virtual environemnt to the minimal container image.

This app needs mod_wsgi and to install (compile it from source) it, we'll need: httpd-devel for header files, gcc and redhat-rpm-config
as a compiler and configuratuion and finally python3.11-devel containing Python header files. There is no need to install those packages
manually because the full container image already contains them. However, the application needs httpd as a runtime dependency
so we need to install it to the minimal container image as well.

```
# Part 1 - build

FROM python-311 as builder

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
ADD app-src /tmp/src
RUN /usr/bin/fix-permissions /tmp/src
USER 1001

# Install the application's dependencies from PyPI
RUN /usr/libexec/s2i/assemble

# Part 2 - deploy

FROM python-311-minimal

# Copy app sources together with the whole virtual environment from the builder image
COPY --from=builder $APP_ROOT $APP_ROOT

# Install httpd package - runtime dependency of our application
USER 0
RUN microdnf install -y httpd
USER 1001

# Set the default command for the resulting image
CMD /usr/libexec/s2i/run
```

This way, the resulting container image does contain only necessary dependencies and it's much lighter.
