.PHONY: package test

package:
	rm -rf dist/utbox
	mkdir -p dist/utbox
	rsync -a --exclude='__pycache__' --exclude='*.pyc' --exclude='/local' --exclude='/metadata/local.meta' package/ dist/utbox/
	COPYFILE_DISABLE=1 tar -C dist -czf dist/utbox.tar.gz utbox

test:
	python -m pytest tests
