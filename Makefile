build:
	moonp `find ./*/ *.moon -maxdepth 0 -path ./deps/ -prune -o -print`