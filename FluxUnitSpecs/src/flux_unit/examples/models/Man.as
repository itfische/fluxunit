package flux_unit.examples.models {
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.utils.setTimeout;
  
  import mx.containers.VBox;
  import mx.core.Container;
  
  public class Man {
    public var decrement_luck:Function = null;
    public var luck:Function = null;
    public var render:Function = null;
    public var askPermission:Function = null;
    public function Man(options:Object) {
      var luck:int = options.luck;
      
      this.decrement_luck = function(delta:int):void {
        luck = Math.max(0, luck - delta);
      };
      this.luck = function():int {
        return luck;
      };
      this.render = function(node:Container):Container {
        var man:VBox = new VBox();
        var hair:VBox = new VBox();
        
        man.addChild(hair);
        node.addChild(man);

        man.data = {className: 'man'};
        hair.data = {className: 'hair'};
        
        man.addEventListener(MouseEvent.CLICK, function(e:Event):void {
          man.removeChild(hair);
        });
        return man;
      };
      this.askPermission = function(question:String, response:Function):void {
        if (question == 'Can I have dessert?') {
          setTimeout(function():void { response('Yes'); }, 5000);
        }
        else if (question == 'Can I go outside and play?') {
          setTimeout(function():void { response('Yes'); }, 1000);
        }
        else {
          setTimeout(function():void { response('No'); }, 3000);
        }
      }
    }
  }
}