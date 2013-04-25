all: main.html

main.html: Starfield.elm main.elm
	elm --make -r elm-runtime-0.7.1.1.js main.elm
