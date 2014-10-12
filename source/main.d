int main() {
    import std.stdio : stdin, stdout;
    import board : Board, Number;
    import io : readBoard, write;
    import solver : iterateSolutions;

    auto board = stdin.readBoard();

    ulong solutions = 0;
    iterateSolutions(
            board,
            (Board!Number solution) {
                ++solutions;
                stdout.writefln("Solution %s:", solutions);
                write(stdout, solution);
            });
    return !(solutions > 0);
}

// vim: set et sw=4:
