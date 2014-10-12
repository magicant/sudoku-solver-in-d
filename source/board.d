import std.conv : to;
import std.string : format;

alias Number = size_t;

enum Number Nsub = 3;
enum Number N = Nsub * Nsub;

struct Position {

    Number i, j;

    bool isValid() const nothrow pure {
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

    Position down(in Number n = 1) const nothrow pure {
        return Position(i + n, j);
    }

    unittest {
        assert(Position(0, 0).down() == Position(1, 0));
        assert(Position(1, 2).down(3) == Position(4, 2));
    }

    Position right(in Number n = 1) const nothrow pure {
        return Position(i, j + n);
    }

    unittest {
        assert(Position(0, 0).right() == Position(0, 1));
        assert(Position(1, 2).right(3) == Position(1, 5));
    }

    string toString() const {
        return format("(%u, %u)", cast(uint) i, cast(uint) j);
    }

    unittest {
        assert(Position(2, 5).toString() == "(2, 5)");
        assert(Position(8, 3).toString() == "(8, 3)");
    }

}

struct Area {

    Position topLeft, bottomRight;

    bool contains(in Position p) const nothrow pure {
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

    int opApply(int delegate(Position p) d) const {
        foreach (i; topLeft.i .. bottomRight.i)
            foreach (j; topLeft.j .. bottomRight.j)
                if (auto result = d(Position(i, j)))
                    return result;
        return 0;
    }

    unittest {
        enum topLeft = Position(3, 5);

        // empty area
        foreach (p; Area(topLeft, topLeft))
            assert(false);
        foreach (p; Area(topLeft, topLeft.down()))
            assert(false);
        foreach (p; Area(topLeft, topLeft.right()))
            assert(false);

        // single position area
        foreach (p; Area(topLeft, topLeft.down().right()))
            assert(p == topLeft);

        // multiple position area
        Position[] ps;
        foreach (p; Area(topLeft, topLeft.down(3).right(2)))
            ps ~= p;
        assert(ps.length == 3 * 2);
        assert(ps[0] == topLeft);
        assert(ps[1] == topLeft.right());
        assert(ps[2] == topLeft.down());
        assert(ps[3] == topLeft.down().right());
        assert(ps[4] == topLeft.down(2));
        assert(ps[5] == topLeft.down(2).right());
    }

}

enum wholeArea = Area(Position(0, 0), Position(N, N));

Area rowArea(in Number i) nothrow pure {
    return Area(Position(i, 0), Position(i + 1, N));
}

Area rowArea(in Position p) nothrow pure {
    return rowArea(p.i);
}

Area columnArea(in Number j) nothrow pure {
    return Area(Position(0, j), Position(N, j + 1));
}

Area columnArea(in Position p) nothrow pure {
    return columnArea(p.j);
}

Area blockArea(in Position p) nothrow pure {
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

    unittest {
        auto b = new Board!int();
        b.values[0][0] = 3;
        assert(b.values[0][0] == 3);
        assert(b.values[1][0] == 0);
        assert(b.values[0][1] == 0);
    }

    ref inout(T) opIndex(Position p) inout nothrow pure {
        return values[p.i][p.j];
    }

    bool opEquals(in Board!T that) const {
        if (!that)
            return false;
        foreach (Position p; wholeArea)
            if (this[p] != that[p])
                return false;
        return true;
    }

    override bool opEquals(Object o) const {
        return opEquals(cast(Board!T) o);
    }

    unittest {
        assert(new Board!bool() == new Board!bool());
    }
    unittest {
        auto a = new Board!int();
        auto b = new Board!int();
        auto p = Position(2, 3);
        assert(a == b);
        a[p] = 23;
        assert(a != b);
        b[p] = 23;
        assert(a == b);
    }

    Board!T dup() const pure @property {
        auto board = new Board!T();
        board.values = this.values;
        return board;
    }

    unittest {
        auto a = new Board!bool();
        auto b = a.dup;
        assert(a == b);
        a[Position()] = true;
        assert(a != b);
    }

}

struct PossibilitySet {

private:

    uint numbers;

    invariant() {
        enum mask = (1u << N) - 1u;
        assert((numbers & mask) == numbers);
    }

    this(uint numbers) nothrow pure {
        this.numbers = numbers;
    }

public:

    bool opIndex(Number n) const nothrow pure
    in {
        assert(n < N);
    }
    body {
        return (this.numbers & (1u << n)) != 0;
    }

