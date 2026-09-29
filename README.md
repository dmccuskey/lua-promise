# lua-promise

Deliver the result of work that finishes later, such as a network request: a `Deferred` that the producer resolves or rejects, and a `Promise` that callers attach their callbacks to.

It's a small, plain Lua 5.1 version of the pattern, with names taken from Twisted's `defer` module (`Deferred`, `callback()`, `errback()`, `addCallbacks()`, `maybeDeferred()`). It was written for [dmc-wamp](https://github.com/dmccuskey/dmc-wamp), whose WAMP session code is ported from AutobahnPython, but it runs anywhere:

```lua
local d = Promise.Deferred:new()
d:addCallbacks( function( value ) print( value ) end )
d:callback( 'done' )  --> done
```

## Features

- `Deferred`: the producer's side; resolves or rejects its promise
- `Promise`: `done()` and `fail()` callbacks, any number of each; a callback added after the promise settled runs at once
- Resolve and reject with any number of values; the callbacks get them all
- `maybeDeferred( func, ... )`: call a function and get a `Deferred` whatever it returns
- Pure Lua 5.1, built on [lua-class](https://github.com/dmccuskey/lua-class); MIT licensed

It isn't Promises/A+: callbacks don't chain, and their return values and errors aren't passed on. See [Known Issues](#known-issues).

## Quick Start

The following steps will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. You will resolve and reject deferreds and watch the callbacks run.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-promise.git
```

The module is `lua-promise/dmc_lua/lua_promise.lua`. The folder also holds a copy of `lua_class.lua`, which it requires.

### 2. Use It

Create `main.lua` in the same folder:

```lua
package.path = './lua-promise/dmc_lua/?.lua;' .. package.path
local Promise = require 'lua_promise'

-- a request that answers later
local function fetchUser( id )
  local d = Promise.Deferred:new()
  if id == 1 then
    d:callback( { name='ada' } )
  else
    d:errback( "no user " .. id )
  end
  return d
end

local function onUser( user ) print( "got", user.name ) end
local function onError( reason ) print( "failed:", reason ) end

fetchUser( 1 ):addCallbacks( onUser, onError )
fetchUser( 7 ):addCallbacks( onUser, onError )

local d = Promise.Deferred:new()
d.promise:done( function( a, b ) print( "sum", a + b ) end )
print( d.promise.state )
d:callback( 2, 3 )
print( d.promise.state )
```

Run it:

```sh
lua main.lua
```

```text
got	ada
failed:	no user 7
pending
sum	5
resolved
```

`fetchUser()` settles its deferred before returning, so `addCallbacks()` runs the callbacks at once; the last deferred holds its callback until `callback()`. If it shows `module 'lua_promise' not found`, run it from the folder that holds `lua-promise/`.

To update, pull the repository again (`git -C lua-promise pull`).

## Reference

### The Module

| member | is |
|---|---|
| `Promise` | The promise class. |
| `Deferred` | The deferred class. |
| `maybeDeferred( func, args, kwargs )` | Calls `func( args, kwargs )`. Returns the result if it's a `Deferred`, otherwise a new `Deferred` already resolved with the result. |
| `__version` | `'0.1.1'`. |

Both classes are lua-class classes: create with `:new()`, remove with `:destroy()`.

### Deferred

| member | does |
|---|---|
| `Deferred:new()` | Creates a deferred with a new, pending promise. |
| `d.promise` | Its promise (read-only property). |
| `d:callback( ... )` | Resolves the promise with the values. |
| `d:errback( ... )` | Rejects the promise with the values. |
| `d:addCallbacks( callback, errback )` | `promise:done( callback )` and `promise:fail( errback )`; either may be `nil`. |
| `d:notify( ... )` | Not written: raises `Promise:progress: not yet implemented`. |

### Promise

| member | does |
|---|---|
| `p.state` | `'pending'`, `'resolved'` or `'rejected'` (read-only property; the values are also `Promise.STATE_PENDING`, `STATE_RESOLVED`, `STATE_REJECTED`). |
| `p:resolve( ... )` | Sets the state to resolved and calls every `done` callback with the values, in the order they were added. |
| `p:reject( ... )` | Sets the state to rejected and calls every `fail` callback with the values. |
| `p:done( callback )` | If resolved, calls `callback` now with the values; otherwise keeps it for `resolve()`. Returns nothing. |
| `p:fail( errback )` | If rejected, calls `errback` now with the values; otherwise keeps it for `reject()`. Returns nothing. |
| `p:progress()` | Not written: raises an error. |

Callbacks run synchronously, inside `resolve()`/`reject()` or `done()`/`fail()`.

## In Solar2D

[dmc-promise](https://github.com/dmccuskey/dmc-promise) is the Solar2D package of this module. The DMC Solar2D libraries load lua-promise as `lib.dmc_lua.lua_promise` from their `dmc_corona/lib/dmc_lua/` folder, part of [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library). dmc-wamp uses it for its futures (`dmc_wamp/future_mix.lua`).

## Known Issues

- **A promise can settle more than once.** `resolve()` and `reject()` don't check the state: a second `resolve()` calls the `done` callbacks again, and a `reject()` after it calls the `fail` callbacks and changes the state.
- **No chaining.** `done()`, `fail()` and `addCallbacks()` return nothing, and a callback's return value is dropped. In Twisted, each callback's result goes to the next one; here every callback gets the original values.
- **An error in a callback stops the rest**: it propagates out of `resolve()`/`reject()` (or `done()`/`fail()`), and the later callbacks don't run.
- **`maybeDeferred()` doesn't catch errors**: when `func` raises, the error propagates instead of coming back as a rejected deferred, as it does in Twisted. It passes at most two arguments (`args`, `kwargs`).
- `maybeDeferred()` looks for a `Failure` class that isn't defined, so it never returns a rejected deferred; any result that isn't a `Deferred`, including a `Promise`, becomes the value of a resolved one.
- `progress()` and `notify()` aren't written.
- Values after a `nil` may be lost when a callback is added after the promise settled (`unpack()` of the stored values); callbacks added before get them all.
- Uses the global `unpack`: Lua 5.1 (and LuaJIT) only. It relies on lua-class's global `newClass()`; its `Class` import is unused.

## Development

Only `dmc_lua/lua_promise.lua` is written here. [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies it into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers it and requires lua-class), and the DMC Solar2D libraries copy it from there into `dmc_corona/lib/dmc_lua/`. `dmc_lua/lua_class.lua` is a copy from [lua-class](https://github.com/dmccuskey/lua-class), for the tests and the Quick Start; fix it there.

The tests are in `spec/lua_promise_spec.lua`, for [busted](https://lunarmodules.github.io/busted/) under Lua 5.1. From the repository's root folder:

```sh
busted spec
```

It ends with:

```text
12 successes / 0 failures / 0 errors / 0 pending : 0.002747 seconds
```

The tests cover `done`/`fail` and `addCallbacks()` added before the promise settles, not callbacks added after, settling twice, or `maybeDeferred()`.

## License

lua-promise is released under the [MIT License](LICENSE).
