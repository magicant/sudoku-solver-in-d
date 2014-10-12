import std.format : FormatException, formattedRead;
import std.stdio : File;
import board : Board, N, Number;

/** Throws: FormatException, StdioExceptiono, UnicodeException */
void parseLine(File input, out Number[N] ns) {
    foreach (j; 0 .. N) {
        uint n;
        if (input.readf(" %s", &n) != 1)
            throw new FormatException();
        --n;
        ns[j] = n < N ? n : N;
    }
}

/** Throws: FormatException, StdioExceptiono, UnicodeException */
Board!Number readBoard(File input) {
    auto board = new Board!Number();
    foreach (i; 0 .. N)
        parseLine(input, board.values[i]);
    return board;
}

void write(File output, in Board!Number board) {
    foreach (i; 0 .. N) {
        foreach (j; 0 .. N) {
            auto n = board.values[i][j];
            output.writef("%s ", cast(uint) (n < N ? n + 1 : 0));
        }
        output.writeln();
    }
}

// vim: set et sw=4:
