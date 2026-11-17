
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.9.5] - 2026-11-17

### Changed
- Declare `python.required = 3.13` on all 8 external lookups, so the Python interpreter is explicit. Lookup results are unchanged.
- The project moved from `splunk/utbox` to `splunk-platform-apps/url_toolbox` with its full commit history. The app ID is still `utbox`.
- The app source moved from `utbox/` to `package/`, and the repository follows the organization structure and pipelines.
- The documentation is in `docs/readme.md`. It replaces the PDF product guide.
- The Python code follows the organization ruff configuration. This is a formatting and style change only.

### Fixed
- Remove a stray `print()` in `ut_presets.py` that wrote to the standard output inside an external lookup.
- Use raw strings for four regular expressions to avoid invalid escape sequence warnings on newer Python versions.

### Added
- `app.manifest`, and navigation links to the documentation and the issue tracker.
- Unit tests with pytest, and a smoke test that runs all lookups and macros on a Splunk instance.

### Removed
- The PDF product guide and the CI job that used the AppInspect API with stale credentials.
