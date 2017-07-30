# GTIN D Library

* Author: Jonathan M. Wilbur
* Copyright: Jonathan M. Wilbur
* License: [Boost License 1.0](http://www.boost.org/LICENSE_1_0.txt)
* Publication Year: 2017

This is a library for strongly-typed Global Trade Item Numbers. It supports
GTIN-8, GTIN-12, GTIN-13, and GTIN-14. Constructors for these types generate 
the checksum digit if not supplied, and validate the checksum if it is supplied.

There currently is no command line tool, but one is in the works.

## Usage

You can create a `GTIN` through three constructors:

```d
// Generates a checksum digit and appends it at the end.
GTIN8 gtin1 = new GTIN8("1234567");

// Validates the checksum digit, which is already appended.
GTIN8 gtin2 = new GTIN8("12345670");

// Validates the checksum digit, which is already appended.
GTIN8 gtin3 = new GTIN8(0x01u, 0x02u, 0x03u, 0x04u, 0x05u, 0x06u, 0x07u, 0x00u);
```

When you supply the checksum digit, it is checked. If it is not valid, a
`GTINException` is thrown.

```d
// This throws an exception because the checksum digit for 1234567 is not 8.
GTIN8 gtin2 = new GTIN8("12345678");
```

The compiler will also completely block you from constructing a `GTIN` with an
inappropriate number of digits, like so:

```d
// These will not compile.
// You must supply either N or N-1 digits for a constructor of type GTIN-N.
GTIN8 gtin1 = new GTIN8("123456");
GTIN8 gtin2 = new GTIN8("1234567890");
```

If later, you want primitive types, you can extract the values like so:

```d
assert(gtin1.toString() == "12345670");
assert(gtin2.toNumber() == 12345670UL);
assert(gtin3.digits == [0x01u, 0x02u, 0x03u, 0x04u, 0x05u, 0x06u, 0x07u, 0x00u]);
```

`GTIN`s can be cast to other `GTIN` types, as long as you cast to a larger `GTIN`.
(Casting to a smaller one would result in a loss of information, the behavior of
which is undefined by the specification.) Casting simply prepends zeros until the
`GTIN` is of the correct number of digits.

```d
GTIN8 gtin1 = new GTIN8("1234567");
assert(gtin1.toString() == "12345670");
GTIN14 gtin2 = cast(GTIN14) gtin1;
assert(gtin2.toString() == "0000012345670");
```

## Why?

Putting the validation and checksum generation responsibility on the constructor
itself means that you can trust `GTIN` types elsewhere in your code without 
performing validation.

For instance, here is an example *bad* program:

```d
uint getNumberOfItemsInStock (string gtin)
{
    // You have to validate the GTIN here!
    // Your devs have to validate the gtin string in every function that uses it,
    // which makes it liable to be missed.
    return number;
}
```

Here is the *good* way to do it:

```d
uint getNumberOfItemsInStock (GTIN14 gtin)
{
    // Now, you do not have to do any validation.
    // The validation was already done upon construction of the GTIN,
    // so it can be completely trusted to be valid in this function.
    return number;
}
```

In short, having a stricter data type--instead of a simple string or array of bytes--makes your programs safer.

## Compile and Install

As of right now, there are no build scripts, since the source is a single file,
but there will be build scripts in the future, just for the sake of consistency
across all similar projects.

## See Also

* [GTIN Information](http://www.gtin.info/)
* [GS1's Page on GTIN](https://www.gs1.org/gtin)
* [An Introduction to the Global Trade Item Number (GTIN)](https://gs1us.org/DesktopModules/Bring2mind/DMX/Download.aspx?Command=Core_Download&EntryId=174)
* [How to calculate a check digit manually](https://www.gs1.org/how-calculate-check-digit-manually)
* [Check digit calculator](https://www.gs1.org/check-digit-calculator)
* [Global Trade Item Number (GTIN) Implementation Guide](http://www.entmerch.org/programsinitiatives/packaging-labeling-and-edi/gtin-implementation-guide.pdf)

## Contact Me

If you would like to suggest fixes or improvements on this library, please just
comment on this on GitHub. If you would like to contact me for other reasons,
please email me at [jonathan@wilbur.space](mailto:jonathan@wilbur.space). :boar: