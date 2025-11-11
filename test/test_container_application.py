import pytest

from container_ci_suite.container_lib import ContainerImage, ContainerTestLib
from container_ci_suite.engines.podman_wrapper import PodmanCLIWrapper

from conftest import VARS


@pytest.fixture(params=VARS.WEB_APPS, ids=[app.name for app in VARS.WEB_APPS])
def build_s2i_app(request) -> ContainerTestLib:
    """
    Build a S2I application.
    """
    container_lib = ContainerTestLib(VARS.IMAGE_NAME)
    app_name = request.param.name
    s2i_app = container_lib.build_as_df(
        app_path=request.param,
        s2i_args="--pull-policy=never",
        src_image=VARS.IMAGE_NAME,
        dst_image=f"{VARS.IMAGE_NAME}-{app_name}",
    )
    yield s2i_app
    s2i_app.cleanup()


@pytest.mark.usefixtures("build_s2i_app")
@pytest.mark.parametrize(
    "container_args",
    [
        "--user 100001",
        "--user 12345",
        "-e ENABLE_INIT_WRAPPER=true",
    ],
)
def test_application(build_s2i_app, container_args):
    """
    Test if container works
    Python version is properly set
    Application response on specific port and specific URL.

    """
    s2i_app = build_s2i_app
    cid_file_name = s2i_app.app_name
    assert s2i_app.create_container(
        cid_file_name=cid_file_name,
        container_args=container_args,
    )
    assert ContainerImage.wait_for_cid(cid_file_name=cid_file_name)
    python_version = PodmanCLIWrapper.podman_run_command_and_remove(
        cid_file_name=VARS.IMAGE_NAME, cmd="echo \\$PYTHON_VERSION"
    ).strip()
    python_version_output = PodmanCLIWrapper.podman_run_command_and_remove(
        cid_file_name=VARS.IMAGE_NAME, cmd="python --version"
    )
    assert f"Python {python_version}." in python_version_output
    cip = s2i_app.get_cip(cid_file_name=cid_file_name)
    assert cip
    port = 8080
    if "different-port" in s2i_app.app_name:
        port = 8085
    assert s2i_app.test_response(url=f"http://{cip}", port=port)


@pytest.mark.parametrize(
    "should_fail_app",
    VARS.SHOULD_FAIL_WEB_APPS,
)
def test_application_should_fail(should_fail_app):
    """
    Test if build fails for should fail apps

    """
    container_lib = ContainerTestLib(VARS.IMAGE_NAME)
    app_name = should_fail_app.name
    s2i_app_should_fail = container_lib.build_as_df(
        app_path=should_fail_app,
        s2i_args="--pull-policy=never",
        src_image=VARS.IMAGE_NAME,
        dst_image=f"{VARS.IMAGE_NAME}-{app_name}",
    )
    assert not s2i_app_should_fail
