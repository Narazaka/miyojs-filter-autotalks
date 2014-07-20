### (C) 2014 Narazaka : Licensed under The MIT License - http://narazaka.net/license/MIT?2014 ###

if require?
	PartPeriod = require 'partperiod'

unless MiyoFilters?
	MiyoFilters = {}

MiyoFilters.autotalks_caller = (argument, request, id, stash) ->
	unless @variables_temporary.autotalks_caller?
		@variables_temporary.autotalks_caller = {}
		unless @variables_temporary.autotalks_caller[id]
			@variables_temporary.autotalks_caller[id] = 0
	id = argument.autotalks_caller.id
	count = argument.autotalks_caller.count || 0
	fluctuation = argument.autotalks_caller.fluctuation || 0
	count = count - fluctuation + Math.round(Math.random() * fluctuation * 2)
	stash = {} if not stash?
	stash.autotalks_trigger = count <= @variables_temporary.autotalks_caller[id]
	if stash.autotalks_trigger
		@variables_temporary.autotalks_caller[id] = 0
	else
		@variables_temporary.autotalks_caller[id]++
	@call_id id, request, stash

MiyoFilters.autotalks = (argument, request, id, stash) ->
	unless @variables.autotalks?
		@variables.autotalks = {once: {}}
	unless @variables_temporary.autotalks?
		@variables_temporary.autotalks = {once_per_boot: {}, chain: {}, chain_position: null, justtime: {}}
	# justtimeであるsetをキャッシュ
	unless @variables_temporary.autotalks.justtime[id]?
		MiyoFilters.autotalks.trace_justtime_talks.call @, argument.autotalks, id
	# 発話可否
	if not stash? or not stash.autotalks_trigger? or stash.autotalks_trigger
		# 発話可
		# chainがある場合、このIDでのchainが終わった場合以外はchainの結果
		if (Object.keys(@variables_temporary.autotalks.chain).length > 0)
			if @variables_temporary.autotalks.chain[id]?
				result = MiyoFilters.autotalks.run_chain.call @, request, id, stash
				if result?
					return result
			else
				return
		# chainがなかったか終わった場合
		# すべてのautotalks
		autotalks = argument.autotalks
	else
		# 発話不可 justtimeのみ発話可能
		if @variables_temporary.autotalks.justtime[id]?
			# justtimeであるautotalks
			autotalks = @variables_temporary.autotalks.justtime[id]
		else
			return
	# 条件を満たすset
	use_sets = MiyoFilters.autotalks.choose_talks.call @, autotalks, request, id
	return MiyoFilters.autotalks.select_talks.call @, use_sets, request, id, stash

MiyoFilters.autotalks.trace_justtime_talks = (autotalks, id) ->
	# justtime属性のあるものをまとめるハッシュに登録
	if autotalks?
		unless @variables_temporary.autotalks.justtime[id]?
			@variables_temporary.autotalks.justtime[id] = []
		for set in autotalks
			if set.when?
				if set.when.justtime? && set.when.justtime - 1 == 0
					@variables_temporary.autotalks.justtime[id].push set

MiyoFilters.autotalks.run_chain = (request, id, stash) ->
	# chainのインデックスをインクリメント
	@variables_temporary.autotalks.chain_position++
	# インクリメント後のエントリがあれば返し、なければキャッシュデータを消去
	result = @variables_temporary.autotalks.chain[id].chain[@variables_temporary.autotalks.chain_position]
	if result?
		return @call_value result, request, id, stash
	else
		delete @variables_temporary.autotalks.chain[id]
		@variables_temporary.autotalks.chain_position = null
		return

MiyoFilters.autotalks.choose_talks = (autotalks, request, id) ->
	# 現在の条件に合致するエントリ=可能エントリを抽出
	# whenの処理
	date = new Date()
	use_sets = {}
	if autotalks?
		for set in autotalks
			use = true
			priority = 0
			if set.when?
				if use and set.when.once?
					use = false if @variables.autotalks.once[set.when.once]?
				if use and set.when.once_per_boot?
					use = false if @variables_temporary.autotalks.once_per_boot[set.when.once_per_boot]?
				if use and set.when.period?
					unless set.when._period?
						code = set.when.period.replace /@([\dT*\/.:-]+)@/g, '''(new PartPeriod('$1')).includes(date)'''
						set.when._period = new Function 'PartPeriod', 'date', 'request', 'id', 'return ' + code
					use = false unless set.when._period.call @, PartPeriod, date, request, id
				if use and set.when.condition?
					unless set.when._condition?
						set.when._condition = new Function 'request', 'id', 'return ' + set.when.condition
					use = false unless set.when._condition.call @, request, id
			if use
				priority = set.priority if set.priority?
				throw "priority must be numeric: #{priority}" if isNaN priority
				use_sets[priority] = [] unless use_sets[priority]?
				use_sets[priority].push set
	use_sets

MiyoFilters.autotalks.select_talks = (use_sets, request, id, stash) ->
	# 可能エントリから1つを選ぶ
	# biasの処理
	# propertyの大きいものからイテレート
	for priority in (Object.keys(use_sets).sort (a, b) -> b - a)
		# bias計算をキャッシュ
		bias_sum = 0
		biases = []
		for set in use_sets[priority]
			bias = 1
			if set.bias?
				unless set._bias?
					set._bias = new Function 'request', 'id', 'return ' + set.bias
				try
					bias = set._bias.call @, request, id
				catch error
					throw 'bias execute error: ' + error
			throw "bias must be numeric >= 0: #{bias}" if (isNaN bias) or (bias < 0)
			bias_sum += bias
			biases.push bias
		# 現在のpriorityのエントリ群の中からランダムにエントリを選ぶ
		while use_sets[priority].length
			select_position = Math.random() * bias_sum
			position = 0
			for bias, index in biases
				position += bias
				if select_position < position
					set = use_sets[priority][index]
					break
			result = null
			# エントリのchainまたはdoを選択し、実行結果を取得
			if set.chain?
				@variables_temporary.autotalks.chain_position = -1
				@variables_temporary.autotalks.chain[id] = set
				result = MiyoFilters.autotalks.run_chain.call @, request, id, stash
			else
				result = @call_entry set.do, request, id, stash
			# 結果が空ならそのエントリーを除いて再選択する
			if not result?
				bias_sum -= biases[index]
				biases.splice index, 1
				use_sets[priority].splice index, 1
			else
				# onceのフラグを登録
				if set.when?
					if set.when.once?
						@variables.autotalks.once[set.when.once] = 1
					if set.when.once_per_boot?
						@variables_temporary.autotalks.once_per_boot[set.when.once_per_boot] = 1
				break
		break if result?
	result

if module? and module.exports?
	module.exports = MiyoFilters
