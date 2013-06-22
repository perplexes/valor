all: Subspace.js

ELM_VERSION=0.8.0.3

elm-runtime.js:
	cp ~/.cabal/share/Elm-${ELM_VERSION}/elm-runtime.js .

Subspace.js: elm-runtime.js Starfield.elm Subspace.elm
	elm --make --only-js -r /elm-runtime.js Subspace.elm

server:
	elm-server --runtime-location=/elm-runtime.js

watch:
	fswatch . 'make Subspace.html'

test.html: elm-runtime.js test.elm
	elm --make -r elm-runtime.js test.elm

clean:
	rm -rf *.html *.js
