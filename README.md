
# Lua-QuickCheck

[![Build Status](https://travis-ci.org/Primordus/lua-quickcheck.svg?branch=master)](https://travis-ci.org/Primordus/lua-quickcheck)
[![Coverage Status](https://coveralls.io/repos/github/Primordus/lua-quickcheck/badge.svg?branch=master)](https://coveralls.io/github/Primordus/lua-quickcheck?branch=master)

Lua-QuickCheck is a Quickcheck clone for Lua.

QuickCheck is a way to do property based testing using randomly generated 
input. Lua-QuickCheck comes with the ability to randomly generate and shrink 
integers, doubles, booleans, strings, tables, ... 

All QuickCheck needs is a property function -- it will then randomly generate 
inputs to that function and call the property for each set of inputs. 
If the property fails (whether by an error or not satisfying your property), 
the inputs are "shrunk" to find a smaller counter-example.

In short:
"Don't write tests... generate them!" - John Hughes


NOTE: this is currently a work in progress.


## Examples

Some example properties can be found [here](https://github.com/Primordus/lua-quickcheck/tree/master/spec/fixtures/examples).


## Contributing

For more information on how to contribute to Lua-QuickCheck, take a look at 
[CONTRIBUTING.md](https://github.com/Primordus/lua-quickcheck/blob/master/CONTRIBUTING.md).


## Tests

Right now lua-quickcheck uses busted for testing (which calls into the
quickcheck engine). Tests can be run with the following command 
in the root directory of this project:

```bash
make tests
```


## Dependencies

LuaQuickcheck currently depends on LuaFilesystem and argparse.
There is also an optional dependency to Moonscript for testing properties 
written in Moonscript.


## Why another QuickCheck clone?

I wanted a quickcheck library that could also easily interface with C or C++
side-by-side with my Lua code.


## Supported Lua versions

- Lua 5.1
- Lua 5.2
- LuaJIT 2.0
- LuaJIT 2.1

Lua 5.3 is currently not fully supported since the luaffi rock needed for the C
integration does not compile with that specific Lua version. The rest of the
functionality is available though.


## License

This project is licensed under the 
[MIT license](https://www.github.com/Primordus/lua-quickcheck/LICENSE)

