/**
    Strongly-typed Global Trade Item Numbers.
*/
module gtin;
import std.ascii : isDigit;
import std.traits : isIntegral, isUnsigned;
// TODO: gs1Prefix()
// TODO: Create countries library to identify prefixes
// TODO: Create ISBN library for "bookland" constructor
// TODO: Create ISSN for Serial Publications constructor
// TODO: Create a UPC library for GTIN-12 constructor
// TODO: opEquals will have to be implemented for each class.
// TODO: opCmp will have to be implemented for each class.

version(unittest)
{
    import std.stdio : writefln, writeln;
}

///
alias GTINException = GlobalTradeItemNumberException;
/**
    A class thrown when a Global Trade Item Number is supplied with an invalid
    identifier.
*/
public
class GlobalTradeItemNumberException : Exception
{
    @nogc @safe pure nothrow
    this
    (
        string msg, 
        string file = __FILE__, 
        size_t line = __LINE__,
        Throwable next = null
    )
    {
        super(msg, file, line, next);
    }
}


alias GTIN = GlobalTradeItemNumber;
/**

*/
public abstract
class GlobalTradeItemNumber
{
    public abstract @property
    size_t length();

    private ubyte[] _digits;

    public nothrow @property
    ubyte[] digits()
    {
        return this._digits;
    }

    /**
        Casts the GTIN as a string.
    */
    public nothrow
    string opCast(string)()
    {
        return this.toString();
    }

    public override
    string toString()
    out (result)
    {
        foreach (digit; result)
        {
            assert(digit.isDigit);
        }
    }
    body
    {
        string result;
        foreach (digit; this._digits)
        {
            result ~= cast(char) (digit + 0x30u);
        }
        return result;
    }

    // REVIEW: Mainly, I want to know that this line is secure.
    /**
        An override so that associative arrays can use a GTIN as a key.
        Returns: A size_t that represents a hash of the GTIN.
    */
    public override nothrow @trusted 
    size_t toHash() const
    {
        size_t result = 0;
        foreach (digit; this._digits)
        {
            result += typeid(digit).getHash(cast(const void*)&digit);
        }
        return result;
    }

    public
    ulong toNumber()
    {
        ulong result;
        for (int i = this.length-1; i > 0; i--)
        {
            result += (this._digits[i] * (10^^(this._digits.length-i)));
        }
        return result;
    }

    private @property
    ubyte modulo10CheckSumDigit()
    {
        ubyte sum;
        for (int i; i < this._digits.length; i++)
        {
            if ((this._digits.length-i) % 2)
            {
                sum += (this._digits[i] * 0x03u);
            }
            else
            {
                sum += this._digits[i];
            }
        }
        uint nearestTen = sum;
        while(nearestTen % 10u) nearestTen++;
        return cast(ubyte) (nearestTen - sum);
    }

    public
    this (string digits)
    {
        if (digits.length > this.length || digits.length < this.length-1)
            throw new GTINException
            ("Invalid number of digits provided to GTIN.");

        foreach (digit; digits)
        {
            if (!digit.isDigit)
                throw new GTINException
                ("Invalid non-digit character provided to constructor.");
            
            this._digits ~= cast(ubyte) (digit - 0x30);
        }

        if (this._digits.length == this.length-1)
        {
            this._digits ~= this.modulo10CheckSumDigit;
        }
        else if (this._digits.length == this.length)
        {
            if (this._digits[$-1] != this.modulo10CheckSumDigit)
                throw new GTINException
                ("Invalid checksum digit provided to the GTIN constructor.");
        }
        else
        {
            assert(0);
        }
    }

    public
    this (ulong number)
    {
        // If the number is too big to be expressed by this GTIN
        if (number >= (10L^^(this.length+1L)))
            throw new GTINException
            ("Constructor for GTIN received too big of a number.");

        this._digits.length = this.length;
        int digitsIndex = this.length-1;
        while (number > 0u)
        {
            this._digits[digitsIndex--] = (number % 10u);
            number = ((number - (number % 10u)) / 10u);
        }
    }

