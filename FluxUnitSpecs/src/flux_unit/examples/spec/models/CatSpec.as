package flux_unit.examples.spec.models {
  import flux_unit.Flux;
  import flux_unit.examples.models.Cat;
  import flux_unit.examples.models.Man;
  
  public dynamic class CatSpec {
    
    public function CatSpec() {
      var self:CatSpec = this;
      new Flux(this).Unit(function():void {
        with (self) {
          describe('Cat', function():void {
            var cat:Cat;
            
            describe('#cross_path', function():void {
              describe('when the cat has black fur', function():void {
                before(function():void {
                  cat = new Cat({color: 'black'});
                });
                
                it("decrements the man's luck by 5", function():void {
                  var man:Man = new Man({luck: 5});
                  cat.cross_path(man);
                  expect(man.luck()).to(equal(), 0);
                });
              });
              
              describe('when the cat has non-black fur', function():void {
                before(function():void {
                  cat = new Cat({color: 'white'});
                });
                
                it("does not change the man's luck", function():void {
                  var man:Man = new Man({luck: 5});          
                  cat.cross_path(man);
                  expect(man.luck()).to(equal(), 5);
                });
              });
            });
          });
        }
      });
    }
  }
}