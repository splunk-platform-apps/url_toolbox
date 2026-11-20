
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.9.5] - 2026-11-17

### Changed
- Declare `python.required = 3.13` on all 8 external lookups, so the Python interpreter is explicit. Lookup results are unchanged.
- The project moved from `splunk/utbox` to `splunk-platform-apps/url_toolbox` with its full commit history, and follows the organization structure and pipelines. The app ID is still `utbox`.
- The documentation is in `docs/readme.md`. It replaces the PDF product guide.

### Fixed
- Remove a stray `print()` in `ut_presets.py` that wrote to the standard output inside an external lookup. In 1.9.4 and earlier, `ut_suites` wrote each preset name of its `set` argument into the lookup output between the CSV rows. Nothing should depend on that output; lookup results are otherwise unchanged.
- Use raw strings for four regular expressions to avoid invalid escape sequence warnings on newer Python versions.

### Added
- `app.manifest`.
- Unit tests with pytest, and a smoke test that runs all lookups and macros on a Splunk instance.
