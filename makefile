all: Subspace.js

ELM_VERSION=0.8.0.3

elm-runtime.js:
	cp ~/.cabal/share/Elm-${ELM_VERSION}/elm-runtime.js vendor/

Subspace.js: elm-runtime.js lib/Subspace.elm
	cd lib && elm --make --only-js --output-directory=../ElmFiles -s Native/Map.js -r /elm-runtime.js Subspace.elm
	cat lib/Native/Map.js >> ElmFiles/Subspace.js
	cat lib/Native/Bits.js >> ElmFiles/Subspace.js

server:
	# elm-server --runtime-location=/elm-runtime.js
	python -m SimpleHTTPServer

watch:
	fswatch . 'make Subspace.html'

test.html: elm-runtime.js test.elm
	elm --make -r elm-runtime.js test.elm

