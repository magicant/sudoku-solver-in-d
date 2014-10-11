import std.conv : to;
import board : Board, Number, Position, PossibilitySet;
import board : blockArea, columnArea, rowArea, wholeArea;

void eliminateImpossibilities(Board!PossibilitySet board, Position p) {
    if (!board[p].unique)
        return;

    auto n = board[p].uniqueValue;

    foreach (p2; rowArea(p))
        board[p2] = board[p2].remove(n);
    foreach (p2; columnArea(p))
        board[p2] = board[p2].remove(n);
    foreach (p2; blockArea(p))
        board[p2] = board[p2].remove(n);

    board[p] = PossibilitySet().add(n);
}

unittest {
    auto board = new Board!PossibilitySet();
    auto p = Position();
    board[p] = PossibilitySet().add(0).add(3);
    auto oldBoard = board.dup;
    eliminateImpossibilities(board, p);
    assert(board == oldBoard, "Non-unique position has no effect");
}
unittest {
    auto board = new Board!PossibilitySet();
    auto position = Position(2, 4);
    auto area = blockArea(position);
    auto n = Number(6);

    foreach (Position p; wholeArea)
        board[p] = PossibilitySet.full;
    board[position] = PossibilitySet().add(n);

    eliminateImpossibilities(board, position);

    foreach (Position p; wholeArea) {
        if (p == position)
            assert(board[p].uniqueValue == n);
        else if (p.i == position.i || p.j == position.j || area.contains(p))
            assert(!board[p][n],
                    "Position " ~ to!string(p) ~ " should not contain " ~
                    to!string(n));
        else
            assert(board[p] == PossibilitySet.full,
                    "Position " ~ to!string(p) ~ " should be full");
    }
}

void eliminateImpossibilities(Board!PossibilitySet board) {
    foreach (Position p; wholeArea)
        eliminateImpossibilities(board, p);
}

// vim: set et sw=4:
