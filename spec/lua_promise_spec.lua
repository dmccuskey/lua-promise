--====================================================================--
-- spec/lua_promise_spec.lua
--
-- Testing for lua-promise using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


--====================================================================--
--== Test: Lua Promise
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Promise = require 'lua_promise'



--====================================================================--
--== Testing Setup
--====================================================================--


describe( "Module Test: lua_promise.lua", function()


	describe( "Tests for Module", function()

		it( "has a version", function()
			assert.is.equal( type(Promise.__version), 'string' )
		end)

		it( "has a Promise class", function()
			local class = Promise.Promise
			assert.is.equal( type(class), 'table' )
			assert.is.equal( class.NAME, "Lua Promise" )
		end)

		it( "has a Deferred class", function()
			local class = Promise.Deferred
			assert.is.equal( type(class), 'table' )
			assert.is.equal( class.NAME, "Lua Deferred" )
		end)

	end)


	describe( "Tests for Promise", function()

		local obj

		before_each( function()
			obj = Promise.Promise:new()
		end)

		after_each( function()
			obj:destroy()
			obj = nil
		end)


		it( "can be resolved", function()
			local cb1_f, cb2_f
			local val, err = nil, nil

			cb1_f = function( value )
				val = value
			end
			cb2_f = function( e )
				err = e
			end

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:done( cb1_f )
			obj:fail( cb2_f )

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:resolve( "success" )

			assert.are.equal( val, 'success' )
			assert.are.equal( err, nil )

		end)


		it( "can be rejected", function()
			local cb1_f, cb2_f
			local val, err = nil, nil

			cb1_f = function( value )
				val = value
			end
			cb2_f = function( e )
				err = e
			end

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:done( cb1_f )
			obj:fail( cb2_f )

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:reject( "error" )

			assert.are.equal( val, nil )
			assert.are.equal( err, 'error' )
		end)


		it( "has multiple resolve callbacks", function()
			local cb1_f, cb2_f
			local val1, val2 = nil, nil

			cb1_f = function( value )
				val1 = value
			end
			cb2_f = function( e )
				val2 = e
			end

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:done( cb1_f )
			obj:done( cb2_f )

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:resolve( "success!" )

			assert.are.equal( val1, "success!" )
			assert.are.equal( val2, "success!" )
		end)


		it( "has multiple reject callbacks", function()
			local cb1_f, cb2_f
			local val1, val2 = nil, nil

			cb1_f = function( value )
				val1 = value
			end
			cb2_f = function( e )
				val2 = e
			end

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:fail( cb1_f )
			obj:fail( cb2_f )

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:reject( "error!" )

			assert.are.equal( val1, "error!" )
			assert.are.equal( val2, "error!" )
		end)

	end)



	describe( "Tests for Deferred", function()

		local obj

		before_each( function()
			obj = Promise.Deferred:new()
		end)

		after_each( function()
			obj:destroy()
			obj = nil
		end)


		it( "has a Promise", function()
			local promise = obj.promise
			assert.is.equal( type(promise), 'table' )
			assert.is.equal( promise.NAME, "Lua Promise" )
		end)


		it( "can be resolved", function()
			local cb1_f, cb2_f
			local val, err = nil, nil

			cb1_f = function( value )
				val = value
			end
			cb2_f = function( e )
				err = e
			end

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:addCallbacks( cb1_f, cb2_f )

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:callback( "success" )

			assert.are.equal( val, 'success' )
			assert.are.equal( err, nil )

		end)


		it( "can be rejected", function()
			local cb1_f, cb2_f
			local val, err = nil, nil

			cb1_f = function( value )
				val = value
			end
			cb2_f = function( e )
				err = e
			end

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:addCallbacks( cb1_f, cb2_f )

			assert.are.equal( val, nil )
			assert.are.equal( err, nil )

			obj:errback( "error" )

			assert.are.equal( val, nil )
			assert.are.equal( err, 'error' )
		end)


		it( "has multiple resolve callbacks", function()
			local cb1_f, cb2_f
			local val1, val2 = nil, nil

			cb1_f = function( value )
				val1 = value
			end
			cb2_f = function( e )
				val2 = e
			end

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:addCallbacks( cb1_f )
			obj:addCallbacks( cb2_f )

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:callback( "success!" )

			assert.are.equal( val1, "success!" )
			assert.are.equal( val2, "success!" )
		end)


		it( "has multiple reject callbacks", function()
			local cb1_f, cb2_f
			local val1, val2 = nil, nil

			cb1_f = function( value )
				val1 = value
			end
			cb2_f = function( e )
				val2 = e
			end

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:addCallbacks( nil, cb1_f )
			obj:addCallbacks( nil, cb2_f )

			assert.are.equal( val1, nil )
			assert.are.equal( val2, nil )

			obj:errback( "error!" )

			assert.are.equal( val1, "error!" )
			assert.are.equal( val2, "error!" )
		end)

	end)


	describe( "Tests for settling", function()

		local obj

		before_each( function()
			obj = Promise.Promise:new()
		end)

		after_each( function()
			obj:destroy()
			obj = nil
		end)


		it( "settles only once", function()
			local done_count, fail_count = 0, 0
			obj:done( function() done_count = done_count + 1 end )
			obj:fail( function() fail_count = fail_count + 1 end )

			obj:resolve( 1 )
			obj:resolve( 2 )
			obj:reject( "error!" )

			assert.are.equal( obj.state, Promise.Promise.STATE_RESOLVED )
			assert.are.equal( done_count, 1 )
			assert.are.equal( fail_count, 0 )

			local late
			obj:done( function( value ) late = value end )
			assert.are.equal( late, 1 )
		end)

		it( "ignores resolve() after reject()", function()
			local val, err
			obj:done( function( value ) val = value end )
			obj:fail( function( e ) err = e end )

			obj:reject( "error!" )
			obj:resolve( "success" )

			assert.are.equal( obj.state, Promise.Promise.STATE_REJECTED )
			assert.are.equal( err, "error!" )
			assert.are.equal( val, nil )
		end)

		it( "runs a callback added after resolve() at once", function()
			obj:resolve( "success" )
			local val, err
			obj:done( function( value ) val = value end )
			obj:fail( function( e ) err = e end )
			assert.are.equal( val, "success" )
			assert.are.equal( err, nil )
		end)

		it( "runs an errback added after reject() at once", function()
			obj:reject( "error!" )
			local val, err
			obj:done( function( value ) val = value end )
			obj:fail( function( e ) err = e end )
			assert.are.equal( err, "error!" )
			assert.are.equal( val, nil )
		end)

		it( "passes values after a nil hole", function()
			local before, after
			obj:done( function( ... ) before = { n=select( '#', ... ), ... } end )
			obj:resolve( 1, nil, 3 )
			obj:done( function( ... ) after = { n=select( '#', ... ), ... } end )

			assert.are.equal( before.n, 3 )
			assert.are.equal( before[3], 3 )
			assert.are.equal( after.n, 3 )
			assert.are.equal( after[3], 3 )
		end)

	end)


	describe( "Tests for a callback that raises an error", function()

		local obj

		before_each( function()
			obj = Promise.Promise:new()
		end)

		after_each( function()
			obj:destroy()
			obj = nil
		end)


		it( "runs the later callbacks, then raises the error", function()
			local order = {}
			obj:done( function() order[#order+1] = 1 end )
			obj:done( function() order[#order+1] = 2 ; error( "second failed", 0 ) end )
			obj:done( function( value ) order[#order+1] = value end )

			assert.has.error( function() obj:resolve( 3 ) end, "second failed" )
			assert.are.same( { 1, 2, 3 }, order )
			assert.are.equal( obj.state, Promise.Promise.STATE_RESOLVED )
		end)

		it( "runs the later errbacks, then raises the error", function()
			local reasons = {}
			obj:fail( function() error( "first failed", 0 ) end )
			obj:fail( function( reason ) reasons[#reasons+1] = reason end )

			assert.has.error( function() obj:reject( "why" ) end, "first failed" )
			assert.are.same( { "why" }, reasons )
			assert.are.equal( obj.state, Promise.Promise.STATE_REJECTED )
		end)

		it( "raises the first error of several", function()
			local count = 0
			obj:done( function() count = count + 1 ; error( "one", 0 ) end )
			obj:done( function() count = count + 1 ; error( "two", 0 ) end )

			assert.has.error( function() obj:resolve() end, "one" )
			assert.are.equal( count, 2 )
		end)

		it( "raises an error object as it is", function()
			local err = { code=42 }
			local ran = false
			obj:done( function() error( err ) end )
			obj:done( function() ran = true end )

			local ok, caught = pcall( function() obj:resolve() end )
			assert.is_false( ok )
			assert.are.equal( caught, err )
			assert.is_true( ran )
		end)

		it( "keeps a raised nil an error", function()
			local ran = false
			obj:done( function() error() end )
			obj:done( function() ran = true end )

			assert.is_false( pcall( function() obj:resolve() end ) )
			assert.is_true( ran )
		end)

		it( "works through a Deferred", function()
			local d = Promise.Deferred:new()
			local ran = false
			d:addCallbacks( function() error( "cb failed", 0 ) end, nil )
			d:addCallbacks( function() ran = true end, nil )

			assert.has.error( function() d:callback( 1 ) end, "cb failed" )
			assert.is_true( ran )
		end)

	end)


	describe( "Tests for maybeDeferred", function()

		local maybeDeferred = Promise.maybeDeferred

		local function outcome( d )
			local res = {}
			d:addCallbacks(
				function( ... ) res.val = { ... } end,
				function( ... ) res.err = { ... } end
			)
			return res
		end


		it( "resolves with the function's result", function()
			local d = maybeDeferred( function( a, b ) return a + b end, 2, 3 )
			assert.is_true( d:isa( Promise.Deferred ) )
			local res = outcome( d )
			assert.are.equal( res.val[1], 5 )
			assert.are.equal( res.err, nil )
		end)

		it( "passes every argument", function()
			local d = maybeDeferred( function( ... ) return select( '#', ... ) end, 1, nil, 3 )
			assert.are.equal( outcome( d ).val[1], 3 )
		end)

		it( "returns a Deferred the function returns", function()
			local inner = Promise.Deferred:new()
			local d = maybeDeferred( function() return inner end )
			assert.are.equal( d, inner )
			local res = outcome( d )
			assert.are.equal( res.val, nil )
			inner:callback( "later" )
			assert.are.equal( res.val[1], "later" )
		end)

		it( "rejects with the error the function raises", function()
			local d = maybeDeferred( function() error( "boom" ) end )
			local res = outcome( d )
			assert.are.equal( res.val, nil )
			assert.is_truthy( res.err[1]:find( "boom", 1, true ) )
		end)

		it( "rejects with a raised table as it is", function()
			local e = { message="boom" }
			local d = maybeDeferred( function() error( e ) end )
			assert.are.equal( outcome( d ).err[1], e )
		end)

	end)


end)
