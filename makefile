all: Subspace.html

# Subspace.html: elm-runtime.js Starfield.elm Subspace.elm
# 	elm --make -r elm-runtime.js Subspace.elm

Subspace.html: elm-runtime.js Subspace.elm
	elm --make -r elm-runtime.js Subspace.elm

test.html: elm-runtime.js test.elm
	elm --make -r elm-runtime.js test.elm

clean:
	rm -rf Subspace.html
