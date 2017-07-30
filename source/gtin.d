/**
	Provides strong types for Global Trade Item Numbers, as well as run-time
    checks for and generations of checksum digits.

	Authors:
        $(LINK2 mailto:jonathan@wilbur.space, Jonathan M. Wilbur)
	Date: July 30th, 2017
	License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
	Version: 1.0.0
    See Also:
        $(LINK2 http://www.gtin.info/, GTIN Information)
        $(LINK2 https://www.gs1.org/gtin, GS1's Page on GTIN
        $(LINK2 https://gs1us.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=174,
            An Introduction to the Global Trade Item Number (GTIN)))
        $(LINK2 https://www.gs1.org/how-calculate-check-digit-manually,
            How to calculate a check digit manually)
        $(LINK2 https://www.gs1.org/check-digit-calculator,
            Check digit calculator)
        $(LINK2 http://www.entmerch.org/programsinitiatives/packaging-labeling-and-edi/gtin-implementation-guide.pdf,
            Global Trade Item Number (GTIN) Implementation Guide)
*/
// TODO: Aliases for UPCs, EANs, etc.
// TODO: Casts to and from ISBNs, ISSNs, ISINs, ISMNs, etc.
// TODO: Cast to string
// TODO: Cast to number
// TODO: Command line utility
// TODO: Storage parameters
// TODO: More contracts
module gtin6;
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
    this (string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

///
alias GTIN = GlobalTradeItemNumber;
/// The abstract class from which all GTIN subclasses will inherit
abstract class GlobalTradeItemNumber
{
    private ubyte[] _digits;

    /// Returns: the length in decimal digits of the GTIN
    public nothrow @property
    size_t length()
    {
        return this._digits.length;
    }

    ///
    @system 
    unittest
    {
        GTIN14 gtin1 = new GTIN14("1234567890123");
        GTIN13 gtin2 = new GTIN13("123456789012");
        GTIN12 gtin3 = new GTIN12("12345678901");
        GTIN8 gtin4 = new GTIN8("1234567");
        assert(gtin1.length == 14u);
        assert(gtin2.length == 13u);
        assert(gtin3.length == 12u);
        assert(gtin4.length == 8u);
    }

    /**
        Returns: an array of unsigned bytes of Binary-Coded Decimals (BCD)
            representing the digits of the GTIN
    */
    public nothrow @property
    ubyte[] digits()
    {
        return this._digits;
    }

    ///
    @system 
    unittest
    {
        GTIN14 gtin1 = new GTIN14("1234567890123");
        GTIN13 gtin2 = new GTIN13("123456789012");
        GTIN12 gtin3 = new GTIN12("12345678901");
        GTIN8 gtin4 = new GTIN8("1234567");
        assert(gtin1.digits == [ 0x01u, 0x02u, 0x03u, 0x04u, 0x05u, 0x06u, 0x07u, 0x08u, 0x09u, 0x00u, 0x01u, 0x02u, 0x03u, 0x01u ]);
        assert(gtin2.digits == [ 0x01u, 0x02u, 0x03u, 0x04u, 0x05u, 0x06u, 0x07u, 0x08u, 0x09u, 0x00u, 0x01u, 0x02u, 0x08u ]);
        assert(gtin3.digits == [ 0x01u, 0x02u, 0x03u, 0x04u, 0x05u, 0x06u, 0x07u, 0x08u, 0x09u, 0x00u, 0x01u, 0x02u ]);
        assert(gtin4.digits == [ 0x01u, 0x02u, 0x03u, 0x04u, 0x05u, 0x06u, 0x07u, 0x00u ]);
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("00000000000000");
        GTIN13 gtin2 = new GTIN13("0000000000000");
        GTIN12 gtin3 = new GTIN12("00000000000");
        GTIN8 gtin4 = new GTIN8("00000000");
        assert(gtin1.digits == [ 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u ]);
        assert(gtin2.digits == [ 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u ]);
        assert(gtin3.digits == [ 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u ]);
        assert(gtin4.digits == [ 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u, 0x00u ]);
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("99999999999997");
        GTIN13 gtin2 = new GTIN13("9999999999994");
        GTIN12 gtin3 = new GTIN12("999999999993");
        GTIN8 gtin4 = new GTIN8("99999995");
        assert(gtin1.digits == [ 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x07u ]);
        assert(gtin2.digits == [ 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x04u ]);
        assert(gtin3.digits == [ 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x03u ]);
        assert(gtin4.digits == [ 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x09u, 0x05u ]);
    }

    private
    ubyte modulo10CheckSumDigit(ubyte[] digits ...)
    {
        ubyte sum;
        immutable size_t size = digits.length;
        for (size_t i = 1u; i <= size; i++) // i represents digits digits.length
        {
            sum += (i%2 ? (digits[size-i] * 0x03u) : (digits[size-i]));
            // writefln("Sum %d when + %d multiplied by %d", sum, digits[size-i], i%2?1:3);
        }
        size_t nearestTen = sum;
        while (nearestTen % 10u) nearestTen++;
        return cast(ubyte) (nearestTen - sum);
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("12345678901231");
        GTIN13 gtin2 = new GTIN13("1234567890128");
        GTIN12 gtin3 = new GTIN12("123456789012");
        GTIN8 gtin4 = new GTIN8("12345670");
        assert(gtin1.toString() == "12345678901231");
        assert(gtin2.toString() == "1234567890128");
        assert(gtin3.toString() == "123456789012");
        assert(gtin4.toString() == "12345670");
    }

    /**
        Returns: a string of characters between 0 and 9 representing
            the digits of the GTIN
    */
    public override
    string toString()
    out (result)
    {
        foreach (digit; result)
        {
            assert(digit >= 0x30u && digit <= 0x39u);
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

    ///
    @system 
    unittest
    {
        GTIN14 gtin1 = new GTIN14("1234567890123");
        GTIN13 gtin2 = new GTIN13("123456789012");
        GTIN12 gtin3 = new GTIN12("12345678901");
        GTIN8 gtin4 = new GTIN8("1234567");
        assert(gtin1.toString() == "12345678901231");
        assert(gtin2.toString() == "1234567890128");
        assert(gtin3.toString() == "123456789012");
        assert(gtin4.toString() == "12345670");
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("00000000000000");
        GTIN13 gtin2 = new GTIN13("0000000000000");
        GTIN12 gtin3 = new GTIN12("00000000000");
        GTIN8 gtin4 = new GTIN8("00000000");
        assert(gtin1.toString() == "00000000000000");
        assert(gtin2.toString() == "0000000000000");
        assert(gtin3.toString() == "000000000000");
        assert(gtin4.toString() == "00000000");
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("99999999999997");
        GTIN13 gtin2 = new GTIN13("9999999999994");
        GTIN12 gtin3 = new GTIN12("999999999993");
        GTIN8 gtin4 = new GTIN8("99999995");
        assert(gtin1.toString() == "99999999999997");
        assert(gtin2.toString() == "9999999999994");
        assert(gtin3.toString() == "999999999993");
        assert(gtin4.toString() == "99999995");
    }

    public
    ulong toNumber()
    {
        ulong result;
        ulong mantissa = 10^^(this._digits.length-1);
        for (size_t i = 1u; i <= this._digits.length; i++)
        {
            result += (this._digits[i-1] * mantissa);
            mantissa /= 10u;
        }
        return result;
    }

    ///
    @system 
    unittest
    {
        GTIN14 gtin1 = new GTIN14("1234567890123");
        GTIN13 gtin2 = new GTIN13("123456789012");
        GTIN12 gtin3 = new GTIN12("12345678901");
        GTIN8 gtin4 = new GTIN8("1234567");
        assert(gtin1.toNumber() == 12345678901231UL);
        assert(gtin2.toNumber() == 1234567890128UL);
        assert(gtin3.toNumber() == 123456789012UL);
        assert(gtin4.toNumber() == 12345670UL);
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("00000000000000");
        GTIN13 gtin2 = new GTIN13("0000000000000");
        GTIN12 gtin3 = new GTIN12("00000000000");
        GTIN8 gtin4 = new GTIN8("00000000");
        assert(gtin1.toNumber() == 00000000000000UL);
        assert(gtin2.toNumber() == 0000000000000UL);
        assert(gtin3.toNumber() == 000000000000UL);
        assert(gtin4.toNumber() == 00000000UL);
    }

    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("99999999999997");
        GTIN13 gtin2 = new GTIN13("9999999999994");
        GTIN12 gtin3 = new GTIN12("999999999993");
        GTIN8 gtin4 = new GTIN8("99999995");
        assert(gtin1.toNumber() == 99999999999997UL);
        assert(gtin2.toNumber() == 9999999999994UL);
        assert(gtin3.toNumber() == 999999999993UL);
        assert(gtin4.toNumber() == 99999995UL);
    }

    // REVIEW: Mainly, I want to know that this line is secure.
    // REVIEW: Learn how to actually unittest this.
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

    // REVIEW: I don't think you can do this, but test comparing the arrays directly.
    /**
        Operator override for comparing one GTIN to another
        using the double equals sign comparator ("==").
    */
    public override @trusted
    bool opEquals(Object that)
    {
        GTIN thatGTIN = cast(GTIN) that;
        if (thatGTIN is null) return false;
        if (this.length != thatGTIN.length) return false;
        for (int i = 1; i < this._digits.length; i++)
        {
            if (this._digits[i] != thatGTIN.digits[i]) return false;
        }
        return true;
    }

    ///
    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("1234567890123");
        GTIN14 gtin2 = new GTIN14("1234567890123");
        GTIN14 gtin3 = new GTIN14("1234567890124");
        assert(gtin1 == gtin2);
        assert(gtin1 != gtin3);
    }

    ///
    @system
    unittest
    {
        GTIN13 gtin1 = new GTIN13("123456789012");
        GTIN13 gtin2 = new GTIN13("123456789012");
        GTIN13 gtin3 = new GTIN13("123456789013");
        assert(gtin1 == gtin2);        
        assert(gtin2 != gtin3);
    }

    ///
    @system
    unittest
    {
        GTIN12 gtin1 = new GTIN12("12345678901");
        GTIN12 gtin2 = new GTIN12("12345678901");
        GTIN12 gtin3 = new GTIN12("12345678909");
        assert(gtin1 == gtin2);        
        assert(gtin2 != gtin3);
    }

    ///
    @system
    unittest
    {
        GTIN8 gtin1 = new GTIN8("1234567");
        GTIN8 gtin2 = new GTIN8("1234567");
        GTIN8 gtin3 = new GTIN8("1234565");
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
        GTIN that = cast(GTIN) other;
        if (that is null) return -1; // REVIEW
        const ulong thisNumber = this.toNumber();
        const ulong thatNumber = that.toNumber();
        if (thisNumber == thatNumber) return 0;
        return ((thisNumber / 10u) > (thatNumber / 10u) ? 1 : -1); 
    }

    ///
    @system
    unittest
    {
        GTIN14 gtin1 = new GTIN14("1234567890123");
        GTIN14 gtin2 = new GTIN14("1234567890123");
        GTIN14 gtin3 = new GTIN14("1234567890124");
        assert(!(gtin1 > gtin2));
        assert(gtin1 < gtin3);
    }

    ///
    @system
    unittest
    {
        GTIN13 gtin1 = new GTIN13("123456789012");
        GTIN13 gtin2 = new GTIN13("123456789012");
        GTIN13 gtin3 = new GTIN13("123456789013");
        assert(!(gtin1 < gtin2));        
        assert(gtin2 < gtin3);
    }

    ///
    @system
    unittest
    {
        GTIN12 gtin1 = new GTIN12("12345678901");
        GTIN12 gtin2 = new GTIN12("12345678901");
        GTIN12 gtin3 = new GTIN12("12345678909");
        assert(!(gtin1 > gtin2));        
        assert(gtin2 < gtin3);
    }

    ///
    @system
    unittest
    {
        GTIN8 gtin1 = new GTIN8("1234567");
        GTIN8 gtin2 = new GTIN8("1234567");
        GTIN8 gtin3 = new GTIN8("1234565");
        assert(!(gtin1 > gtin2));        
        assert(gtin2 > gtin3);
    }

    invariant
    {
        assert(this._digits.length > 0);
        foreach (digit; this._digits)
        {
            assert(digit <= 0x09u);
        }
    }
} // End of GTIN superclass

///
alias GlobalTradeItemNumber8 = GlobalTradeItemNumberImpl!8;
///
alias GlobalTradeItemNumber12 = GlobalTradeItemNumberImpl!12;
///
alias GlobalTradeItemNumber13 = GlobalTradeItemNumberImpl!13;
///
alias GlobalTradeItemNumber14 = GlobalTradeItemNumberImpl!14;
///
alias GTIN8 = GlobalTradeItemNumberImpl!8u;
///
alias GTIN12 = GlobalTradeItemNumberImpl!12u;
///
alias GTIN13 = GlobalTradeItemNumberImpl!13u;
///
alias GTIN14 = GlobalTradeItemNumberImpl!14u;
/**

*/
class GlobalTradeItemNumberImpl(uint size) : GlobalTradeItemNumber
{
    static assert(size != 0u, "GTIN size cannot be zero!");

    /* NOTE:
        I tried making digitBytes in the constructors below a fixed-length array,
        but for some reason, when you do that, this._digits becomes some sort of
        array of bytes representing a memory address or something semi-random.
        Changing it to a dynamic array made it work.
    */

    /**
        Accepts a string representing the GTIN $(B without) the checksum digit, then
        calculates the checksum digit and appends it to the end of the GTIN. If
        this object is returned as a string, number, or byte array, it will have
        the checksum digit applied already.

        Params:
            digits = an array of characters between 0 - 9 representing the digits
                of the GTIN $(B without) the checksum digit appended
        Returns:
            a GTIN with the checksum digit calculated and appended
        Throws:
            GTINException if a non-numeric character, such as 'a' or '-' is supplied
                to the constructor 
    */
    public
    this (char[size-1] digits ...)
    {
        ubyte[] digitBytes;
        digitBytes.length = size;
        for (int i = 0; i < size-1; i++)
        {
            digitBytes[i] = cast(ubyte) (digits[i] - 0x30);
            if (digitBytes[i] > 0x09)
                throw new GTINException
                ("Invalid non-digit character provided to constructor.");
        }
        digitBytes[size-1] = this.modulo10CheckSumDigit(digitBytes[0 .. $-1]);
        this._digits = digitBytes;
    }

    /**
        Accepts a string representing the GTIN $(B with) the checksum digit.

        Params:
            digits = an array of characters between 0 - 9 representing the digits
                of the GTIN $(B with) the checksum digit appended
        Returns:
            a GTIN
        Throws:
            GTINException if a non-numeric character, such as 'a' or '-' is supplied
                to the constructor, or if the checksum digit supplied is invalid
    */
    public
    this (char[size] digits ...)
    {
        ubyte[] digitBytes;
        digitBytes.length = size;
        for (int i = 0; i < size; i++)
        {
            digitBytes[i] = cast(ubyte) (digits[i] - 0x30);
            if (digitBytes[i] > 0x09)
                throw new GTINException
                ("Invalid non-digit character provided to constructor.");
        }
        if (digitBytes[size-1] != this.modulo10CheckSumDigit(digitBytes[0 .. $-1]))
            throw new GTINException
            ("Invalid checksum digit provided to the GTIN constructor.");
        this._digits = digitBytes; 
    }

    // TODO: Add a this(ubyte[size-1] bytes ...) constructor for GTINs without checksum

    /**
        Accepts an unsigned byte array representing the GTIN $(B with) the checksum 
        digit.

        Params:
            digits = an array of characters between 0 - 9 representing the digits
                of the GTIN $(B with) the checksum digit appended
        Returns:
            a GTIN
        Throws:
            GTINException if a non-numeric character, such as 'a' or '-' is supplied
                to the constructor, or if the checksum digit supplied is invalid
    */
    public
    this (ubyte[size] bytes ...)
    {
        foreach(b; bytes)
        {
            if (b > 0x09)
                throw new GTINException
                ("Non-decimal number supplied to constructor.");
        }
        this._digits = bytes;
    }

    /* NOTE:
        I had to put this method in the templated class, because this
        would be type GTIN instead of GTIN##, so the generic constraints
        below would not apply properly.
    */

    // TODO: Allow casts to smaller GTINs if all the leading digits are zeroed?

    /**
        Operator override to permit casting to other GTIN types. Note that
        you may only 'cast up in size'; you can only cast from a smaller /
        shorter GTIN to a larger / longer GTIN. The reverse is prohibited
        by the compiler itself; you cannot compile your program if you try
        to cast a larger GTIN to a smaller one. Casting to a smaller GTIN
        is prohibited because doing so would necessitate a loss of
        information, the expected behavior of which is not specified by
        GTIN's specification.

        As an example, you can cast from a GTIN13 to a GTIN14, but you
        cannot cast from a GTIN14 to a GTIN13.

        When you cast one GTIN to another, the GTIN is simply prepended
        with zeros until the required length is achieved for the target
        GTIN type.
    */
    public
    T opCast(T : GTIN)()
    if
    (
        // You can only cast up in size, not down.
        (is(T == GTIN12) && 
            (
                is(typeof(this) == GTIN8) ||
                is(typeof(this) == GTIN12)
            )
        ) ||
        (is(T == GTIN13) && // is(typeof(this) == GTIN)
            (
                is(typeof(this) == GTIN8) || 
                is(typeof(this) == GTIN12) ||
                is(typeof(this) == GTIN13)
            )
        ) ||
        (is(T == GTIN14))
    )
    {
        static if (is(T == GTIN14))
        {
            int targetLength = 14;
            ubyte[14] newGTINDigits;
            char[14] newGTINString;
        }
        else static if (is(T == GTIN13))
        {
            int targetLength = 13;
            ubyte[13] newGTINDigits;
            char[13] newGTINString;
        }
        else static if (is(T == GTIN12))
        {
            int targetLength = 12;
            ubyte[12] newGTINDigits;
            char[12] newGTINString;
        }
        else
        {
            assert(0, "Unexpected opCast target found for GTIN type.");
        }

        for (ulong i = 1u; i <= this._digits.length; i++)
        {
            newGTINDigits[$-i] = this._digits[$-i];
        }

        for (int i = 0; i < targetLength; i++)
        {
            newGTINString[i] = cast(char) (newGTINDigits[i] + 0x30u);
        }
        return new T(newGTINString);
    }

    static if (size == 14)
    {
        /**
            The first digit of a GTIN-14 indicates a 'packaging level'. The
            packaging level is an ordinal (not cardinal) indicator of the
            size of a package of identical items, which themselves have a
            shared GTIN-13. Bigger packages of the same product have higher
            packaging level numbers.

            For example, if the GTIN-14 "01234567890128" indicates a single
            rubber ducky, the GTIN-14 "11234567890125" might indicate a 
            dozen rubber duckies in a case, and the GTIN-14 "21234567890122"
            might indicate a pallet containing a gross (144 or a dozen dozens) 
            of rubber duckies, and the GTIN-14 "31234567890129" might indicate
            a shipping container of rubber duckies, and the GTIN-14 "41234567890126"
            might indicate an entire planet made out of rubber duckies.

            This property only exists for a GTIN-14 and simply returns the first
            digit of the GTIN-14.

            Returns: The first digit of the GTIN-14, which represents the packaging level
        */
        public nothrow @property
        ubyte packagingLevel()
        out (result)
        {
            assert(result < 0x0A);
        }
        body
        {
            return this._digits[0];
        }
    }
} // End of GTINImpl template

/*
    These unittests were put outside of the template so they would not be
    duplicated with each instance of the template.
*/
@system
unittest
{
    import std.exception : assertThrown;
    assertThrown!GTINException(new GTIN14("12345678901234"));
    assertThrown!GTINException(new GTIN13("1234567890123"));
    assertThrown!GTINException(new GTIN12("123456789010"));
    assertThrown!GTINException(new GTIN8("12345678"));
}

@system
unittest
{
    GTIN13 source1 = new GTIN13("123456789012");
    GTIN12 source2 = new GTIN12("12345678901");
    GTIN8 source3 = new GTIN8("1234567");
    assert((cast(GTIN14) source1).toString() == (new GTIN14("0123456789012")).toString());
    assert((cast(GTIN14) source2).toString() == (new GTIN14("0012345678901")).toString());
    assert((cast(GTIN14) source3).toString() == (new GTIN14("0000001234567")).toString());
}

@system
unittest
{
    GTIN12 source1 = new GTIN12("12345678901");
    GTIN8 source2 = new GTIN8("1234567");
    assert((cast(GTIN13) source1).toString() == (new GTIN13("012345678901")).toString());
    assert((cast(GTIN13) source2).toString() == (new GTIN13("000001234567")).toString());
}

@system
unittest
{
    GTIN8 source1 = new GTIN8("1234567");
    assert((cast(GTIN12) source1).toString() == (new GTIN12("00001234567")).toString());
}