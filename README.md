# url_toolbox

URL Toolbox (UTBox) is a set of building blocks for Splunk that are specially created for URL manipulation. UTBox is modular, easy to use, and easy to deploy in any Splunk environment.

One of the core features of UTBox is to parse URLs and complicated top-level domains (TLDs) correctly, using the Mozilla Suffix List. Other functions are also available, such as Shannon entropy, character counting, suites, meaning ratio, Bayesian analysis, and Levenshtein distance.

UTBox was first created for security analysts, but it fits other needs because it is a set of building blocks. Each lookup ships with a macro to make it easier to use. UTBox only needs to be deployed on Splunk search heads. The knowledge bundles are sent to your indexers automatically.

[Read about this app on the Splunk Blogs](https://www.splunk.com/en_us/blog/security/ut-parsing-domains-like-house-slytherin.html).

## Getting Started

To install and run this app, download the latest compiled application directly from the releases page.

:package: [Download the latest release here](https://github.com/splunk-platform-apps/url_toolbox/releases)

Once downloaded, installation instructions can be found in the provided [documentation](https://splunk-platform-apps.github.io/url_toolbox/).

## Useful Links

:books: [Documentation](https://splunk-platform-apps.github.io/url_toolbox/)<br/>
:writing_hand: [Release Notes](./CHANGELOG.md)<br/>
:balance_scale: [License](./LICENSE)

:gear: [Development Guidelines](https://github.com/splunk-platform-apps/.github/blob/main/documentation/DEV_GUIDELINES.md#getting-started)<br/>
:heart_on_fire: [Contributing Guidelines](https://github.com/splunk-platform-apps/.github/blob/main/.github/CONTRIBUTING.md)

## Installation

Install the app on the search tier of your deployment. You can install it in Splunk Enterprise and in Splunk Cloud Platform. For supported versions, see the app on [Splunkbase](https://splunkbase.splunk.com/app/2734/).

- **Splunkbase:** in Splunk Web, go to **Apps > Find More Apps**, search for URL Toolbox, and install it.
- **Package file:** if you need a specific version, or you want to inspect the package before you install it, download it from the releases page. Then follow the Splunk documentation to [install the app](https://docs.splunk.com/Documentation/AddOns/released/Overview/Installingadd-ons) on your platform.

The app ID is `utbox`. Installing a new version over an existing one keeps your `local` customizations.

## Usage

The app provides one macro for each bundled lookup. The arguments are the fields in your events that hold the value to analyze.

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

For example, to split a URL into its parts:

```
| makeresults count=1
| eval url="https://splunk.com"
| `ut_parse_simple(url)`
```

For the full list of fields, more examples, and sample output, see the [documentation](https://splunk-platform-apps.github.io/url_toolbox/). The original product guide is also available as a [PDF](utbox/appserver/static/documentation.pdf).

## Troubleshooting

The lookup scripts log errors to the `_internal` index. To find them, run:

```
index=_internal ERROR *bin/ut_*py
```

## Development

- Run the unit tests with `make test`.
- Start a local Splunk instance with the app mounted by running `docker compose up`.
- Create a package for local checks with `make package`. The release package is built by the repository pipelines.

## Acknowledgments

* Cedric Le Roux
* [Ian Forrest](https://github.com/iforrest)
* [Daniel Federschmidt](https://github.com/dfederschmidt)
* [Mayur Pipaliya](https://github.com/mayurah)
* [Gurkan Gokdemir](https://github.com/ggokdemir)
