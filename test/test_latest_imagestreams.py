import os
import sys

import pytest

from pathlib import Path

from container_ci_suite.imagestreams import ImageStreamChecker
from container_ci_suite.utils import check_variables

TEST_DIR = Path(os.path.abspath(os.path.dirname(__file__)))

if not check_variables():
    print("At least one variable from IMAGE_NAME, OS, SINGLE_VERSION is missing.")
    sys.exit(1)

VERSION = os.getenv("VERSION")


# Replacement with 'test_latest_imagestreams'
class TestLatestImagestreams:

    def setup_method(self):
        self.isc = ImageStreamChecker(working_dir=TEST_DIR.parent.parent)

    def test_latest_imagestream(self):
        self.latest_version = self.isc.get_latest_version()
        assert self.latest_version != ""
        self.isc.check_imagestreams(self.latest_version)
