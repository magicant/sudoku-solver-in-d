alias Number = size_t;

enum Number Nsub = 3;
enum Number N = Nsub * Nsub;

struct Position {

    Number i, j;

    bool isValid() const pure {
        return i < N && j < N;
    }

    unittest {
        assert(Position(0, 0).isValid());
        assert(Position(8, 0).isValid());
        assert(Position(0, 8).isValid());
        assert(Position(8, 8).isValid());

        assert(!Position(9, 8).isValid());
        assert(!Position(8, 9).isValid());
        assert(!Position(9, 9).isValid());
    }

    Position down(in Number n = 1) const pure {
        return Position(i + n, j);
    }

    unittest {
        assert(Position(0, 0).down() == Position(1, 0));
        assert(Position(1, 2).down(3) == Position(4, 2));
    }

    Position right(in Number n = 1) const pure {
        return Position(i, j + n);
    }

    unittest {
        assert(Position(0, 0).right() == Position(0, 1));
        assert(Position(1, 2).right(3) == Position(1, 5));
    }

}

struct Area {

    Position topLeft, bottomRight;

    bool contains(in Position p) const pure {
        return topLeft.i <= p.i && topLeft.j <= p.j &&
            p.i < bottomRight.i && p.j < bottomRight.j;
    }

    unittest {
        enum topLeft = Position(2, 3);
        enum bottomRight = topLeft.down(2).right(2);
        enum area = Area(topLeft, bottomRight);
        assert(area.contains(topLeft));
        assert(area.contains(topLeft.down()));
        assert(area.contains(topLeft.right()));
        assert(area.contains(topLeft.down().right()));

        assert(!area.contains(bottomRight));
        assert(!area.contains(topLeft.down(2)));
        assert(!area.contains(topLeft.right(2)));

        assert(!area.contains(Position(1, 3)));
        assert(!area.contains(Position(2, 2)));
        assert(!area.contains(Position(1, 2)));
    }

}

enum wholeArea = Area(Position(0, 0), Position(N, N));

Area rowArea(in Number i) pure {
    return Area(Position(i, 0), Position(i + 1, N));
}

Area rowArea(in Position p) pure {
    return rowArea(p.i);
}

Area columnArea(in Number j) pure {
    return Area(Position(0, j), Position(N, j + 1));
}

Area blockArea(in Position p) pure {
    const topLeft = Position(p.i / Nsub * Nsub, p.j / Nsub * Nsub);
    const bottomRight = topLeft.down(3).right(3);
    return Area(topLeft, bottomRight);
}

unittest {
    assert(blockArea(Position(0, 0)) == Area(Position(0, 0), Position(3, 3)));
    assert(blockArea(Position(2, 0)) == Area(Position(0, 0), Position(3, 3)));
    assert(blockArea(Position(0, 2)) == Area(Position(0, 0), Position(3, 3)));
    assert(blockArea(Position(2, 2)) == Area(Position(0, 0), Position(3, 3)));

    assert(blockArea(Position(3, 0)) == Area(Position(3, 0), Position(6, 3)));
    assert(blockArea(Position(6, 0)) == Area(Position(6, 0), Position(9, 3)));

    assert(blockArea(Position(0, 3)) == Area(Position(0, 3), Position(3, 6)));
    assert(blockArea(Position(0, 6)) == Area(Position(0, 6), Position(3, 9)));

    assert(blockArea(Position(8, 8)) == Area(Position(6, 6), Position(9, 9)));
}

class Board(T) {

    T[N][N] values;

}

unittest {
    auto b = new Board!int();
    b.values[0][0] = 3;
    assert(b.values[0][0] == 3);
    assert(b.values[1][0] == 0);
    assert(b.values[0][1] == 0);
}

// vim: set et sw=4:
