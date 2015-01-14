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


end)
