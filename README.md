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
- A promise settles once: later `resolve()` and `reject()` calls are ignored
- Resolve and reject with any number of values, `nil` included; the callbacks get them all
- `maybeDeferred( func, ... )`: call a function and get a `Deferred` whatever it returns, rejected if the function raises an error
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
| `maybeDeferred( func, ... )` | Calls `func( ... )` in `pcall()`. Returns the result if it's a `Deferred`, otherwise a new `Deferred` already resolved with the result (its first return value). If `func` raises, returns a new `Deferred` already rejected with the error: the message string (with its file and line) or the value raised. |
| `__version` | `'0.2.0'`. |

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
| `p:resolve( ... )` | If pending, sets the state to resolved and calls every `done` callback with the values, in the order they were added. Does nothing if the promise has settled. |
| `p:reject( ... )` | If pending, sets the state to rejected and calls every `fail` callback with the values. Does nothing if the promise has settled. |
| `p:done( callback )` | If pending, keeps `callback` for `resolve()`; if resolved, calls it now with the values; if rejected, drops it. Returns nothing. |
| `p:fail( errback )` | If pending, keeps `errback` for `reject()`; if rejected, calls it now with the values; if resolved, drops it. Returns nothing. |
| `p:progress()` | Not written: raises an error. |

Callbacks run synchronously, inside `resolve()`/`reject()` or `done()`/`fail()`. Once the promise has settled it keeps no callbacks.

## In Solar2D

[dmc-promise](https://github.com/dmccuskey/dmc-promise) is the Solar2D package of this module. The DMC Solar2D libraries load lua-promise as `lib.dmc_lua.lua_promise` from their `dmc_corona/lib/dmc_lua/` folder, part of [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library). dmc-wamp uses it for its futures (`dmc_wamp/future_mix.lua`).

## Known Issues

- **No chaining.** `done()`, `fail()` and `addCallbacks()` return nothing, and a callback's return value is dropped. In Twisted, each callback's result goes to the next one; here every callback gets the original values.
- **An error in a callback stops the rest**: it propagates out of `resolve()`/`reject()` (or `done()`/`fail()`), and the later callbacks don't run.
- `maybeDeferred()` has no `Failure` class, as Twisted has: a raised error comes back as it was raised. Any result that isn't a `Deferred`, including a `Promise`, becomes the value of a resolved one, and only the first return value is kept.
- `progress()` and `notify()` aren't written.

## Development

Only `dmc_lua/lua_promise.lua` is written here. [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies it into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers it and requires lua-class), and the DMC Solar2D libraries copy it from there into `dmc_corona/lib/dmc_lua/`. `dmc_lua/lua_class.lua` is a copy from [lua-class](https://github.com/dmccuskey/lua-class), for the tests and the Quick Start; fix it there.

The tests are in `spec/lua_promise_spec.lua`, for [busted](https://lunarmodules.github.io/busted/) under Lua 5.1. From the repository's root folder:

```sh
busted spec
```

It ends with:

```text
22 successes / 0 failures / 0 errors / 0 pending : 0.004 seconds
```

The tests cover `done`/`fail` and `addCallbacks()` added before and after the promise settles, settling once, values after a `nil`, and `maybeDeferred()`.

## License

lua-promise is released under the [MIT License](LICENSE).
