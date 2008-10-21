import flux_unit.Flux;

Flux.Matchers['have'] = function():Object {
  return {
    match: function(expected:*, actual:*):Boolean {
      return Flux.selectAll(expected, actual).length > 0;
    },
    failure_message: function(expected:*, actual:*, not:Boolean):String {
      return 'expected ' + actual + (not ? ' to not have ' : ' to have ') + expected;
    }
  }
}
