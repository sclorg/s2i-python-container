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
OS = os.getenv("OS")

BRANCH_TO_TEST = "master"
DEPLOYED_PSQL_IMAGE = "quay.io/centos7/postgresql-10-centos7:centos7"
IMAGE_TAG = "postgresql:10"
PSQL_VERSION = "10"

if VERSION == "3.11" or VERSION == "3.12":
    BRANCH_TO_TEST = "4.2.x"
    DEPLOYED_PSQL_IMAGE = "quay.io/sclorg/postgresql-12-c8s"
    IMAGE_TAG = "postgresql:12"
    PSQL_VERSION = "12"


TAGS = {
    "rhel8": "-ubi8",
    "rhel9": "-ubi9"
}

TAG = TAGS.get(OS, None)


# Replacement with 'test_python_s2i_templates'
class TestImagestreamsQuickstart:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix="python-testing", version=VERSION)
        assert self.oc_api.upload_image(DEPLOYED_PSQL_IMAGE, IMAGE_TAG)

    def teardown_method(self):
        self.oc_api.delete_project()

    @pytest.mark.parametrize(
        "template",
        [
            "django.json",
            "django-postgresql-persistent.json"
        ]
    )
    def test_python_template_inside_cluster(self, template):
        service_name = "python-testing"
        template_url = self.oc_api.get_raw_url_for_json(
            container="django-ex", dir="openshift/templates", filename=template, branch=BRANCH_TO_TEST
        )
        openshift_args = [
            f"SOURCE_REPOSITORY_REF={BRANCH_TO_TEST}",
            f"PYTHON_VERSION={VERSION}",
            f"NAME={service_name}"
        ]
        if template != "django.json":
            openshift_args = [
                f"SOURCE_REPOSITORY_REF={BRANCH_TO_TEST}",
                f"POSTGRESQL_VERSION={PSQL_VERSION}",
                f"PYTHON_VERSION={VERSION}",
                f"NAME={service_name}",
                f"DATABASE_USER=testu",
                f"DATABASE_PASSWORD=testp"
            ]
        assert self.oc_api.imagestream_quickstart(
            imagestream_file="imagestreams/python-rhel.json",
            template_file=template_url,
            image_name=IMAGE_NAME,
            name_in_template="python",
            openshift_args=openshift_args
        )
        assert self.oc_api.template_deployed(name_in_template=service_name)
        assert self.oc_api.check_response_inside_cluster(
            name_in_template=service_name, expected_output="Welcome to your Django application on OpenShift"
        )
