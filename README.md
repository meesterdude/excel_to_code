# Excel to Code

[![Tests Passing](https://travis-ci.org/tamc/excel_to_code.svg?branch=master)](https://travis-ci.org/tamc/excel_to_code)

excel_to_c - roughly translate some Excel files into C.

excel_to_ruby - roughly translate some Excel files into Ruby.

This allows spreadsheets to be:

1. Embedded in other programs, such as web servers, or optimisers
2. Without depending on any Microsoft code

For example, running [these commands](examples/simple/compile.sh) turns [this spreadsheet](examples/simple/simple.xlsx) into [this Ruby code](examples/simple/ruby/simple.rb) or [this C code](examples/simple/c/simple.c).

# Install

Requires Ruby. Install by:

    gem install excel_to_code

# Run

To just have a go:

	excel_to_c <excel_file_name>

This will produce a file called excelspreadsheet.c

For a more complex spreadsheet:
	
	excel_to_c --compile --run-tests --settable <name of input worksheet> --prune-except <name of output worksheet> <excel file name> 
	
See the full list of options:

	excel_to_c --help

# Gotchas, limitations and bugs

0. ~~No custom functions, no macros for generating results~~ see expansion notes
1. Results are cached. So you must call reset(), then set values, then read values.
2. It must be possible to replace INDIRECT and OFFSET formula with standard references at compile time (e.g., INDIRECT("A"&"1") is fine, INDIRECT(userInput&"3") is not.
3. Doesn't implement all functions. [See which functions are implemented](docs/Which_functions_are_implemented.md).
4. Doesn't implement references that involve range unions and lists (but does implement standard ranges)
5. Sometimes gives cells as being empty, when excel would give the cell as having a numeric value of zero
6. The generated C version does not multithread and will give bad results if you try.
7. The generated code uses floating point, rather than fully precise arithmetic, so results can differ slightly.
8. The generated code uses the sprintf approach to rounding (even-odd) rather than excel's 0.5 rounds away from zero.
9. Ranges like this: Sheet1!A10:Sheet1!B20 and 3D ranges don't work.


# Expansion notes

0. define custom JS functions via a "functions" named range and will they available at runtime via execjs. 
1. All cells are lambdas and lazy eval. When assigning a value, it will be wrapped in a lambda if it is not already one.
2. To check if a cell is empty, use ISBLANK() and not something like `A1 <> ""`
3. Because of custom JS functions, the importer will no longer raise an exception if an excel function is used for which there is no support. 
4. Call `reset_cache` to clear the caches (but not any values you've set)
5. excel stores time as a float of days since jan 1st 1900. to get time into and out of excel, it must be converted.
	1. Unix Timestamp = (Excel Timestamp - 25569) * 86400
	2. Excel Timestamp =  (Unix Timestamp / 86400) + 25569
6. To convert a duration to hours, multiply it by 24. 

# Debugging

The best way to debug a generated class is to compare it to what the spreadsheet has for a given cell utilizing the same values, or creating a very small spreadsheet that encompasses the problem and focus on that. This makes it easy to debug the underlying library. Common issues are:

0. Misuse of excel functions. 
1. relying on excel magic that cannot translate into the conversion
2. Parsing error
3. missing or incorrect function implementation

Report bugs: <https://github.com/tamc/excel_to_code/issues>

# Changelog

See [Changes](CHANGES.md).

# License

See [License](LICENSE.md)

# Hacking

Source code: <https://github.com/tamc/excel_to_code>

Documentation:

* [Installing from source](docs/installing_from_source.md)
* [Structure of this project](docs/structure_of_this_project.md)
* [How does the calculation work](docs/how_does_the_calculation_work.md)
* [How to fix parsing errors](docs/How_to_fix_parsing_errors.md)
* [How to implement a new Excel function](docs/How_to_add_a_missing_function.md)

Some notes on how Excel works under the hood:

* [The Excel file structure](docs/implementation/excel_file_structure.md)
* [Relationships](docs/implementation/relationships.md)
* [Workbooks](docs/implementation/workbook.md)
* [Worksheets](docs/implementation/worksheets.md)
* [Cells](docs/implementation/cell.md)
* [Tables](docs/implementation/tables.md)
* [Shared Strings](docs/implementation/shared_strings.md)
* [Array formulae](docs/implementation/array_formulae.md)

