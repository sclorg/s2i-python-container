import os
import sys

import pytest

from container_ci_suite.openshift import OpenShiftAPI
from container_ci_suite.utils import check_variables

if not check_variables():
    print("At least one variable from IMAGE_NAME, OS, VERSION is missing.")
    sys.exit(1)

VERSION = os.getenv("VERSION")
IMAGE_NAME = os.getenv("IMAGE_NAME")
OS = os.getenv("TARGET")


# Replacement with 'test_python_s2i_app_ex_standalone'
class TestPythonExTemplate:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix="python-testing", version=VERSION, shared_cluster=True)

    def teardown_method(self):
        self.oc_api.delete_project()

    def test_python_ex_template_inside_cluster(self):
        service_name = "python-testing"
        assert self.oc_api.deploy_s2i_app(
            image_name=IMAGE_NAME, app="https://github.com/sclorg/s2i-python-container.git",
            context="examples/standalone-test-app",
            service_name=service_name
        )
        assert self.oc_api.template_deployed(name_in_template=service_name)
        assert self.oc_api.check_response_inside_cluster(
            name_in_template=service_name, expected_output="Hello World from standalone WSGI application!"
        )
