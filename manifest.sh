# Manifest for Dockerfiles creation
# every dest path will be prefixed by $DESTDIR/$version

# Files containing distgen directives
DISTGEN_RULES="
    src=src/cccp.yml
    dest=cccp.yml;

    src=src/README.md
    dest=README.md;

    src=src/root/opt/app-root/etc/scl_enable
    dest=root/opt/app-root/etc/scl_enable;

    src=src/s2i/bin/assemble
    dest=s2i/bin/assemble
    mode=0755;

    src=src/s2i/bin/usage
    dest=s2i/bin/usage
    mode=0755;

    src=src/test/pipenv-test-app/Pipfile
    dest=test/pipenv-test-app/Pipfile;

    src=src/test/pipenv-test-app/Pipfile.lock
    dest=test/pipenv-test-app/Pipfile.lock;
"

# Files containing distgen directives, which are used for each
# (distro, version) combination not excluded in multispec
DISTGEN_MULTI_RULES="
    src=src/Dockerfile.template
    dest=Dockerfile;

    src=src/Dockerfile.template
    dest=Dockerfile.rhel7;

    src=src/Dockerfile.template
    dest=Dockerfile.fedora;
"

# Symbolic links
SYMLINK_RULES=""

# Files to copy
COPY_RULES="
    src=src/content_sets.yml
    dest=content_sets.yml;

    src=src/root/opt/app-root/etc/generate_container_user
    dest=root/opt/app-root/etc/generate_container_user;

    src=src/s2i/bin/run
    dest=s2i/bin/run
    mode=0755;

    src=test/run
    dest=test/run
    mode=0755;

    src=test/run-openshift
    dest=test/run-openshift
    mode=0755;

    src=common/test-lib.sh
    dest=test/test-lib.sh;

    src=common/test-lib-openshift.sh
    dest=test/test-lib-openshift.sh;

    src=examples/app-home-test-app/project/__init__.py
    dest=test/app-home-test-app/project/__init__.py;

    src=examples/app-home-test-app/project/wsgi.py
    dest=test/app-home-test-app/project/wsgi.py;

    src=examples/app-home-test-app/.s2i/environment
    dest=test/app-home-test-app/.s2i/environment;

    src=examples/app-home-test-app/requirements.txt
    dest=test/app-home-test-app/requirements.txt;

    src=examples/mod-wsgi-test-app/app.py
    dest=test/mod-wsgi-test-app/app.py;

    src=examples/mod-wsgi-test-app/requirements.txt
    dest=test/mod-wsgi-test-app/requirements.txt;

    src=examples/mod-wsgi-test-app/wsgi.py
    dest=test/mod-wsgi-test-app/wsgi.py;

    src=examples/pipenv-test-app/.gitignore
    dest=test/pipenv-test-app/.gitignore;

    src=examples/pipenv-test-app/testapp.py
    dest=test/pipenv-test-app/testapp.py;

    src=examples/pipenv-test-app/.s2i/environment
    dest=test/pipenv-test-app/.s2i/environment;

    src=examples/pipenv-test-app/setup.py
    dest=test/pipenv-test-app/setup.py;

    src=examples/django-postgresql.json
    dest=test/django-postgresql.json;

    src=examples/django-test-app/.gitignore
    dest=test/django-test-app/.gitignore;

    src=examples/django-test-app/project/settings.py
    dest=test/django-test-app/project/settings.py;

    src=examples/django-test-app/project/__init__.py
    dest=test/django-test-app/project/__init__.py;

    src=examples/django-test-app/project/urls.py
    dest=test/django-test-app/project/urls.py;

    src=examples/django-test-app/project/wsgi.py
    dest=test/django-test-app/project/wsgi.py;

    src=examples/django-test-app/requirements.txt
    dest=test/django-test-app/requirements.txt;

    src=examples/django-test-app/manage.py
    dest=test/django-test-app/manage.py;

    src=examples/standalone-test-app/app.py
    dest=test/standalone-test-app/app.py;

    src=examples/standalone-test-app/requirements.txt
    dest=test/standalone-test-app/requirements.txt;

    src=examples/django-postgresql-persistent.json
    dest=test/django-postgresql-persistent.json;

    src=examples/locale-test-app/requirements.txt
    dest=test/locale-test-app/requirements.txt;

    src=examples/locale-test-app/wsgi.py
    dest=test/locale-test-app/wsgi.py;

    src=examples/numpy-test-app/requirements.txt
    dest=test/numpy-test-app/requirements.txt;

    src=examples/numpy-test-app/wsgi.py
    dest=test/numpy-test-app/wsgi.py;

    src=examples/setup-test-app/.gitignore
    dest=test/setup-test-app/.gitignore;

    src=examples/setup-test-app/testapp.py
    dest=test/setup-test-app/testapp.py;

    src=examples/setup-test-app/setup.py
    dest=test/setup-test-app/setup.py;

    src=examples/setup-requirements-test-app/.gitignore
    dest=test/setup-requirements-test-app/.gitignore;

    src=examples/setup-requirements-test-app/testapp.py
    dest=test/setup-requirements-test-app/testapp.py;

    src=examples/setup-requirements-test-app/setup.py
    dest=test/setup-requirements-test-app/setup.py;

    src=examples/setup-requirements-test-app/requirements.txt
    dest=test/setup-requirements-test-app/requirements.txt;

    src=examples/npm-virtualenv-uwsgi-test-app/.s2i/environment
    dest=test/npm-virtualenv-uwsgi-test-app/.s2i/environment;

    src=examples/npm-virtualenv-uwsgi-test-app/app.sh
    dest=test/npm-virtualenv-uwsgi-test-app/app.sh;

    src=examples/npm-virtualenv-uwsgi-test-app/requirements.txt
    dest=test/npm-virtualenv-uwsgi-test-app/requirements.txt;

    src=examples/npm-virtualenv-uwsgi-test-app/wsgi.py
    dest=test/npm-virtualenv-uwsgi-test-app/wsgi.py;
"
