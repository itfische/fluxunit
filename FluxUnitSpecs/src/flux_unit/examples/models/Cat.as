package flux_unit.examples.models {
  public class Cat {
    public var cross_path:Function = null;
    public function Cat(options:Object) {
      this.cross_path = function(man:Man):void {
        if (options.color == 'black') man.decrement_luck(5);
      };
    }
  }
}