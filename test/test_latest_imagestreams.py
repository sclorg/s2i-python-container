from container_ci_suite.imagestreams import ImageStreamChecker

from conftest import VARS


# Replacement with 'test_latest_imagestreams'
class TestLatestImagestreams:

    def setup_method(self):
        self.isc = ImageStreamChecker(working_dir=VARS.TEST_DIR.parent.parent)

    def test_latest_imagestream(self):
        self.latest_version = self.isc.get_latest_version()
        assert self.latest_version != ""
        self.isc.check_imagestreams(self.latest_version)
