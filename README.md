co2
===

*co2* is an extended replacement for the lua (inbuilt) *coroutine* library.
It was conceived mostly because of my constant frustration that `coroutine.resume` acts like pcall, and not a normal call.


Differences between co2 and coroutine
-------------------------------------

The functionality provided by co2 differs from the coroutine library in a few significant ways:

 - `co2.resume` propagates errors properly.
	When an error occurs in a coroutine, `coroutine.resume` acts like pcall and returns it, `co2.resume` instead throws a new error in the calling coroutine.
 - `co2.presume` implements the `coroutine.resume` semantics.
 - `co2.xpresume` is the `xpcall` version of `co2.resume`.
	Call `co2.xpresume` with a coroutine, a handler, and the arguments to resume the coroutine with.
	In case of an error, the handler is called with the error message, and the coroutine that errored.
 - It comes with an integrated traceback utility `co2.traceback`.
	This traceback combines both the traceback of the supplied coroutine, and the calling coroutine.
	Mostly useful when combined with `co2.xpresume`.


Using this library
------------------

The best way to obtain this library is via [luarocks][rock].
Alternatively, you can use this library by placing the contents of the src directory in a location on your lua load path.

Once installed, you can require the co2 library as follows:

```lua
local co2 = require "co2"
```


Running the tests
-----------------

You can run the provided unit tests using the [busted][] test framework.
When installed you can run `busted tests` from the root of this repository.

[rock]: TBD
[busted]: https://olivinelabs.com/busted/