    @system
    unittest
    {
        GTIN8 g08 = new GTIN8(1234_5678u);
        assert(g08.toString() == "12345678");
        GTIN12 g12 = new GTIN12(1234_5678_9012u);
        assert(g12.toString() == "123456789012");
        GTIN13 g13 = new GTIN13(1234_5678_9012_3u);
        assert(g13.toString() == "1234567890123");
        GTIN14 g14 = new GTIN14(1234_5678_9012_34u);
        assert(g14.toString() == "12345678901234");
    }

    invariant
    {
        foreach (digit; this._digits)
        {
            assert(digit <= 0x09);
        }
    }
}

alias GTIN14 = GlobalTradeItemNumber14;
/**

*/
public
class GlobalTradeItemNumber14 : GlobalTradeItemNumber
{
    public override @property
    size_t length()
    {
        return 14u;
    }

    this(string digits)
    {
        super(digits);
    }

    this(ulong number)
    {
        super(number);
    }

    /**
        Operator override for comparing one GTIN to another
        using the double equals sign comparator ("==").
    */
    public override nothrow @trusted
    bool opEquals(Object other)
    {
        GTIN14 that = cast(GTIN14) other;
        return ((!(that is null)) && (this.digits == that.digits));
    }

    ///
    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14(1234_5678u);
        GTIN14 gtin2 = new GTIN14(1234_5678u);
        GTIN14 gtin3 = new GTIN14(1234_5679u);
        assert(gtin1 == gtin2);
        assert(gtin2 != gtin3);
    }

    /**
        Operator override for comparing one GTIN to another
        using the "<", "<=", ">", and ">=" comparators.
    */
    public override @trusted
    int opCmp(Object other)
    {
        GTIN14 that = cast(GTIN14) other;
        const ulong thisNumber = this.toNumber();
        const ulong thatNumber = that.toNumber();
        if (thisNumber == thatNumber) return 0;
        return ((thisNumber / 10u) > (thatNumber / 10u) ? 1 : -1); 
    }

    ///
    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14(1234_5678u);
        GTIN14 gtin2 = new GTIN14(1234_5678u);
        GTIN14 gtin3 = new GTIN14(1234_5679u);
        assert(!(gtin1 > gtin2));
        assert(!(gtin1 < gtin2));
        assert(gtin1 >= gtin2);
        assert(gtin1 <= gtin2);
        assert(gtin2 < gtin3);
    }

    /**
        Bigger packages of the same product have higher packaging level
        numbers.
    */
    public @property
    ubyte packagingLevel()
    {
        return this._digits[0];
    }
}

alias GTIN13 = GlobalTradeItemNumber13;
/**

*/
public
class GlobalTradeItemNumber13 : GlobalTradeItemNumber
{
    public override @property
    size_t length()
    {
        return 13u;
    }

    this(string digits)
    {
        super(digits);
    }

    this(ulong number)
    {
        super(number);
    }

        /**
        Operator override for comparing one GTIN to another
        using the double equals sign comparator ("==").
    */
    public override nothrow @trusted
    bool opEquals(Object other)
    {
        GTIN13 that = cast(GTIN13) other;
        return ((!(that is null)) && (this.digits == that.digits));
    }

    ///
    @system
    unittest
    {
        GTIN13 gtin1 = new GTIN13(1234_5678u);
        GTIN13 gtin2 = new GTIN13(1234_5678u);
        GTIN13 gtin3 = new GTIN13(1234_5679u);
        assert(gtin1 == gtin2);
        assert(gtin2 != gtin3);
    }

    /**
        Operator override for comparing one GTIN to another
        using the "<", "<=", ">", and ">=" comparators.
    */
    public override @trusted
    int opCmp(Object other)
    {
        GTIN13 that = cast(GTIN13) other;
        const ulong thisNumber = this.toNumber();
        const ulong thatNumber = that.toNumber();
        if (thisNumber == thatNumber) return 0;
        return ((thisNumber / 10u) > (thatNumber / 10u) ? 1 : -1); 
    }

    ///
    @system
    unittest
    {
        GTIN13 gtin1 = new GTIN13(1234_5678u);
        GTIN13 gtin2 = new GTIN13(1234_5678u);
        GTIN13 gtin3 = new GTIN13(1234_5679u);
        assert(!(gtin1 > gtin2));
        assert(!(gtin1 < gtin2));
        assert(gtin1 >= gtin2);
        assert(gtin1 <= gtin2);
        assert(gtin2 < gtin3);
    }
}

