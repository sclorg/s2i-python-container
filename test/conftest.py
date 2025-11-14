import os
import sys
from pathlib import Path
from collections import namedtuple

from container_ci_suite.utils import check_variables
from pytest import skip

if not check_variables():
    sys.exit(1)

TAGS = {
    "rhel8": "-ubi8",
    "rhel9": "-ubi9",
    "rhel10": "-ubi10",
}


Vars = namedtuple(
    "Vars",
    [
        "OS",
        "VERSION",
        "IMAGE_NAME",
        "IS_MINIMAL",
        "VERSION_NO_MINIMAL",
        "SHORT_VERSION",
        "TAG",
        "TEST_DIR",
        "WEB_APPS",
        "SHOULD_FAIL_WEB_APPS",
        "BRANCH_TO_TEST",
        "DEPLOYED_PSQL_IMAGE",
        "IMAGE_TAG",
        "PSQL_VERSION",
    ],
)
VERSION = os.getenv("VERSION")
OS = os.getenv("TARGET").lower()
TEST_DIR = Path(__file__).parent.absolute()
BRANCH_TO_TEST = "2.2.x"
DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-10-c8s:c8s"
IMAGE_TAG = "postgresql:10"
PSQL_VERSION = "10"
if VERSION in ("3.11", "3.12", "3.12-minimal"):
    BRANCH_TO_TEST = "4.2.x"
    DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-12-c8s"
    IMAGE_TAG = "postgresql:12"
    PSQL_VERSION = "12"

COMMON_WEB_APPS = [
    TEST_DIR / f"{x}-test-app"
    for x in [
        "gunicorn-config-different-port",
        "gunicorn-different-port",
        "django-different-port",
        "standalone",
        "setup",
        "setup-requirements",
        "django",
        "numpy",
        "app-home",
        "locale",
        "pipenv",
        "app-module",
        "pyuwsgi-pipenv",
        "micropipenv",
        "standalone-custom-pypi-index",
        "gunicorn-python-configfile-different-port",
    ]
]
FULL_WEB_APPS = [
    TEST_DIR / f"{x}-test-app"
    for x in [
        "setup-cfg",
        "npm-virtualenv-uwsgi",
        "mod-wsgi",
        "pin-pipenv-version",
        "micropipenv-requirements",
        "poetry-src-layout",
    ]
]
SHOULD_FAIL_WEB_APPS = [
    TEST_DIR / "pipenv-and-micropipenv-should-fail-test-app",
]

MINIMAL_WEB_APPS: list[Path] = []
if "minimal" in VERSION:
    WEB_APPS = COMMON_WEB_APPS
else:
    WEB_APPS = COMMON_WEB_APPS + FULL_WEB_APPS

VARS = Vars(
    OS=OS,
    VERSION=VERSION,
    IMAGE_NAME=os.getenv("IMAGE_NAME"),
    IS_MINIMAL="minimal" in VERSION,
    VERSION_NO_MINIMAL=VERSION.replace("-minimal", ""),
    SHORT_VERSION=VERSION.replace("-minimal", "").replace(".", ""),
    TAG=TAGS.get(OS),
    TEST_DIR=TEST_DIR,
    WEB_APPS=WEB_APPS,
    SHOULD_FAIL_WEB_APPS=SHOULD_FAIL_WEB_APPS,
    BRANCH_TO_TEST=BRANCH_TO_TEST,
    DEPLOYED_PSQL_IMAGE=DEPLOYED_PSQL_IMAGE,
    IMAGE_TAG=IMAGE_TAG,
    PSQL_VERSION=PSQL_VERSION,
)


def skip_helm_charts_tests():
    if VARS.VERSION in ("3.9-minimal", "3.11-minimal") or (
        VARS.VERSION == "3.12-minimal" and VARS.OS == "rhel8"
    ):
        skip(f"Skipping Helm Charts tests for {VARS.VERSION} on {VARS.OS}.")
