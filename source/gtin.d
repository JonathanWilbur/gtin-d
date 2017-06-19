/**
    Strongly-typed Global Trade Item Numbers.
*/
module gtin;
import std.ascii : isDigit;
import std.traits : isIntegral, isUnsigned;

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

    private @property
    ubyte modulo10CheckSumDigit()
    {
        ubyte sum;
        for (int i; i < this._digits.length; i++)
        {
            if ((this._digits.length-i) % 2)
            {
                debug writeln("x3: " ~ cast(char) (this._digits[i] + 0x30u));
                sum += (this._digits[i] * 0x03u);
            }
            else
            {
                debug writeln("x1: " ~ cast(char) (this._digits[i] + 0x30u));
                sum += this._digits[i];
            }
        }
        uint nearestTen = sum;
        while(nearestTen % 10u) nearestTen++;
        debug writefln("sum: %d nearestTen: %d", sum, nearestTen);
        return cast(ubyte) (nearestTen - sum);
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
    public
    this (string digits)
    {
        if (digits.length > 14 || digits.length < 13)
            throw new GTINException
            ("Invalid number of digits in GTIN-14. Constructor will accept 13 or 14.");

        foreach (digit; digits)
        {
            if (!digit.isDigit)
                throw new GTINException
                ("Invalid non-digit character provided to constructor.");
            
            this._digits ~= cast(ubyte) (digit - 0x30);
        }

        if (this._digits.length == 13)
        {
            this._digits ~= this.modulo10CheckSumDigit;
        }
        else if (this._digits.length == 14)
        {
            if (this._digits[$-1] != this.modulo10CheckSumDigit)
                throw new GTINException
                ("Invalid checksum digit provided to the GTIN-14 constructor.");
        }
        else
        {
            assert(0);
        }
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
    public
    this (string digits)
    {
        if (digits.length > 13 || digits.length < 12)
            throw new GTINException
            ("Invalid number of digits in GTIN-13. Constructor will accept 12 or 13.");

        foreach (digit; digits)
        {
            if (!digit.isDigit)
                throw new GTINException
                ("Invalid non-digit character provided to constructor.");
            
            this._digits ~= cast(ubyte) (digit - 0x30);
        }

        if (this._digits.length == 12)
        {
            this._digits ~= this.modulo10CheckSumDigit;
        }
        else if (this._digits.length == 13)
        {
            if (this._digits[$-1] != this.modulo10CheckSumDigit)
                throw new GTINException
                ("Invalid checksum digit provided to the GTIN-13 constructor.");
        }
        else
        {
            assert(0);
        }
    }
}

@system
unittest
{
    GTIN13 g = new GTIN13("629104150021");
    writeln("Calculated string: " ~ g.toString());
    assert(g.toString() == "6291041500213");
}

// alias GTIN12 = GlobalTradeItemNumber12;
// /**

// */
// public
// class GlobalTradeItemNumber12 : GlobalTradeItemNumber
// {

// }

// alias GTIN8 = GlobalTradeItemNumber8;
// /**

// */
// public
// class GlobalTradeItemNumber8 : GlobalTradeItemNumber
// {

// }

// /**
//     Returns the last digit of the number. Luhn checksum digits are usually
//     appended to the number for which they are a checksum, meaning that, to
//     obtain the checksum digit, one simply needs to take the last digit of
//     the number. This function does that.

//     Params:
//         number = The number from which the last digit will be retrieved. The
//             number itself will not be modified by reference.
//     Returns: The last digit of the number.
// */
// // pragma(inline, true)
// public @safe
// ubyte lastDigitOf(T)(T number)
// if (isIntegral!T && isUnsigned!T)
// out (result)
// {
//     assert(result >= 0 && result <= 9);
// }
// body
// {
//     return cast(ubyte) (number % 10u);
// }

// ///
// @safe
// unittest
// {
//     assert(lastDigitOf(79927398713u) == 3u);
// }

// /**
//     Returns the number, but with the last decimal digit removed. The number is
//     not modified by reference, so the number passed in as the argument is not
//     changed by this function; rather, the resulting number is returned.

//     Params:
//         number = The number from which the last decimal digit will be removed.
//     Returns: The number, but with the last decimal digit removed.
// */
// // pragma(inline, true)
// public @safe
// T removeLastDigitFrom(T)(T number)
// if (isIntegral!T && isUnsigned!T)
// out (result)
// {
//     assert(result <= number);
// }
// body
// {
//     return ((number - lastDigitOf(number)) / 10u);
// }

// ///
// @safe
// unittest
// {
//     assert(lastDigitOf(79927398713u) == 3u);
// }