@system
unittest
{
    GTIN13 g = new GTIN13("629104150021");
    assert(g.toString() == "6291041500213");
}

alias GTIN12 = GlobalTradeItemNumber12;
/**

*/
public
class GlobalTradeItemNumber12 : GlobalTradeItemNumber
{
    public override @property
    size_t length()
    {
        return 12u;
    }

    this(string digits)
    {
        super(digits);
    }

    this(ulong number)
    {
        super(number);
    }

        /**
        Operator override for comparing one GTIN to another
        using the double equals sign comparator ("==").
    */
    public override nothrow @trusted
    bool opEquals(Object other)
    {
        GTIN12 that = cast(GTIN12) other;
        return ((!(that is null)) && (this.digits == that.digits));
    }

    ///
    @system
    unittest
    {
        GTIN12 gtin1 = new GTIN12(1234_5678u);
        GTIN12 gtin2 = new GTIN12(1234_5678u);
        GTIN12 gtin3 = new GTIN12(1234_5679u);
        assert(gtin1 == gtin2);
        assert(gtin2 != gtin3);
    }

    /**
        Operator override for comparing one GTIN to another
        using the "<", "<=", ">", and ">=" comparators.
    */
    public override @trusted
    int opCmp(Object other)
    {
        GTIN12 that = cast(GTIN12) other;
        const ulong thisNumber = this.toNumber();
        const ulong thatNumber = that.toNumber();
        if (thisNumber == thatNumber) return 0;
        return ((thisNumber / 10u) > (thatNumber / 10u) ? 1 : -1); 
    }

    ///
    @system
    unittest
    {
        GTIN12 gtin1 = new GTIN12(1234_5678u);
        GTIN12 gtin2 = new GTIN12(1234_5678u);
        GTIN12 gtin3 = new GTIN12(1234_5679u);
        assert(!(gtin1 > gtin2));
        assert(!(gtin1 < gtin2));
        assert(gtin1 >= gtin2);
        assert(gtin1 <= gtin2);
        assert(gtin2 < gtin3);
    }
}

alias GTIN8 = GlobalTradeItemNumber8;
/**

*/
public
class GlobalTradeItemNumber8 : GlobalTradeItemNumber
{
    public override @property
    size_t length()
    {
        return 8u;
    }

    this(string digits)
    {
        super(digits);
    }

    this(ulong number)
    {
        super(number);
    }

        /**
        Operator override for comparing one GTIN to another
        using the double equals sign comparator ("==").
    */
    public override nothrow @trusted
    bool opEquals(Object other)
    {
        GTIN8 that = cast(GTIN8) other;
        return ((!(that is null)) && (this.digits == that.digits));
    }

    ///
    @system
    unittest
    {
        GTIN8 gtin1 = new GTIN8(1234_5678u);
        GTIN8 gtin2 = new GTIN8(1234_5678u);
        GTIN8 gtin3 = new GTIN8(1234_5679u);
        assert(gtin1 == gtin2);
        assert(gtin2 != gtin3);
    }

    /**
        Operator override for comparing one GTIN to another
        using the "<", "<=", ">", and ">=" comparators.
    */
    public override @trusted
    int opCmp(Object other)
    {
        GTIN8 that = cast(GTIN8) other;
        const ulong thisNumber = this.toNumber();
        const ulong thatNumber = that.toNumber();
        if (thisNumber == thatNumber) return 0;
        return ((thisNumber / 10u) > (thatNumber / 10u) ? 1 : -1); 
    }

    ///
    @system
    unittest
    {
        GTIN8 gtin1 = new GTIN8(1234_5678u);
        GTIN8 gtin2 = new GTIN8(1234_5678u);
        GTIN8 gtin3 = new GTIN8(1234_5679u);
        assert(!(gtin1 > gtin2));
        assert(!(gtin1 < gtin2));
        assert(gtin1 >= gtin2);
        assert(gtin1 <= gtin2);
        assert(gtin2 < gtin3);
    }
}