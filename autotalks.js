// Generated by CoffeeScript 1.7.1

/* (C) 2014 Narazaka : Licensed under The MIT License - http://narazaka.net/license/MIT?2014 */
var MiyoFilters, PartPeriod;

if (typeof require !== "undefined" && require !== null) {
  PartPeriod = require('partperiod');
}

if (typeof MiyoFilters === "undefined" || MiyoFilters === null) {
  MiyoFilters = {};
}

MiyoFilters.autotalks_caller = function(argument, request, id, stash) {
  var count, fluctuation;
  if (this.variables_temporary.autotalks_caller == null) {
    this.variables_temporary.autotalks_caller = {};
    if (!this.variables_temporary.autotalks_caller[id]) {
      this.variables_temporary.autotalks_caller[id] = 0;
    }
  }
  id = argument.autotalks_caller.id;
  count = argument.autotalks_caller.count || 0;
  fluctuation = argument.autotalks_caller.fluctuation || 0;
  count = count - fluctuation + Math.round(Math.random() * fluctuation * 2);
  if (stash == null) {
    stash = {};
  }
  stash.autotalks_trigger = count <= this.variables_temporary.autotalks_caller[id];
  if (stash.autotalks_trigger) {
    this.variables_temporary.autotalks_caller[id] = 0;
  } else {
    this.variables_temporary.autotalks_caller[id]++;
  }
  return this.call_id(id, request, stash);
};

MiyoFilters.autotalks = function(argument, request, id, stash) {
  var autotalks, result, use_sets;
  if (this.variables.autotalks == null) {
    this.variables.autotalks = {
      once: {}
    };
  }
  if (this.variables_temporary.autotalks == null) {
    this.variables_temporary.autotalks = {
      once_per_boot: {},
      chain: {},
      chain_position: null,
      justtime: {}
    };
  }
  if (this.variables_temporary.autotalks.justtime[id] == null) {
    MiyoFilters.autotalks.trace_justtime_talks.call(this, argument.autotalks, id);
  }
  if ((stash == null) || (stash.autotalks_trigger == null) || stash.autotalks_trigger) {
    if (Object.keys(this.variables_temporary.autotalks.chain).length > 0) {
      if (this.variables_temporary.autotalks.chain[id] != null) {
        result = MiyoFilters.autotalks.run_chain.call(this, request, id, stash);
        if (result != null) {
          return result;
        }
      } else {
        return;
      }
    }
    autotalks = argument.autotalks;
  } else {
    if (this.variables_temporary.autotalks.justtime[id] != null) {
      autotalks = this.variables_temporary.autotalks.justtime[id];
    } else {
      return;
    }
  }
  use_sets = MiyoFilters.autotalks.choose_talks.call(this, autotalks, request, id);
  return MiyoFilters.autotalks.select_talks.call(this, use_sets, request, id, stash);
};

