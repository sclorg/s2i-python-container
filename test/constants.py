TAGS = {
    "rhel8": "-ubi8",
    "rhel9": "-ubi9",
    "rhel10": "-ubi10",
}

BRANCH_TO_TEST = "master"


def is_test_allowed(os: str, version: str):
    if os == "rhel8" and version == "3.12-minimal":
        return False
    if version == "3.9-minimal" or version == "3.11-minimal":
        return False
    return True
