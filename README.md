sudoku-solver-in-d
==================

A simple sudoku solver written in D

Usage:

```
$ dub build
Building sudoku ~master configuration "application", build type debug.
Compiling using dmd...
Linking...
$ cat sample.txt
1 0 0 4 0 0 7 0 9
0 5 0 7 8 0 0 2 0
7 0 9 0 2 3 0 0 6
3 0 0 6 0 0 0 0 0
6 4 0 0 7 0 0 1 2
9 0 8 0 0 2 0 4 5
2 3 0 5 0 4 8 0 0
0 6 0 0 9 0 0 3 0
8 0 7 0 0 1 0 6 4
$ ./sudoku <sample.txt
Solution 1:
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
3 1 2 6 4 5 9 7 8
6 4 5 9 7 8 3 1 2
9 7 8 3 1 2 6 4 5
2 3 1 5 6 4 8 9 7
5 6 4 8 9 7 2 3 1
8 9 7 2 3 1 5 6 4
```
