# URL Toolbox

URL Toolbox (UTBox) is a set of building blocks for Splunk that are specially created for URL manipulation. It is a search-time app with no user interface. It bundles eight external lookups, each with a macro that makes it easier to use. The lookups declare `python.required = 3.13`.

## Features

- Parses URLs correctly, including complicated top-level domains (TLDs), using the Mozilla Suffix List.
- Provides other building blocks, such as Shannon entropy, character counting, suites, meaning ratio, Bayesian analysis, and Levenshtein distance.
- Ships one macro for each lookup.
- Needs to be deployed on search heads only. The knowledge bundles are sent to your indexers automatically.

## Getting Started

> Building blocks for URL manipulation in Splunk.

### Requirements

- Splunk Enterprise or Splunk Cloud Platform. The lookups declare Python 3.13, so use a Splunk version that provides it. See [Versions Supported](#versions-supported).

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
| `ut_countset(word, set)` | Returns `ut_countset`, the total and per-character counts of the characters in `set`. |
| `ut_suites(word, set)` | Returns `ut_max_suite_<preset>`, the length of the longest run of consecutive characters for each preset in `set`. |
| `ut_meaning(word)` | Returns `ut_meaning_ratio`, the ratio between the length of the known words found in the value and the length of the value. |
| `ut_bayesian(word)` | Returns `ut_bayesian`, a naive Bayesian score of the probability that a domain is malicious, based on its 2-grams. |
| `ut_levenshtein(w1, w2)` | Returns `ut_levenshtein`, the Levenshtein distance between the two values. |

#### Call a lookup or a macro

A generic lookup call in Splunk has this format:

```
... | lookup <lookup_name> field AS <field>
```

For example:

```
... | lookup ut_parse_simple_lookup url AS cs_uri
```

UTBox also provides a macro for each lookup. The macro for the previous example is:

```
... | `ut_parse_simple(cs_uri)`
```

The macros are shortcuts to the lookup calls. You can use either one.

#### URL syntax

The syntax of a URL is:

```
scheme://[user:password@]domain:port/path?query_string#fragment_id
```

- The scheme defines how the resource is obtained. In many cases it is the name of a protocol, but not always. Examples are `http`, `https`, `ftp`, and `file`.
- The domain name, or a numeric IP address, gives the destination location.
- The port number is optional. If it is omitted, the default for the scheme is used, such as 80 for `http` and 443 for `https`.
- The path specifies the resource that is requested.
- The query string contains data to pass to the software that runs on the server. It can contain name and value pairs that are separated by ampersands, such as `?first_name=John&last_name=Doe`.
- The fragment identifier, if present, specifies a part or a position within the resource or document.

Source: [Uniform Resource Locator on Wikipedia](https://en.wikipedia.org/wiki/Uniform_resource_locator).

#### ut_parse_simple

`ut_parse_simple(url)` parses the URL with the Python `urlparse()` function. It returns the fields `ut_scheme`, `ut_netloc`, `ut_path`, `ut_params`, `ut_query`, and `ut_fragment`. A field is set to `None` when it has no value.

If the parsing fails, the app writes a log entry. See [Troubleshooting](#troubleshooting).

#### ut_parse and ut_parse_extended

`ut_parse(url, list)` and `ut_parse_extended(url, list)` are the extended version of `ut_parse_simple`. They use a list of suffixes to return these additional fields: `ut_port`, `ut_domain`, `ut_tld`, `ut_domain_without_tld`, `ut_subdomain`, `ut_subdomain_count`, and `ut_subdomain_parts`.

- All fields are set to `None` when they have no value, except `ut_port`, which is set to 80, and `ut_subdomain_count`, which is set to 0.
- The `ut_subdomain_parts` field contains JSON data. The macro expands it with the `spath` command into the fields `ut_subdomain_level_1`, `ut_subdomain_level_2`, and so on. Level 1 is the label closest to the domain. The macro then drops `ut_subdomain_parts`.

The `list` argument selects the suffix list:

| Value | List |
| --- | --- |
| `iana` | The IANA top-level domain list. It has entries such as `uk`, but not `co.uk`. This is the default. |
| `mozilla` | The Mozilla Suffix List. It is the complete list, and has entries such as `googlecode.com` as a TLD. |
| `custom` | Your own list. |
| `*` | All three lists together. |

You set the `list` argument with an `eval` command, as in this example:

```
... | fields cs_url | eval list = "iana" | `ut_parse(cs_url, list)`
```

To edit the custom list, add or remove entries in `$SPLUNK_HOME/etc/apps/utbox/bin/suffix_list_custom.dat`. Use one TLD per line, in lowercase and in punycode format, such as `xn--...`. Lines that start with `#` are comments. An app upgrade replaces the files in `bin`, so keep a copy of your changes.

If the parsing fails, the app writes a log entry. See [Troubleshooting](#troubleshooting).

#### ut_shannon

`ut_shannon(word)` returns the Shannon entropy of the value in the `ut_shannon` field.

#### ut_countset

`ut_countset(word, set)` returns the number of occurrences of each character of `set` in the value. The result is in the `ut_countset` field, as JSON. Each character is a key in hexadecimal, such as `2E` for the dot. The `sum` key is the total of the counted characters.

The `set` argument is free-form text, but you can also use a [preset](#presets). For example, these two commands count the same characters:

```
... | eval set="0123456789abcdefABCDEF" | `ut_countset(word, set)`
... | eval set="@hexa_all@" | `ut_countset(word, set)`
```

To ignore the case of the value, use the `lower()` function of the `eval` command:

```
... | eval set="@word@" | eval field_lowered=lower(field) | lookup ut_countset_lookup word AS field_lowered set
```

To read the counters, use the `spath` command. For example, to count the dots in the field `countme`:

```
... | eval countme="a.b.c.domain.tld", set="." | `ut_countset(countme, set)` | spath input=ut_countset | rename ut_countset.sum AS n_dots | fields - ut_countset*
```

This example uses the `sum` key because it counts one character only. To count a larger set, read the counter of an individual character. The key is the character in hexadecimal, such as `ut_countset.2E` for the dot.

#### ut_suites

`ut_suites(word, set)` returns the length of the longest suite, which is a run of consecutive characters, for each preset in `set`. Separate several presets with commas. The result fields are named `ut_max_suite_` followed by the preset name without the `@` characters. The macro expands the JSON with the `spath` command and drops the `ut_suites` field.

For example, to get the longest suites of digits, vowels, and consonants:

```
... | eval set="@digits@,@vowels@,@consonants@" | `ut_suites(word, set)`
```

This returns the fields `ut_max_suite_digits`, `ut_max_suite_vowels`, and `ut_max_suite_consonants`. Some presets have no meaning for suites, such as `@word@`.

#### ut_meaning

`ut_meaning(word)` returns a ratio between the length of the value and the length of the words that compose it, based on a dictionary in the `bin` directory of the app. For example, the word `microsoft` has a ratio of 1, because it is composed of the words `micro` and `soft`, which are in the dictionary. If `soft` were not in the dictionary, the ratio would drop to 0.56, which is `len(micro)` divided by `len(microsoft)`, or 5 divided by 9. This helps to identify domains that are generated by algorithms (DGA).

#### ut_bayesian

`ut_bayesian(word)` studies the distribution of bigrams in two lists of domain names, and computes the probability that an input domain is a bad one, based on the bigrams that compose it. This helps to identify DGA domains. The lists, `bayesian_good.dic` and `bayesian_bad.dic`, are in the `bin` directory of the app. According to the original product guide, the bad list came from malwaredomainlist.com and the good list came from alexa.com.

#### ut_levenshtein

`ut_levenshtein(w1, w2)` returns the Levenshtein distance between the two values in the `ut_levenshtein` field.

#### Presets

The `set` argument of `ut_countset` and `ut_suites` accepts these presets. The names ending in `_up` contain uppercase characters, and the names ending in `_all` contain both lowercase and uppercase characters.

| Preset | Characters |
| --- | --- |
| `@digits@` | `0` to `9`, and `: ; < = > ?` |
| `@alpha@`, `@alpha_up@`, `@alpha_all@` | Letters `a` to `z`, `A` to `Z`, or both. |
| `@alphanum@`, `@alphanum_up@`, `@alphanum_all@` | The letters, plus the characters of `@digits@`. |
| `@hexa@`, `@hexa_up@`, `@hexa_all@` | The characters of `@digits@`, plus `a` to `f`, `A` to `F`, or both. |
| `@base64@` | The characters of `@alphanum_all@`, plus `+ / =`. |
| `@vowels@`, `@vowels_up@`, `@vowels_all@` | The vowels `a e i o u y`, in lowercase, uppercase, or both. |
| `@consonants@` | The lowercase consonants `b c d f g h j k l m n p q r s t v w x z`. |
| `@consonants_up@` | The 26 lowercase letters `a` to `z`. |
| `@consonants_all@` | The same characters as `@consonants@`. |
| `@noalpha@` | The printable ASCII characters (0x20 to 0x7E) without the letters. |
| `@punct@` | The printable ASCII characters without the letters and without the characters of `@digits@`. |
| `@typo@` | `& * @ \ ^ # % ~ _ \|` |
| `@word@` | Only the characters that are in the submitted value. Available for `ut_countset` only. |

> [!NOTE]
> The presets that contain digits also contain `: ; < = > ?`, because the digit set spans the ASCII range 0x30 to 0x3F. The presets `@consonants_up@` and `@consonants_all@` do not contain the uppercase consonants. These are known behaviors of the current version and are kept for compatibility.

## Troubleshooting

The lookup scripts write errors to `$SPLUNK_HOME/var/log/splunk/utbox.log`. They also log to the `_internal` index. To find the errors, run:

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
| eval url="https://a.b.example.co.uk/x", list="mozilla"
| `ut_parse(url, list)`
```

| ut_domain | ut_tld | ut_subdomain | ut_subdomain_count | ut_subdomain_level_1 | ut_subdomain_level_2 |
| --- | --- | --- | --- | --- | --- |
| example.co.uk | co.uk | a.b | 2 | b | a |

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

### ut_suites

```
| makeresults count=1
| eval word="abc123xyz", set="@digits@,@vowels@,@consonants@"
| `ut_suites(word, set)`
```

| word | ut_max_suite_digits | ut_max_suite_vowels | ut_max_suite_consonants |
| --- | --- | --- | --- |
| abc123xyz | 3 | 1 | 2 |

### ut_meaning

```
| makeresults count=1
| eval word="microxyze"
| `ut_meaning(word)`
```

| word | ut_meaning_ratio |
| --- | --- |
| microxyze | 0.5555555555555556 |

### ut_levenshtein

```
| makeresults count=1
| eval a="kitten", b="sitting"
| `ut_levenshtein(a, b)`
```

| a | b | ut_levenshtein |
| --- | --- | --- |
| kitten | sitting | 3 |

## Tests

Run the unit tests from the root of the repository:

```
make test
```

To get a local Splunk environment with the app mounted, run `docker compose up`.

To check all the lookups and macros on a Splunk instance that has the app installed, run the smoke test. It reads the connection settings from `SPLUNK_HOST`, `SPLUNK_USER`, and `SPLUNK_PASSWORD`:

```
./tests/splunk_smoke.sh
```

## Versions Supported

The app 1.9.5 was tested with an in-place upgrade from 1.9.3, and with all lookups returning identical results, on Splunk Enterprise 10.6.1.1 and 10.7.0.0. For other versions, see the app on [Splunkbase](https://splunkbase.splunk.com/app/2734/).

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
