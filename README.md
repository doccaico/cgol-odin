## Simple Conway's Game of Life

[Play](https://doccaico.github.io/cgol-odin/)

### User guide
- [R] randomize
- [P] pause and unpause
- [W] speed up
- [S] speed down
- [A] change ALIVE color (Random)
- [D] change DEAD color (Random)

### Desktop Build
```sh
# build
$ build_desktop.bat
# run
$ build\game_desktop.exe

# build and run in one line
$ call build_desktop.bat && build\game_desktop.exe

# debug build
$ build_desktop.bat --debug

# check
$ build_desktop.bat --check

# release build
$ build_desktop.bat --release
```
### Web Build
```sh
# build
$ build_web.bat
# go to localhost:8000 in your browser
$ python -m http.server

# release build
$ build_web.bat --release
```