MiyoFilters.autotalks.trace_justtime_talks = function(autotalks, id) {
  var set, _i, _len, _results;
  if (autotalks != null) {
    if (this.variables_temporary.autotalks.justtime[id] == null) {
      this.variables_temporary.autotalks.justtime[id] = [];
    }
    _results = [];
    for (_i = 0, _len = autotalks.length; _i < _len; _i++) {
      set = autotalks[_i];
      if (set.when != null) {
        if ((set.when.justtime != null) && set.when.justtime - 1 === 0) {
          _results.push(this.variables_temporary.autotalks.justtime[id].push(set));
        } else {
          _results.push(void 0);
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }
};

MiyoFilters.autotalks.run_chain = function(request, id, stash) {
  var result;
  this.variables_temporary.autotalks.chain_position++;
  result = this.variables_temporary.autotalks.chain[id].chain[this.variables_temporary.autotalks.chain_position];
  if (result != null) {
    return this.call_value(result, request, id, stash);
  } else {
    delete this.variables_temporary.autotalks.chain[id];
    this.variables_temporary.autotalks.chain_position = null;
  }
};

MiyoFilters.autotalks.choose_talks = function(autotalks, request, id) {
  var code, date, priority, set, use, use_sets, _i, _len;
  date = new Date();
  use_sets = {};
  if (autotalks != null) {
    for (_i = 0, _len = autotalks.length; _i < _len; _i++) {
      set = autotalks[_i];
      use = true;
      priority = 0;
      if (set.when != null) {
        if (use && (set.when.once != null)) {
          if (this.variables.autotalks.once[set.when.once] != null) {
            use = false;
          }
        }
        if (use && (set.when.once_per_boot != null)) {
          if (this.variables_temporary.autotalks.once_per_boot[set.when.once_per_boot] != null) {
            use = false;
          }
        }
        if (use && (set.when.period != null)) {
          if (set.when._period == null) {
            code = set.when.period.replace(/@([\dT*\/.:-]+)@/g, '(new PartPeriod(\'$1\')).includes(date)');
            set.when._period = new Function('PartPeriod', 'date', 'request', 'id', 'return ' + code);
          }
          if (!set.when._period.call(this, PartPeriod, date, request, id)) {
            use = false;
          }
        }
        if (use && (set.when.condition != null)) {
          if (set.when._condition == null) {
            set.when._condition = new Function('request', 'id', 'return ' + set.when.condition);
          }
          if (!set.when._condition.call(this, request, id)) {
            use = false;
          }
        }
      }
      if (use) {
        if (set.priority != null) {
          priority = set.priority;
        }
        if (isNaN(priority)) {
          throw "priority must be numeric: " + priority;
        }
        if (use_sets[priority] == null) {
          use_sets[priority] = [];
        }
        use_sets[priority].push(set);
      }
    }
  }
  return use_sets;
};

MiyoFilters.autotalks.select_talks = function(use_sets, request, id, stash) {
  var bias, bias_sum, biases, error, index, position, priority, result, select_position, set, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
  _ref = Object.keys(use_sets).sort(function(a, b) {
    return b - a;
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    priority = _ref[_i];
    bias_sum = 0;
    biases = [];
    _ref1 = use_sets[priority];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      set = _ref1[_j];
      bias = 1;
      if (set.bias != null) {
        if (set._bias == null) {
          set._bias = new Function('request', 'id', 'return ' + set.bias);
        }
        try {
          bias = set._bias.call(this, request, id);
        } catch (_error) {
          error = _error;
          throw 'bias execute error: ' + error;
        }
      }
      if ((isNaN(bias)) || (bias < 0)) {
        throw "bias must be numeric >= 0: " + bias;
      }
      bias_sum += bias;
      biases.push(bias);
    }
    while (use_sets[priority].length) {
      select_position = Math.random() * bias_sum;
      position = 0;
      for (index = _k = 0, _len2 = biases.length; _k < _len2; index = ++_k) {
        bias = biases[index];
        position += bias;
        if (select_position < position) {
          set = use_sets[priority][index];
          break;
        }
      }
      result = null;
      if (set.chain != null) {
        this.variables_temporary.autotalks.chain_position = -1;
        this.variables_temporary.autotalks.chain[id] = set;
        result = MiyoFilters.autotalks.run_chain.call(this, request, id, stash);
      } else {
        result = this.call_entry(set["do"], request, id, stash);
      }
      if (result == null) {
        bias_sum -= biases[index];
        biases.splice(index, 1);
        use_sets[priority].splice(index, 1);
      } else {
        if (set.when != null) {
          if (set.when.once != null) {
            this.variables.autotalks.once[set.when.once] = 1;
          }
          if (set.when.once_per_boot != null) {
            this.variables_temporary.autotalks.once_per_boot[set.when.once_per_boot] = 1;
          }
        }
        break;
      }
    }
    if (result != null) {
      break;
    }
  }
  return result;
};

if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
  module.exports = MiyoFilters;
}

//# sourceMappingURL=autotalks.map
