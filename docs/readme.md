# URL Toolbox

URL Toolbox (UTBox) is a set of building blocks for Splunk that are specially created for URL manipulation. It is a search-time app with no user interface. It bundles eight external lookups, each with a macro that makes it easier to use. The lookup scripts run on Python 3.

## Features

- Parses URLs correctly, including complicated top-level domains (TLDs), using the Mozilla Suffix List.
- Provides other building blocks, such as Shannon entropy, character counting, suites, meaning ratio, Bayesian analysis, and Levenshtein distance.
- Ships one macro for each lookup.
- Needs to be deployed on search heads only. The knowledge bundles are sent to your indexers automatically.

## Getting Started

> Building blocks for URL manipulation in Splunk.

### Requirements

- Splunk Enterprise or Splunk Cloud Platform. For supported versions, see the app on [Splunkbase](https://splunkbase.splunk.com/app/2734/).

### Installation

Install the app on the search tier of your deployment.

- **Splunkbase:** in Splunk Web, go to **Apps > Find More Apps**, search for URL Toolbox, and install it.
- **Package file:** if you need a specific version, or you want to inspect the package before you install it, download it from the [releases page](https://github.com/splunk-platform-apps/url_toolbox/releases). Then follow the Splunk documentation to [install the app](https://docs.splunk.com/Documentation/AddOns/released/Overview/Installingadd-ons) on your platform.

The app ID is `utbox`. Installing a new version over an existing one keeps your `local` customizations.

### Usage

The app provides one macro for each lookup. The arguments are the fields in your events that hold the value to analyze.

| Macro | Result fields |
| --- | --- |
| `ut_parse_simple(url)` | Splits a URL into `ut_scheme`, `ut_netloc`, `ut_path`, `ut_params`, `ut_query`, and `ut_fragment`. |
| `ut_parse(url, list)` | Parses a URL into its parts and also returns the domain, subdomain, and TLD. It uses the suffix lists. It is a shortcut for `ut_parse_extended(url, list)`. |
| `ut_shannon(word)` | Returns `ut_shannon`, the Shannon entropy of the value. |
| `ut_countset(word, set)` | Returns `ut_countset`, the total and per-character counts of the characters in `set`. The set can be a preset such as `@digits@`, `@alpha@`, or `@hexa@`, `@word@` for the letters of the value itself, or a list of characters. |
| `ut_suites(word, set)` | Returns `ut_suites`, the length of the longest run of consecutive characters for each preset in `set`, such as `@digits@,@alpha@`. |
| `ut_meaning(word)` | Returns `ut_meaning_ratio`, the ratio between the length of the known words found in the value and the length of the value. |
| `ut_bayesian(word)` | Returns `ut_bayesian`, a naive Bayesian score of the probability that a domain is malicious, based on its 2-grams. |
| `ut_levenshtein(w1, w2)` | Returns `ut_levenshtein`, the Levenshtein distance between the two values. |

The original product guide is available as a [PDF](https://github.com/splunk-platform-apps/url_toolbox/blob/main/utbox/appserver/static/documentation.pdf).

## Troubleshooting

The lookup scripts log errors to the `_internal` index. To find them, run:

```
index=_internal ERROR *bin/ut_*py
```

## Examples

### ut_parse_simple

```
| makeresults count=1
| eval url="https://www.splunk.com/en_us/blog/security/ut-parsing-domains-like-house-slytherin.html"
| `ut_parse_simple(url)`
```

| url | ut_scheme | ut_netloc | ut_path | ut_params | ut_query | ut_fragment |
| --- | --- | --- | --- | --- | --- | --- |
| https://www.splunk.com/en_us/blog/security/ut-parsing-domains-like-house-slytherin.html | https | www.splunk.com | /en_us/blog/security/ut-parsing-domains-like-house-slytherin.html | None | None | None |

### ut_parse

```
| makeresults count=1
| eval url="https://www.splunk.com/en_us/blog/security/ut-parsing-domains-like-house-slytherin.html", list="*"
| `ut_parse(url, list)`
```

| url | ut_domain | ut_domain_without_tld | ut_netloc | ut_scheme | ut_subdomain | ut_subdomain_count | ut_subdomain_level_1 | ut_tld |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| https://www.splunk.com/en_us/blog/security/ut-parsing-domains-like-house-slytherin.html | splunk.com | splunk | www.splunk.com | https | www | 1 | www | com |

The output also includes the `ut_path`, `ut_params`, `ut_query`, `ut_fragment`, and `ut_port` fields. The first four are the same as the fields returned by `ut_parse_simple`.

### ut_shannon

```
| makeresults count=1
| eval word="buttercup"
| `ut_shannon(word)`
```

| word | ut_shannon |
| --- | --- |
| buttercup | 2.725480556997868 |

### ut_countset

```
| makeresults count=1
| eval word="buttercup", set="tu"
| `ut_countset(word, set)`
```

| word | set | ut_countset |
| --- | --- | --- |
| buttercup | tu | {"ut_countset": {"sum": 4, "74": 2, "75": 2}} |

## Tests

Run the unit tests from the root of the repository:

```
make test
```

To get a local Splunk environment with the app mounted, run `docker compose up`.

## Versions Supported

For the supported Splunk versions, see the app on [Splunkbase](https://splunkbase.splunk.com/app/2734/).

## Credits & Acknowledgements

* Cedric Le Roux
* [Ian Forrest](https://github.com/iforrest)
* [Daniel Federschmidt](https://github.com/dfederschmidt)
* [Mayur Pipaliya](https://github.com/mayurah)
* [Gurkan Gokdemir](https://github.com/ggokdemir)

## References

- [URL Toolbox on Splunkbase](https://splunkbase.splunk.com/app/2734/)
- [Parsing domains like House Slytherin (Splunk Blogs)](https://www.splunk.com/en_us/blog/security/ut-parsing-domains-like-house-slytherin.html)

## Contributing
See the [CONTRIBUTING.md](https://github.com/splunk-platform-apps/.github/blob/main/.github/CONTRIBUTING.md) file for details.
