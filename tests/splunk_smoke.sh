#!/usr/bin/env bash
# shellcheck disable=SC2016  # the SPL contains backticks that must not be expanded
# Runs one search per lookup against a Splunk instance that has the app installed.
# Settings come from SPLUNK_HOST, SPLUNK_USER and SPLUNK_PASSWORD.
set -uo pipefail

SPLUNK_HOST="${SPLUNK_HOST:-https://localhost:8089}"
SPLUNK_USER="${SPLUNK_USER:-admin}"
SPLUNK_PASSWORD="${SPLUNK_PASSWORD:-password}"  # pragma: allowlist secret
failed=0

check() {
  local name="$1" spl="$2" assertion="$3" out
  out=$(curl -sk -u "${SPLUNK_USER}:${SPLUNK_PASSWORD}" "${SPLUNK_HOST}/services/search/jobs/export" \
    --data-urlencode "search=${spl}" -d output_mode=json)
  if echo "${out}" | jq -es "map(select(.result != null)) | .[0].result | ${assertion}" > /dev/null 2>&1; then
    echo "PASS ${name}"
  else
    echo "FAIL ${name}"
    echo "${out}"
    failed=1
  fi
}

check "ut_shannon_lookup" \
  '| makeresults | eval word="splunkenterprise" | lookup ut_shannon_lookup word' \
  '.ut_shannon != null'
check "ut_parse_simple_lookup" \
  '| makeresults | eval url="http://www.example.co.uk:8080/a/b.php;p?x=1&y=2#frag" | lookup ut_parse_simple_lookup url' \
  '.ut_scheme == "http" and .ut_netloc == "www.example.co.uk:8080" and .ut_path == "/a/b.php"'
check "ut_parse_extended_lookup (mozilla)" \
  '| makeresults | eval url="http://www.example.co.uk:8080/a/b.php?x=1#frag", list="mozilla" | lookup ut_parse_extended_lookup url list' \
  '.ut_domain == "example.co.uk"'
check "ut_parse_extended_lookup (iana)" \
  '| makeresults | eval url="http://mail.example.com/x", list="iana" | lookup ut_parse_extended_lookup url list' \
  '.ut_domain == "example.com"'
check "ut_meaning_lookup" \
  '| makeresults | eval word="splunk" | lookup ut_meaning_lookup word' \
  '.ut_meaning_ratio != null'
check "ut_suites_lookup" \
  '| makeresults | eval word="abc123xyz", set="@alpha@,@digits@" | lookup ut_suites_lookup word set' \
  '.ut_suites != null'
check "ut_countset_lookup" \
  '| makeresults | eval word="abc123xyz", set="@alpha@" | lookup ut_countset_lookup word set' \
  '(.ut_countset | fromjson | .ut_countset.sum) == 6'
check "ut_bayesian_lookup" \
  '| makeresults | eval word="google" | lookup ut_bayesian_lookup word' \
  '.ut_bayesian != null'
check "ut_levenshtein_lookup" \
  '| makeresults | eval word1="kitten", word2="sitting" | lookup ut_levenshtein_lookup word1 word2' \
  '(.ut_levenshtein | tostring) == "3"'
check "macro ut_parse_simple" \
  '| makeresults | eval url="https://splunk.com" | `ut_parse_simple(url)`' \
  '.ut_scheme == "https"'
check "macro ut_parse" \
  '| makeresults | eval url="https://www.splunk.com/test", list="*" | `ut_parse(url, list)`' \
  '.ut_path == "/test" and .ut_domain == "splunk.com" and .ut_subdomain_level_1 == "www"'

exit "${failed}"