    size_t count() const nothrow pure @property {
        uint x = ((numbers & 0b010101010) >>> 1) + (numbers & 0b101010101);
        x = ((x & 0b011001100) >>> 2) + (x & 0b100110011);
        x = (x >>> 8) + (x >>> 4) + x;
        return x & 0b000001111;
    }

    bool empty() const nothrow pure @property {
        return count == 0;
    }

    bool unique() const nothrow pure @property {
        return count == 1;
    }

    Number uniqueValue() const nothrow pure @property
    in {
        assert(unique);
    }
    body {
        foreach (n; 0 .. N)
            if (this[n])
                return n;
        assert(false);
    }

    PossibilitySet add(Number n) const nothrow pure
    in {
        assert(n < N);
    }
    body {
        return PossibilitySet(this.numbers | (1u << n));
    }

    PossibilitySet remove(Number n) const nothrow pure
    in {
        assert(n < N);
    }
    body {
        return PossibilitySet(this.numbers & ~(1u << n));
    }

    static PossibilitySet full() nothrow pure @property {
        return PossibilitySet(0b111111111);
    }

}

unittest {
    enum set235 = PossibilitySet().add(2).add(3).add(5);

    assert(!set235[0]);
    assert(!set235[1]);
    assert(set235[2]);
    assert(set235[3]);
    assert(!set235[4]);
    assert(set235[5]);
    assert(!set235[6]);
    assert(!set235[7]);
    assert(!set235[8]);

    assert(!PossibilitySet()[2]);
    assert(!PossibilitySet()[5]);
    assert(PossibilitySet.full[0]);
    assert(PossibilitySet.full[8]);

    assert(PossibilitySet().count == 0);
    assert(PossibilitySet().add(0).count == 1);
    assert(PossibilitySet().add(1).count == 1);
    assert(PossibilitySet().add(2).count == 1);
    assert(PossibilitySet().add(3).count == 1);
    assert(PossibilitySet().add(4).count == 1);
    assert(PossibilitySet().add(5).count == 1);
    assert(PossibilitySet().add(6).count == 1);
    assert(PossibilitySet().add(7).count == 1);
    assert(PossibilitySet().add(8).count == 1);
    assert(set235.count == 3);
    assert(PossibilitySet.full.count == N);

    assert(PossibilitySet().empty);
    assert(!PossibilitySet().add(0).empty);
    assert(!PossibilitySet().add(8).empty);
    assert(!set235.empty);
    assert(!PossibilitySet.full.empty);

    assert(!PossibilitySet().unique);
    assert(PossibilitySet().add(0).unique);
    assert(PossibilitySet().add(1).unique);
    assert(PossibilitySet().add(2).unique);
    assert(PossibilitySet().add(3).unique);
    assert(PossibilitySet().add(4).unique);
    assert(PossibilitySet().add(5).unique);
    assert(PossibilitySet().add(6).unique);
    assert(PossibilitySet().add(7).unique);
    assert(PossibilitySet().add(8).unique);
    assert(!set235.unique);
    assert(!PossibilitySet.full.unique);

    assert(set235.add(2) == set235);
    assert(set235.add(5) == set235);
    assert(set235.remove(0) == set235);
    assert(set235.remove(7) == set235);

    assert(set235.remove(2) == PossibilitySet().add(3).add(5));
    assert(set235.remove(5) == PossibilitySet().add(2).add(3));

    assert(PossibilitySet().add(0).uniqueValue == 0);
    assert(PossibilitySet().add(1).uniqueValue == 1);
    assert(PossibilitySet().add(2).uniqueValue == 2);
    assert(PossibilitySet().add(3).uniqueValue == 3);
    assert(PossibilitySet().add(4).uniqueValue == 4);
    assert(PossibilitySet().add(5).uniqueValue == 5);
    assert(PossibilitySet().add(6).uniqueValue == 6);
    assert(PossibilitySet().add(7).uniqueValue == 7);
    assert(PossibilitySet().add(8).uniqueValue == 8);
}

Board!U convert(U, T)(const Board!T from, U delegate(in T) d) {
    auto to = new Board!U();
    foreach (Position p; wholeArea)
        to[p] = d(from[p]);
    return to;
}

unittest {
    auto from = new Board!int();
    auto p1 = Position(0, 3), p2 = Position(2, 4), p3 = Position(5, 1);
    from[p1] = 1;
    from[p2] = 1;
    from[p3] = 1;
    auto result = from.convert((in int n) => n != 0);
    foreach (Position p; wholeArea)
        assert(result[p] == (p == p1 || p == p2 || p == p3), to!string(p));
}

// vim: set et sw=4:
