package flux_unit.examples.spec.models {
  import flux_unit.Flux;
  import flux_unit.examples.models.Man;
  
  import flash.events.MouseEvent;
  import flash.utils.setTimeout;
  
  import mx.containers.VBox;
  import mx.core.Container;
  
  public dynamic class ManSpec {
    public function ManSpec() {
      var self:ManSpec = this;
      new Flux(this).Unit(function():void {
        with (self) {
          describe('Man', function():void {
            var testNode:VBox = new VBox();
            var man:Man;
            before(function():void {
              man = new Man({luck: 5});
            });
            
            describe('#decrement_luck', function():void {
              it('decrements the luck field by the given amount', function():void {
                man.decrement_luck(3);
                expect(man.luck()).to(equal(), 2);
              });
              
              it('asks for dessert', function():void {
                man.askPermission('Can I have dessert?', eventually(function(response:String):void {
                  expect(response).to(equal(), 'Yes');
                }));
              });
              
              it('asks to go play', function():void {
                man.askPermission('Can I go outside and play?', eventually(function(response:String):void {
                  expect(response).to(equal(), 'Yes');
                }));
              }).but_times_out_after(2000);
              
              it('asks to go to Disney Land', function():void {
                man.askPermission('Can I go to Disnay Land?', eventually(function(response:String):void {
                  expect(response).to(equal(), 'No');
                }));
              }).but_times_out_after(4000);
              
              describe('when the decrement exceeds the luck balance', function():void {
                it('decrements the luck field to zero', function():void {
                  man.decrement_luck(100000000);
                  expect(man.luck()).to(equal(), 0);
                });
              });
            });
            
            describe('@click', function():void {
              var manNode:Container;
              before(function():void {
                manNode = man.render(testNode);
              });
              
              it("removes the man's hair", function():void {
                expect(manNode).to(have(), 'hair');
                manNode.dispatchEvent(new MouseEvent('click'));
                expect(manNode).to_not(have(), 'hair');
              });
            });
          });
        }
      });
    }
  }
}