all: Subspace.html

Subspace.html: elm-runtime.js Starfield.elm Subspace.elm
	elm --make -r elm-runtime.js Subspace.elm

clean:
	rm -rf Subspace.html
