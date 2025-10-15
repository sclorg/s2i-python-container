from collections import namedtuple
import os
from pathlib import Path
import sys

from container_ci_suite.utils import check_variables
from pytest import skip

if not check_variables():
    sys.exit(1)

TAGS = {
    "rhel8": "-ubi8",
    "rhel9": "-ubi9",
    "rhel10": "-ubi10",
}

Vars = namedtuple("Vars", ["OS", "VERSION", "IMAGE_NAME", "IS_MINIMAL", "VERSION_NO_MINIMAL", "SHORT_VERSION", "TEST_DIR"])
VERSION = os.getenv("VERSION")
OS = os.getenv("TARGET").lower()
VARS = Vars(
    OS=OS,
    VERSION=VERSION,
    IMAGE_NAME=os.getenv("IMAGE_NAME"),
    IS_MINIMAL="minimal" in VERSION,
    VERSION_NO_MINIMAL=VERSION.replace("-minimal", ""),
    SHORT_VERSION=VERSION.replace("-minimal", "").replace(".", ""),
    TAG=TAGS.get(OS),
    TEST_DIR=Path(__file__).parent.absolute()
)


def skip_helm_charts_tests():
    if VARS.VERSION in ("3.9-minimal", "3.11-minimal") or \
           (VARS.VERSION == "3.12-minimal" and VARS.OS == "rhel8"):
        skip(f"Skipping Helm Charts tests for {VARS.VERSION} on {VARS.OS}.")
