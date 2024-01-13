play:
	love ./src/

love:
	mkdir -p dist
	cd src && zip -r ../dist/MandelbrotFractalExplo-Shaders.love .

js: love
	love.js -c --title="Mandelbrot‘s fractal exploration (with shaders)" ./dist/MandelbrotFractalExplo-Shaders.love ./dist/js
