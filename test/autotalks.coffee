chai = require 'chai'
chai.should()
expect = chai.expect
sinon = require 'sinon'
property_filter = require 'miyojs-filter-property'
MiyoFilters = require '../autotalks.js'

describe 'caller', ->
	ms = null
	request = null
	id = null
	to_id = null
	random = null
	filter = MiyoFilters.autotalks_caller
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_id = sinon.stub()
		ms.call_id.returnsArg 0
		request = sinon.stub()
		id = 'OnTest'
		to_id = 'OnTest2'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
	it 'should work with only id', ->
		argument =
			autotalks_caller:
				id: to_id
		random.returns 0
		filter.call(ms, argument, request, id)
		stash = {autotalks_trigger: true}
		ms.call_id.getCall(0).args[2].should.be.deep.equal stash
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(1).args[2].should.be.deep.equal stash
	it 'should work with count', ->
		argument =
			autotalks_caller:
				id: to_id
				count: 2
		random.returns 0
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(0).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(1).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(2).args[2].should.be.deep.equal autotalks_trigger: true
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(3).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(4).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(5).args[2].should.be.deep.equal autotalks_trigger: true
	it 'should work with count and fluctuation', ->
		argument =
			autotalks_caller:
				id: to_id
				count: 5
				fluctuation: 2
		random.returns 0
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(0).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(1).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(2).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(3).args[2].should.be.deep.equal autotalks_trigger: true
		random.returns 0.7
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(4).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(5).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(6).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(7).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(8).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(9).args[2].should.be.deep.equal autotalks_trigger: false
		filter.call(ms, argument, request, id)
		ms.call_id.getCall(10).args[2].should.be.deep.equal autotalks_trigger: true

describe 'do with no "when"', ->
	ms = null
	request = null
	id = null
	random = null
	filter = MiyoFilters.autotalks
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_entry = sinon.stub()
		ms.call_entry.returnsArg 0
		request = sinon.stub()
		id = 'OnTest'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
	it 'should work with no other properties', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.deep.equal 'do 1'
	it 'should work with bias', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
					'bias.jse': '1 + 1'
				}
				{
					do: 'do 3'
					bias: 7
				}
			]
		random.returns 0.3
		filter.call(ms, argument, request, id).should.deep.equal 'do 3'
		random.returns 0.09
		filter.call(ms, argument, request, id).should.deep.equal 'do 1'
		random.returns 0.1
		filter.call(ms, argument, request, id).should.deep.equal 'do 2'
		random.returns 0.29
		filter.call(ms, argument, request, id).should.deep.equal 'do 2'
	it 'should work with bias with null', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: null
					bias: 2
				}
				{
					do: 'do 3'
					bias: 7
				}
			]
		random.returns 0.3
		filter.call(ms, argument, request, id).should.deep.equal 'do 3'
		random.returns 0.09
		filter.call(ms, argument, request, id).should.deep.equal 'do 1'
		random.returns 0.1
		filter.call(ms, argument, request, id).should.deep.equal 'do 1'
		random.returns 0.29
		filter.call(ms, argument, request, id).should.deep.equal 'do 3'
	it 'should throw with wrong bias', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
					'bias.jse': '"a"'
				}
				{
					do: 'do 3'
					bias: 7
				}
			]
		random.returns 0.3
		(-> filter.call ms, argument, request, id).should.throw /bias must be numeric/
	it 'should throw with wrong bias 2', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
					'bias.jse': 'a'
				}
				{
					do: 'do 3'
					bias: 7
				}
			]
		random.returns 0.3
		(-> filter.call ms, argument, request, id).should.throw /bias execute error/
	it 'should work with priority', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
					priority: 1
					bias: 3
				}
				{
					do: 'do 3'
					priority: 1
					bias: 7
				}
			]
		random.returns 0.3
		filter.call(ms, argument, request, id).should.deep.equal 'do 3'
		random.returns 0.0
		filter.call(ms, argument, request, id).should.deep.equal 'do 2'
		random.returns 0.29
		filter.call(ms, argument, request, id).should.deep.equal 'do 2'
	it 'should work with priority that has null', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
					priority: 1
					bias: 3
				}
				{
					do: 'do 3'
					priority: 1
					bias: 7
				}
				{
					do: null
					priority: 2
					bias: 7
				}
			]
		random.returns 0.3
		filter.call(ms, argument, request, id).should.deep.equal 'do 3'
		random.returns 0.0
		filter.call(ms, argument, request, id).should.deep.equal 'do 2'
		random.returns 0.29
		filter.call(ms, argument, request, id).should.deep.equal 'do 2'
	it 'should throw with wrong priority', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
				}
				{
					do: 'do 2'
					priority: 'a'
					bias: 3
				}
				{
					do: 'do 3'
					priority: 1
					bias: 7
				}
			]
		random.returns 0.3
		(-> filter.call ms, argument, request, id).should.throw /numeric/

