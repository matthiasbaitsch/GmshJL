all: docs sourcecode

docs:
	jupyter-book build doc
	/opt/homebrew/Caskroom/miniforge/base/envs/py39/bin/ghp-import -n -p -f doc/_build/html

sourcecode:
	mkdir -p dist/gmshjl
	cp doc/*.ipynb src-demo/*.jl dist/gmshjl
	cd dist && zip -r gmshjl.zip gmshjl

clean:
	rm -rf dist doc/_build



