import os
import sys

import pytest
from packaging.version import Version

from container_ci_suite.openshift import OpenShiftAPI

from conftest import VARS

BRANCH_TO_TEST = "2.2.x"
if Version(VARS.VERSION_NO_MINIMAL) >= Version("3.11"):
    BRANCH_TO_TEST = "4.2.x"

# Replacement with 'test_python_s2i_app_ex'
class TestPythonExTemplate:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix=f"python-{VARS.SHORT_VERSION}-test", version=VARS.VERSION_NO_MINIMAL, shared_cluster=True)

    def teardown_method(self):
        self.oc_api.delete_project()

    def test_python_ex_template_inside_cluster(self):
        service_name = f"python-{VARS.SHORT_VERSION}-test"
        assert self.oc_api.deploy_s2i_app(
            image_name=VARS.IMAGE_NAME, app=f"https://github.com/sclorg/django-ex.git#{BRANCH_TO_TEST}",
            context=".",
            service_name=service_name
        )
        assert self.oc_api.is_template_deployed(name_in_template=service_name)
        assert self.oc_api.check_response_inside_cluster(
            name_in_template=service_name, expected_output="Welcome to your Django application on OpenShift"
        )