describe 'chain with no "when"', ->
	ms = null
	request = null
	id = null
	random = null
	filter = MiyoFilters.autotalks
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_value = sinon.stub()
		ms.call_value.returnsArg 0
		request = sinon.stub()
		id = 'OnTest'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
	it 'should work with no other properties', ->
		id2 = 'OnTest2'
		argument =
			autotalks: [
				{
					chain: [ 'chain 1-1', 'chain 1-2' ]
				}
				{
					chain: [ 'chain 2' ]
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.deep.equal 'chain 1-1'
		random.returns 0.7
		filter.call(ms, argument, request, id).should.deep.equal 'chain 1-2'
		filter.call(ms, argument, request, id).should.deep.equal 'chain 2'
		filter.call(ms, argument, request, id).should.deep.equal 'chain 2'
		random.returns 0
		filter.call(ms, argument, request, id).should.deep.equal 'chain 1-1'
		expect(filter.call(ms, argument, request, id2)).is.undefined
		filter.call(ms, argument, request, id).should.deep.equal 'chain 1-2'

describe 'do with when.once/when.once_per_boot', ->
	ms = null
	request = null
	id = null
	random = null
	filter = MiyoFilters.autotalks
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_entry = sinon.stub()
		ms.call_entry.returnsArg 0
		request = sinon.stub()
		id = 'OnTest'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
	it 'should work', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
					when:
						once: 'onceid'
				}
				{
					do: 'do 2'
					when:
						once: 'onceid'
				}
				{
					do: 'do 3'
					when:
						once: 'onceid2'
				}
				{
					do: 'do 4'
					when:
						once_per_boot: 'onceid'
				}
				{
					do: 'do 5'
					when:
						once_per_boot: 'onceid2'
				}
				{
					do: 'do 6'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do 1'
		filter.call(ms, argument, request, id).should.be.equal 'do 3'
		filter.call(ms, argument, request, id).should.be.equal 'do 4'
		filter.call(ms, argument, request, id).should.be.equal 'do 5'
		filter.call(ms, argument, request, id).should.be.equal 'do 6'
		filter.call(ms, argument, request, id).should.be.equal 'do 6'

describe 'do with when.period', ->
	ms = null
	request = null
	id = null
	random = null
	clock = null
	filter = MiyoFilters.autotalks
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_entry = sinon.stub()
		ms.call_entry.returnsArg 0
		request = sinon.stub()
		clock = sinon.useFakeTimers()
		id = 'OnTest'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
		clock.restore()
	it 'should work with .jse', ->
		argument =
			autotalks: [
				{
					do: 'do when'
					when:
						'period.jse': '@1970-*-*/1970-*-*@ && @*:*:0/*:*:1@'
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do when'
	it 'should work with .js', ->
		argument =
			autotalks: [
				{
					do: 'do when'
					when:
						'period.js': 'return @1970-*-*/1970-*-*@ && @*:*:0/*:*:1@'
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do when'
	it 'should work with .coffee', ->
		argument =
			autotalks: [
				{
					do: 'do when'
					when:
						'period.coffee': '@1970-*-*/1970-*-*@ && @*:*:0/*:*:1@'
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do when'
	it 'should work with .* extra stash', ->
		argument =
			autotalks: [
				{
					do: 'do when'
					when:
						'period.js': '''return (stash.dummy == 'dummy') && (new PartPeriod('1970-*-*/1970-*-*')).includes(date)'''
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id, dummy: 'dummy').should.be.equal 'do when'
	it 'should throw on wrong .*', ->
		argument =
			autotalks: [
				{
					do: 'do when'
					when:
						'period.jse': 'return @1970-*-*/1970-*-*@ && @*:*:0/*:*:1@'
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		(-> filter.call(ms, argument, request, id)).should.throw /period execute error/
	it 'should work', ->
		argument =
			autotalks: [
				{
					do: 'do single'
					when:
						'period.jse': '@*:0:*/*:0:*@'
				}
				{
					do: 'do and'
					when:
						'period.jse': '@1970-*-*/1970-*-*@ && @*:*:0/*:*:1@'
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do single'
		random.returns 0.5
		filter.call(ms, argument, request, id).should.be.equal 'do and'
		random.returns 0.9
		filter.call(ms, argument, request, id).should.be.equal 'do always'
		clock.tick 2 * 1000
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do single'
		random.returns 0.5
		filter.call(ms, argument, request, id).should.be.equal 'do always'
		random.returns 0.9
		filter.call(ms, argument, request, id).should.be.equal 'do always'
		clock.tick 58 * 1000
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do and'
		random.returns 0.5
		filter.call(ms, argument, request, id).should.be.equal 'do always'
		random.returns 0.9
		filter.call(ms, argument, request, id).should.be.equal 'do always'

describe 'do with when.condition', ->
	ms = null
	request = null
	id = null
	random = null
	filter = MiyoFilters.autotalks
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_entry = sinon.stub()
		ms.call_entry.returnsArg 0
		request = sinon.stub()
		id = 'OnTest'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
	it 'should throw on wrong .*', ->
		argument =
			autotalks: [
				{
					do: 'do when'
					when:
						'condition.jse': 'a'
				}
				{
					do: 'do always'
				}
			]
		random.returns 0
		(-> filter.call(ms, argument, request, id)).should.throw /condition execute error/
	it 'should work', ->
		argument =
			autotalks: [
				{
					do: 'do false'
					when:
						'condition.jse': 'false'
				}
				{
					do: 'do true'
					when:
						'condition.jse': 'true'
				}
				{
					do: 'do OnTest2'
					when:
						'condition.jse': 'id == "OnTest2"'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do true'
		random.returns 0.9
		filter.call(ms, argument, request, id).should.be.equal 'do true'
		random.returns 0.9
		filter.call(ms, argument, request, 'OnTest2').should.be.equal 'do OnTest2'

describe 'autotalk called with trigger', ->
	ms = null
	request = null
	id = null
	random = null
	filter = MiyoFilters.autotalks
	beforeEach ->
		ms = sinon.stub()
		ms.filters =
			property_handler: property_filter.property_handler
		property_filter.property_initialize.call ms,
			property_initialize:
				handlers: ['coffee', 'jse', 'js']
		ms.variables = {}
		ms.variables_temporary = {}
		ms.call_entry = sinon.stub()
		ms.call_entry.returnsArg 0
		request = sinon.stub()
		id = 'OnTest'
		random = sinon.stub Math, 'random'
	afterEach ->
		random.restore()
	it 'should work on no trigger', ->
		argument =
			autotalks: [
				{
					do: 'do'
				}
			]
		random.returns 0
		filter.call(ms, argument, request, id).should.be.equal 'do'
	it 'should work on true trigger', ->
		argument =
			autotalks: [
				{
					do: 'do'
				}
			]
		stash =
			autotalks_trigger: true
		random.returns 0
		filter.call(ms, argument, request, id, stash).should.be.equal 'do'
	it 'should not work on false trigger', ->
		argument =
			autotalks: [
				{
					do: 'do'
				}
			]
		stash =
			autotalks_trigger: false
		random.returns 0
		expect(filter.call(ms, argument, request, id, stash)).be.undefined
	it 'should work with justtime and false trigger', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
					priority: 1
				}
				{
					do: 'do justtime'
					when:
						justtime: 1
				}
			]
		stash =
			autotalks_trigger: false
		random.returns 0
		filter.call(ms, argument, request, id, stash).should.be.equal 'do justtime'
	it 'should work with justtime and true trigger', ->
		argument =
			autotalks: [
				{
					do: 'do 1'
					priority: 1
				}
				{
					do: 'do justtime'
					when:
						justtime: 1
				}
			]
		stash =
			autotalks_trigger: true
		random.returns 0
		filter.call(ms, argument, request, id, stash).should.be.equal 'do 1'
