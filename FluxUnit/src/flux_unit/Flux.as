package flux_unit {
  import flash.events.TextEvent;
  import flash.utils.clearTimeout;
  import flash.utils.setTimeout;
  
  import mx.containers.VBox;
  import mx.controls.Text;
  import mx.core.Container;
  import mx.core.IDataRenderer;
  import mx.core.UIComponent;
  
  public class Flux {
    
    public function Flux(target:Object) {
      if (!topNode) throw new Error('You must call Flux.setRoot before calling new Flux');
      mixin(target, [Specifications, Matchers]);

      var describe:VBox = new VBox();
      if (!Flux.setupStatus) {
        var status:Text = new Text();
        status.text = 'Status';
      }
      var befores:VBox = new VBox();
      var its:VBox = new VBox();
      var describes:VBox = new VBox();
      var afters:VBox = new VBox();

      if (!Flux.setupStatus) describe.addChild(status);
      describe.addChild(befores);
      describe.addChild(its);
      describe.addChild(describes);
      describe.addChild(afters);

      Flux.topNode.addChild(describe);
      describe.styleName = 'describe';
      if (!Flux.setupStatus) status.styleName = 'status';
      describe.percentWidth = 100;
      describes.percentWidth = 100;
      its.percentWidth = 100;
      Flux.setClass(describe,'describe');
      if (!Flux.setupStatus) Flux.setClass(status, 'status');
      Flux.setClass(befores, 'befores');
      Flux.setClass(its, 'its');
      Flux.setClass(describes, 'describes');
      Flux.setClass(afters, 'afters');
      
      Flux.setupStatus = true;
    }

    public function Unit(fn:Function):void {
      Flux.Specifications.context.push(Flux.child(Flux.topNode, 'describe'));
      fn();
      Flux.Specifications.context.pop();
    }
    
    public static function Run():void {
      Flux.setEventsAndBehaviorsAndRun();
    }
    
    private static var topNode:Container;
    public static function setRoot(node:Container):void {
      if (Flux.topNode) return;
      Flux.topNode = node;
    }
    
    private static var setupStatus:Boolean = false;
    
    private static var q:Array = [];
    private static function queue(fn:Function):void {
      q.push(fn);
    }
    private static function dequeue():void {
      if (q.length) q.pop()();
    }
    private static function dequeueAll():void {
      if (q.length) {
        q.shift()();
        setTimeout(Flux.dequeueAll, 20);
      }
    }
    
    private static function mixin(inst:Object, objs:Array):void {
      for (var i:int = 0; i < objs.length; i++) {
        var target:Object = (objs[i].target && objs[i].skip ? objs[i].target : objs[i]);
        var skip:Object = (objs[i].target && objs[i].skip ? objs[i].skip : {});
        for (var j:String in target) {
          if (inst[j] || skip[j]) continue;
          inst[j] = target[j];
        }
      }
    }

    private static var Specifications:Object = {
      context: [],

      describe: function(name:String, fn:Function):void {
        var describe:VBox = new VBox();
        var text:Text = new Text();
        text.text = name;
        var befores:VBox = new VBox();
        var its:VBox = new VBox();
        var describes:VBox = new VBox();
        var afters:VBox = new VBox();
        
        describe.addChild(text);
        describe.addChild(befores);
        describe.addChild(its);
        describe.addChild(describes);
        describe.addChild(afters);
        
        Flux.child(this.context[this.context.length-1], 'describes').addChild(describe);
        describe.styleName = 'describe';
        describe.percentWidth = 100;
        describes.percentWidth = 100;
        its.percentWidth = 100;
        Flux.setClass(describe, 'describe');
        Flux.setClass(befores, 'befores');
        Flux.setClass(its, 'its');
        Flux.setClass(describes, 'describes');
        Flux.setClass(afters, 'afters');

        this.context.push(describe);
        fn();
        this.context.pop();
      },

      it: function(name:String, fn:Function):Object {
        var it:VBox = new VBox();
        var text:Text = new Text();
        text.text = 'it ' + name;
        it.addChild(text);
        
        Flux.child(this.context[this.context.length-1], 'its').addChild(it);
        it.percentWidth = 100;
        text.percentWidth = 100;
        Flux.setClass(it, 'it');
        it.data.fluxUnitFunc = fn;
        it.data.specObject = this;
        return {
          but_times_out_after: function(timeout:int):void {
            it.data.timeout = timeout;
          }
        };
      },

      before: function(fn:Function):void {
        var before:VBox = new VBox();

        Flux.child(this.context[this.context.length-1], 'befores').addChild(before);
        Flux.setClass(before, 'before');
        before.data.fluxUnitFunc = fn;
      },

      after: function(fn:Function):void {
        var after:VBox = new VBox();

        Flux.child(this.context[this.context.length-1], 'afters').addChild(after);
        Flux.setClass(after, 'after');
        after.data.fluxUnitFunc = fn;
      }
    }
    
    public static var Matchers:Object = {
      expect: function(actual:*):Object {
        return {
          to: function(matcher:Object, expected:* = null, not:Boolean = false):void {
            var matched:Boolean = matcher.match(expected, actual);
            if (not ? matched : !matched) {
              throw(matcher.failure_message(expected, actual, not));
            }
          },
          
          to_not: function(matcher:Object, expected:* = null):void {
            this.to(matcher, expected, true);
          }
        }
      },
      
      // Matchers are functions returning objects because the flex compiler 
      // doesn't let this.equal compile for dynamic properties, only for dynamic 
      // functions in a dynamic class
      equal: function():Object { return {
          match: function(expected:*, actual:*):Boolean {
            if (expected is Array) {
              for (var i:int = 0; i < actual.length; i++)
                if (!Flux.Matchers.equal().match(expected[i], actual[i])) return false;
              return actual.length == expected.length;
            }
            else if (expected is Boolean) {
              return expected == actual;
            }
            else if (expected is Number) {
              return expected == actual;
            }
            else if (expected is String) {
              return expected == actual;
            }
            else if (expected is Object) {
              for (var key:String in expected) // TODO: this should be recursive?
                if (expected[key] != actual[key]) return false;
              for (key in actual)
                if (actual[key] != expected[key]) return false;
              return true;
            } 
            else {
              return expected == actual;
            }
          },
          
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + actual + (not ? ' to not equal ' : ' to equal ') + expected;
          }
        }
      },
      
      match: function():Object { 
        return {
          match: function(expected:*, actual:*):Boolean {
            if (expected.constructor == RegExp)
              return expected.exec(actual.toString());
            else
              return actual.indexOf(expected) > -1;
          },
          
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected "' + actual + (not ? '" to not match "' : '" to match "') + expected + '"';
          }
        }
      },
      
      be_empty: function():Object { 
        return {
          match: function(expected:*, actual:*):Boolean {
            if (actual.length == undefined) throw(actual.toString() + " does not respond to length");
            
            return actual.length == 0;
          },
          
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + (not ? '[] to not be empty' : actual + ' to be empty');
          }
        }
      },
  
      have_length: function():Object {
        return {
          match: function(expected:*, actual:*):Boolean {
            if (actual.length == undefined) throw(actual.toString() + " does not respond to length");
    
            return actual.length == expected;
          },
    
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + actual + (not ? ' to not' : ' to') + ' have length ' + expected;
          }
        }
      },
  
      be_null: function():Object {
        return {
          match: function(expected:*, actual:*):Boolean {
            return actual == null;
          },
    
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + actual + (not ? ' to not be null' : ' to be null');
          }
        }
      },
  
      be_undefined: function():Object {
        return {
          match: function(expected:*, actual:*):Boolean {
            return actual == undefined;
          },
    
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + actual + (not ? ' to not be undefined' : ' to be undefined');
          }
        }
      },
  
      be_true: function():Object {
        return {
          match: function(expected:*, actual:*):Boolean {
            return actual;
          },
    
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + actual + (not ? ' to not be true' : ' to be true');
          }
        }
      },
  
      be_false: function():Object {
        return {
          match: function(expected:*, actual:*):Boolean {
            return !actual;
          },
    
          failure_message: function(expected:*, actual:*, not:Boolean):String {
            return 'expected ' + actual + (not ? ' to not be false' : ' to be false');
          }
        }
      }
    }
    
    private static function trigger(node:UIComponent, eventName:String, error:* = null):void {
      var e:TextEvent = new TextEvent(eventName);
      if (error) e.text = error;
      node.dispatchEvent(e);
    }
    
    private static function bind(node:UIComponent, eventName:String, fn:Function):void {
      node.addEventListener(eventName, function(event:TextEvent):void { fn(event.text); });
    }
    
    private static function getDescribe():Array {
      return Flux.select(Flux.topNode.getChildren(), 'describe');
    }
    
    private static function getAllChildren(node:UIComponent):Array {
      if (node is Container) {
        var a:Array = [node];
        (node as Container).getChildren().forEach(function(n:UIComponent, i:int, arr:Array):void {
          a.concat(n);
          Flux.getAllChildren(n).forEach(function(n1:UIComponent, i1:int, arr1:Array):void { a.push(n1); });
        });
        return a;
      }
      else {
        return [node];
      }
    }
    
    private static function setClass(node:IDataRenderer, className:String):void {
      if (!node.data) node.data = {className: className};
      else node.data.className = className;
    }
    
    private static function child(node:Container, selector:String):Container {
      var child:Container = null;
      var children:Array = Flux.children(node, selector);
      if (children.length) child = children[children.length - 1];
      return child;
    }
    
    private static function children(node:Container, selector:String):Array {
      return select(node.getChildren(), selector);
    }
    
    private static function select(nodes:Array, selector:String):Array {
      return (nodes.filter(function(n:*, i:int, a:Array):Boolean { if (n is IDataRenderer && (n as IDataRenderer).data) return (n as IDataRenderer).data.className == selector; else return false; }) || []);
    }
    
    private static function selectStyleName(nodes:Array, styleName:String):Array {
      return nodes.filter(function(n:*, i:int, a:Array):Boolean { if (n is UIComponent) return (n as UIComponent).styleName == styleName; else return false; });
    }
    
    public static function selectAll(selector:String, node:Container = null):Array {
      return Flux.selectAllArray(selector, Flux.getAllChildren(node ? node : Flux.topNode));
    }
    
    private static function selectAllArray(selector:String, nodes:Array):Array {
      return Flux.select(nodes, selector);
    }
    
    private static function selectAllOfStyle(styleName:String):Array {
      return Flux.selectAllOfStyleArray(styleName, Flux.getAllChildren(Flux.topNode));
    }
    
    private static function selectAllOfStyleArray(styleName:String, nodes:Array):Array {
      return Flux.selectStyleName(nodes, styleName);
    }
    
    private static function setEvents():void {
      Flux.selectAll('it').forEach(function(n:Container, i:int, a:Array):void {
        Flux.bind(n, 'enqueued', function(m:String):void {
          n.styleName = 'enqueued';
        })
        Flux.bind(n, 'running', function(m:String):void {
          n.styleName = 'running';
        })
        Flux.bind(n, 'passed', function(m:String):void {
          n.styleName = 'passed';
        })
        Flux.bind(n, 'failed', function(m:String):void {
          n.styleName = 'failed';
          var error:Text = new Text();
          error.text = m;
          n.addChild(error);
        })
      });
      Flux.bind(Flux.topNode, 'before', function():void {
        Flux.selectAll('status').forEach(function(n:Text, i:int, a:Array):void { n.text = 'Running...'; });
      });
      Flux.bind(Flux.topNode, 'after', function():void {
        Flux.selectAll('status').forEach(function(n:IDataRenderer, i:int, a:Array):void { n.data.display(); });
      });
    }
    
    private static function buildBehavior(behavior:Function, node:IDataRenderer, name:String):Function {
      var b:Function = behavior;
      return function():* {
        return b.call(node);
      }
    }
    
    private static function buildBehaviors(behaviors:Object, node:IDataRenderer):Object {
      var newBehaviors:Object = {};
      for (var i:String in behaviors) {
        if (behaviors[i] is Function) {
          newBehaviors[i] = Flux.buildBehavior(behaviors[i], node, i);
        }
      }
      return newBehaviors;
    }
    
    private static function addBehavior(selector:String, behaviors:Object):void {
      Flux.selectAll(selector).forEach(function(node:IDataRenderer, i:int, a:Array):void {
        Flux.mixin(node.data, [Flux.buildBehaviors(behaviors, node)]);
      });
    }
    
    private static function setBehaviors():void {
      Flux.addBehavior('status', {
        display: function():void {
          this.text = Flux.selectAllOfStyle('passed').length + 
                      Flux.selectAllOfStyle('failed').length + 
                      Flux.selectAllOfStyle('enqueued').length + ' test(s), ' + 
                      Flux.selectAllOfStyle('failed').length + ' failure(s), ' + 
                      Flux.selectAllOfStyle('enqueued').length + ' pending';
        }
      });
      Flux.addBehavior('describe', {
        parent: function():Container {
          if (this.parent.parent.data) return this.parent.parent;
          return null;
        },
        
        run_befores: function():void {
          if (this.data.parent() && 
              this.data.parent().data && 
              this.data.parent().data.run_befores) 
            this.data.parent().data.run_befores();
          Flux.children(Flux.child(this, 'befores'), 'before').forEach(function(n:IDataRenderer, i:int, a:Array):void {
            n.data.run();
          });
        },
        
        run_afters: function():void {
          if (this.data.parent() && 
              this.data.parent().data && 
              this.data.parent().data.run_afters) 
            this.data.parent().data.run_afters();
          Flux.children(Flux.child(this, 'afters'), 'after').forEach(function(n:IDataRenderer, i:int, a:Array):void {
            n.data.run();
          });
        },
        
        enqueue: function():void {
          Flux.children(Flux.child(this, 'its'), 'it').forEach(function(n:IDataRenderer, i:int, a:Array):void {
            n.data.enqueue();
          });
          Flux.children(Flux.child(this, 'describes'), 'describe').forEach(function(n:IDataRenderer, i:int, a:Array):void {
            n.data.enqueue();
          });
        }
      });
      
      Flux.addBehavior('it', {
        parent: function():Container {
          return this.parent.parent;
        },
        
        run: function():void {
          var node:Container = this;
          var eventuallyCalled:Boolean = false;
          this.data.specObject.eventually = function(fn:Function):Function {
            eventuallyCalled = true;
            return function(... args):* {
              if (node.data.timeoutId) clearTimeout(node.data.timeoutId);
              try {
                try {
                  node.data.parent().data.run_befores();
                  fn.apply(this, args);
                  if (node.styleName == 'enqueued') Flux.trigger(node, 'passed');
                  else Flux.trigger(node, 'failed', 'it passed, but too late');
                }
                finally {
                  node.data.parent().data.run_afters();
                }
              }
              catch(e:*) {
                Flux.trigger(node, 'failed', e);
              }
              Flux.selectAll('status')[0].data.display();
            }
          };

          try {
            try {
              this.data.parent().data.run_befores();
              this.data.fluxUnitFunc();
              if (this.data.timeout) {
                var self:Container = this;
                this.data.timeoutId = setTimeout(function():void {
                  Flux.trigger(self, 'failed', 'expected to return within ' + self.data.timeout + ' ms');
                }, this.data.timeout);
              }
            }
            finally {
              this.data.parent().data.run_afters();
            }
            if (!eventuallyCalled) Flux.trigger(this, 'passed');
          }
          catch(e:*) {
            Flux.trigger(this, 'failed', e);
          }
          Flux.selectAll('status')[0].data.display();
        },
        
        enqueue: function():void {
          var self:IDataRenderer = this;
          Flux.trigger(this, 'enqueued');
          Flux.queue(function():void {
            self.data.run();
          });
        }
      });
      
      Flux.addBehavior('before', {
        run: function():void { this.data.fluxUnitFunc(); }
      }); 
    
      Flux.addBehavior('after', {
        run: function():void { this.data.fluxUnitFunc(); }
      }); 
    
    }
    
    private static function setEventsAndBehaviorsAndRun():void {
      //Flux.dequeue();
      Flux.setEvents();
      Flux.setBehaviors();
      
      Flux.trigger(Flux.topNode, 'before');
      
      var to_run:Array = Flux.getDescribe();
      to_run.forEach(function(node:Container, i:int, a:Array):void {
        node.data.enqueue();
      });
      
      Flux.queue(function():void { Flux.trigger(Flux.topNode, 'after'); });
      Flux.dequeueAll();
    }
    
  }
}