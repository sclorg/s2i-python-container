import os
import sys

import pytest
from packaging.version import Version

from container_ci_suite.utils import check_variables
from container_ci_suite.openshift import OpenShiftAPI

if not check_variables():
    print("At least one variable from IMAGE_NAME, OS, VERSION is missing.")
    sys.exit(1)


VERSION = os.getenv("VERSION")
IMAGE_NAME = os.getenv("IMAGE_NAME")
OS = os.getenv("TARGET").lower()

BRANCH_TO_TEST = "2.2.x"
if Version(VERSION) >= Version("3.11"):
    BRANCH_TO_TEST = "4.2.x"
SHORT_VERSION = VERSION.replace(".", "")

# Replacement with 'test_python_s2i_app_ex'
class TestPythonExTemplate:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix=f"python-{SHORT_VERSION}-test", version=VERSION, shared_cluster=True)

    def teardown_method(self):
        self.oc_api.delete_project()

    def test_python_ex_template_inside_cluster(self):
        if OS == "rhel10":
            pytest.skip("Do NOT test on rhel10. It is not released yet.")
        service_name = f"python-{SHORT_VERSION}-test"
        assert self.oc_api.deploy_s2i_app(
            image_name=IMAGE_NAME, app=f"https://github.com/sclorg/django-ex.git#{BRANCH_TO_TEST}",
            context=".",
            service_name=service_name
        )
        assert self.oc_api.is_template_deployed(name_in_template=service_name)
        assert self.oc_api.check_response_inside_cluster(
            name_in_template=service_name, expected_output="Welcome to your Django application on OpenShift"
        )
