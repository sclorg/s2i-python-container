# This image provides a Python 3.8 environment you can use to run your Python
# applications.
FROM quay.io/centos7/s2i-base-centos7

EXPOSE 8080

ENV PYTHON_VERSION=3.8 \
    PYTHON_SCL_VERSION=38 \
    PATH=$PATH:/opt/rh/rh-python38/root/usr/bin:$HOME/.local/bin/:/opt/rh/$NODEJS_SCL/root/usr/bin:/opt/rh/httpd24/root/usr/bin:/opt/rh/python38/root/usr/bin:/opt/rh/httpd24/root/usr/sbin:/opt/rh/rh-python38/root/usr/local/bin \
    LD_LIBRARY_PATH=/opt/rh/rh-python38/root/usr/lib64:/opt/rh/$NODEJS_SCL/root/usr/lib64:/opt/rh/httpd24/root/usr/lib64:/opt/rh/python38/root/usr/lib64 \
    LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64 \
    X_SCLS=rh-python38 \
    MANPATH=/opt/rh/rh-python38/root/usr/share/man:/opt/rh/python38/root/usr/share/man:/opt/rh/httpd24/root/usr/share/man:/opt/rh/$NODEJS_SCL/root/usr/share/man \
    VIRTUAL_ENV=/opt/app-root \
    PYTHONPATH=/opt/rh/$NODEJS_SCL/root/usr/lib/python2.7/site-packages \
    XDG_DATA_DIRS=/opt/rh/python38/root/usr/share:/opt/rh/rh-python38/root/usr/share:/usr/local/share:/usr/share \
    PKG_CONFIG_PATH=/opt/rh/python38/root/usr/lib64/pkgconfig:/opt/rh/httpd24/root/usr/lib64/pkgconfig:/opt/rh/rh-python38/root/usr/lib64/pkgconfig \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIP_NO_CACHE_DIR=off

ENV SUMMARY="Platform for building and running Python $PYTHON_VERSION applications" \
    DESCRIPTION="Python $PYTHON_VERSION available as container is a base platform for \
building and running various Python $PYTHON_VERSION applications and frameworks. \
Python is an easy to learn, powerful programming language. It has efficient high-level \
data structures and a simple but effective approach to object-oriented programming. \
Python's elegant syntax and dynamic typing, together with its interpreted nature, \
make it an ideal language for scripting and rapid application development in many areas \
on most platforms."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Python 3.8" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python38,python-38,rh-python38" \
      com.redhat.component="python38-container" \
      name="centos7/python-38-centos7" \
      version="1" \
      usage="s2i build https://github.com/sclorg/s2i-python-container.git --context-dir=3.8/test/setup-test-app/ centos7/python-38-centos7 python-sample-app" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

RUN INSTALL_PKGS="rh-python38 rh-python38-python-devel rh-python38-python-setuptools rh-python38-python-pip nss_wrapper \
        httpd24 httpd24-httpd-devel httpd24-mod_ssl httpd24-mod_auth_kerb httpd24-mod_ldap \
        httpd24-mod_session atlas-devel gcc-gfortran libffi-devel libtool-ltdl enchant" && \
    yum install -y centos-release-scl && \
    yum -y --setopt=tsflags=nodocs install --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    # Remove centos-logos (httpd dependency) to keep image size smaller.
    rpm -e --nodeps centos-logos && \
    yum -y clean all --enablerepo='*'

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH.
COPY 3.8/s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY 3.8/root/ /

# Python 3 only
# Yes, the directory below is already copied by the previous command.
# The problem here is that the wheels directory is copied as a symlink.
# Only if you specify symlink directly as a source, COPY copies all the
# files from the symlink destination.
COPY 3.8/root/opt/wheels /opt/wheels
# - Create a Python virtual environment for use by any application to avoid
#   potential conflicts with Python packages preinstalled in the main Python
#   installation.
# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.
RUN source scl_source enable rh-python38 && \
    python3.8 -m venv ${APP_ROOT} && \
    # Python 3 only code, Python 2 installs pip from PyPI in the assemble script. \
    # We have to upgrade pip to a newer verison because: \
    # * pip < 9 does not support different packages' versions for Python 2/3 \
    # * pip < 19.3 does not support manylinux2014 wheels. Only manylinux2014 (and later) wheels \
    #   support platforms like ppc64le, aarch64 or armv7 \
    # We are newly using wheel from one of the latest stable Fedora releases (from RPM python-pip-wheel) \
    # because it's tested better then whatever version from PyPI and contains useful patches. \
    # We have to do it here (in the macro) so the permissions are correctly fixed and pip is able \
    # to reinstall itself in the next build phases in the assemble script if user wants the latest version \
    ${APP_ROOT}/bin/pip install /opt/wheels/pip-* && \
    rm -r /opt/wheels && \
    chown -R 1001:0 ${APP_ROOT} && \
    fix-permissions ${APP_ROOT} -P && \
    rpm-file-permissions


USER 1001

# Set the default CMD to print the usage of the language image.
CMD $STI_SCRIPTS_PATH/usage
