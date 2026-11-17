import pytest
import ut_parse_lib


@pytest.mark.parametrize("list_name", ["mozilla", "iana", "custom"])
def test_parse_extended(list_name):
    domain = "http://www.example.com/123/123.php"
    tld_list = ut_parse_lib.loadTLDFile(list_name)
    parse_result = ut_parse_lib.parse_extended(domain, tld_list)
    assert parse_result["ut_domain"] == "example.com"
