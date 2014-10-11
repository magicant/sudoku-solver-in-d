import std.conv : to;
import board : N, Nsub;
import board : Area, Board, Number, Position, PossibilitySet;
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

/**
 * Counts the number of positions where a number can occur in the given area.
 * Makes the possibility unique if the number can occur at exactly one
 * position.
 */
void fixUniquePossibilities(Board!PossibilitySet board, in Area area) {
    struct Possibility {
        Position position;
        size_t count;
    }

    Possibility[N] possibilities;

    foreach (Position p; area) {
        foreach (n; 0 .. N) {
            if (board[p][n]) {
                possibilities[n].position = p;
                ++possibilities[n].count;
            }
        }
    }

    foreach (n, ref possibility; possibilities)
        if (possibility.count == 1)
            board[possibility.position] = PossibilitySet().add(n);
}

unittest {
    auto board = new Board!PossibilitySet();
    auto position = Position(7, 4);
    auto area = rowArea(position);
    auto n = 2;
    foreach (Position p; wholeArea)
        board[p] = PossibilitySet.full;
    foreach (Position p; area)
        board[p] = board[p].remove(n);
    board[position] = PossibilitySet.full;

    auto expectedBoard = board.dup;
    expectedBoard[position] = PossibilitySet().add(n);

    fixUniquePossibilities(board, area);
    assert(board == expectedBoard);
}

void fixUniquePossibilities(Board!PossibilitySet board) {
    foreach (n; 0 .. N) {
        fixUniquePossibilities(board, rowArea(n));
        fixUniquePossibilities(board, columnArea(n));
    }

    foreach (n; 0 .. Nsub)
        foreach (m; 0 .. Nsub)
            fixUniquePossibilities(
                    board, blockArea(Position(n * Nsub, m * Nsub)));
}

void repeatNonAssumptionProcess(Board!PossibilitySet board) {
    auto oldBoard = new Board!PossibilitySet();
    do {
        oldBoard.values = board.values;
        eliminateImpossibilities(board);
        fixUniquePossibilities(board);
    } while (board != oldBoard);
}

Position positionWithLeastPossibilities(in Board!PossibilitySet board) {
    Position position;
    size_t count = N;
    foreach (p; wholeArea) {
        auto c = board[p].count;
        if (count > c) {
            count = c;
            position = p;
        }
    }
    return position;
}

unittest {
    auto board = new Board!PossibilitySet();
    auto position = Position(7, 2);
    foreach (Position p; wholeArea)
        board[p] = PossibilitySet.full.remove(p.i).remove(p.j);
    board[position] = PossibilitySet().add(4).add(5).add(8);
    assert(positionWithLeastPossibilities(board) == position);
}
unittest {
    auto board = new Board!PossibilitySet();
    foreach (Position p; wholeArea)
        board[p] = PossibilitySet().add(p.i).add(p.j);
    auto position = positionWithLeastPossibilities(board);
    assert(position.i == position.j);
}

/**
 * Finds the position that has the least number of possible numbers and calls
 * the given delegate passing the board with the possibility set at the found
 * position replaced with a unique possibility set.
 */
void splitPossibilities(
        in Board!PossibilitySet board, void delegate(Board!PossibilitySet) d) {
    auto p = positionWithLeastPossibilities(board);
    foreach (n; 0 .. N) {
        if (board[p][n]) {
            auto newBoard = board.dup;
            newBoard[p] = PossibilitySet().add(n);
            d(newBoard);
        }
    }
}

// vim: set et sw=4:
