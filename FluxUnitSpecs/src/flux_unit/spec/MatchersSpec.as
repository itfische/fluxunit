package flux_unit.spec {
  import flux_unit.Flux;
  
  public dynamic class MatchersSpec {
    public function MatchersSpec() {
      var self:MatchersSpec = this;
      self.undefined = function():* { return undefined; };
      new Flux(this).Unit(function():void {
        with (self) {
          describe("Matchers", function():void {
            describe('#equal', function():void {
              it("invokes the provided matcher on a call to expect", function():void {
                expect(true).to(equal(), true);
                expect(true).to_not(equal(), false);
              });
              
              describe('when given an object', function():void {
                it("matches Objects with the same keys and values", function():void {
                  expect({a: 'b', c: 'd'}).to(equal(), {a: 'b', c: 'd'});
                  expect({a: 'b', c: 'd', e: 'f'}).to_not(equal(), {a: 'b', c: 'd', e: 'G'});
                });
                
              });
              
              describe('when given an array', function():void {
                it("matches Arrays with the same elements", function():void {
                  expect([1, 2, 4]).to(equal(), [1, 2, 4]);
                  expect([1, 2, 3]).to_not(equal(), [3, 2, 1]);
                });
                
                it("recursively applies equality to complex elements", function():void {
                  expect([{a: 'b'}, {c: 'd'}]).to(equal(), [{a: 'b'}, {c: 'd'}]);
                  expect([{a: 'b'}, {c: 'd'}]).to_not(equal(), [{a: 'b'}, {c: 'E'}]);
                });
              });
              
              describe(".failure_message", function():void {
                it('prints "expected [expected] to (not) be equal [actual]"', function():void {
                  var message:String = null;
                  try { expect(1).to(equal(), 2) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1 to equal 2');
                  
                  try { expect(1).to_not(equal(), 1) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1 to not equal 1');
                });
              });
            });
            
            describe('#match', function():void {
              describe('when given a regular expression', function():void {
                it("matches Strings produced by the grammar", function():void {
                  expect("The wheels of the bus").to(match(), /bus/);
                  expect("The wheels of the bus").to_not(match(), /boat/);
                });
              });
              
              describe('when given a string', function():void {
                it("matches [expected]s containing [actual]s", function():void {
                  expect("The wheels of the bus").to(match(), "wheels");
                  expect("The wheels of the bus").to_not(match(), "oars");
                });
              });
        
              describe('when given an integer', function():void {
                it("matches [expected]s containing [actual]s", function():void {
                  expect("1 time").to(match(), 1);
                  expect("2 times").to_not(match(), 3);
                });
              });
              
              describe(".failure_message", function():void {
                it('prints "expected [actual] to (not) match [expected]"', function():void {
                  var message:String = null;
                  try { expect("hello").to(match(), "schmello") } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected "hello" to match "schmello"');
                  
                  try { expect("hello").to_not(match(), "ello") } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected "hello" to not match "ello"');
                });
              });
            });
            
            describe('#be_empty', function():void {
              it("matches Arrays with no elements", function():void {
                expect([]).to(be_empty());
                expect([1]).to_not(be_empty());
              });
              
              describe(".failure_message", function():void {
                it("prints 'expected [actual] to (not) be empty'", function():void {
                  var message:String = null;
                  try { expect([1]).to(be_empty()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1 to be empty');
                  
                  try { expect([]).to_not(be_empty()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected [] to not be empty');
                });
              });
            });
        
            describe('#have_length', function():void {
              it("matches Arrays of the expected length", function():void {
                expect([]).to(have_length(), 0);
                expect([1]).to(have_length(), 1);
                expect([1, 2, 3]).to_not(have_length(), 4);
              });
        
              describe(".failure_message", function():void {
                it("prints 'expected [actual] to (not) have length [expected]'", function():void {
                  var message:String = null;
                  try { expect([1, 2]).to(have_length(), 4) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1,2 to have length 4');
                  
                  try { expect([1]).to_not(have_length(), 1) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1 to not have length 1');
                });
              });
            });
        
            describe('#be_null', function():void {
              it("matches null", function():void {
                expect(null).to(be_null());
                expect(1).to_not(be_null());
              });
        
              describe(".failure_message", function():void {
                it("prints 'expected [actual] to (not) be null", function():void {
                  var message:String = null;
                  try { expect(1).to(be_null()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1 to be null');
        
                  try { expect(null).to_not(be_null()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected null to not be null');
                });
              });
            });
        
            describe('#be_undefined', function():void {
              it("matches undefined", function():void {
                expect(undefined()).to(be_undefined());
                expect(1).to_not(be_undefined());
              });
        
              describe(".failure_message", function():void {
                it("prints 'expected [actual] to (not) be undefined", function():void {
                  var message:String = undefined();
                  try { expect(1).to(be_undefined()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected 1 to be undefined');
        
                  try { expect(undefined()).to_not(be_undefined()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected undefined to not be undefined');
                });
              });
            });
        
            describe('#be_true', function():void {
              it("matches values that are considered true conditions", function():void {
                expect(true).to(be_true());
                expect(1).to(be_true());
                expect(false).to_not(be_true());
                expect(undefined()).to_not(be_true());
                expect(null).to_not(be_true());
              });
        
              describe(".failure_message", function():void {
                it("prints 'expected [actual] to (not) be true", function():void {
                  var message:String = true;
                  try { expect(false).to(be_true()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected false to be true');
        
                  try { expect(true).to_not(be_true()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected true to not be true');
                });
              });
            });
        
            describe('#be_false', function():void {
              it("matches values that are considered false conditions", function():void {
                expect(false).to(be_false());
                expect(undefined()).to(be_false());
                expect(null).to(be_false());
                expect(true).to_not(be_false());
                expect(1).to_not(be_false());
              });
        
              describe(".failure_message", function():void {
                it("prints 'expected [actual] to (not) be false", function():void {
                  var message:String = false;
                  try { expect(true).to(be_false()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected true to be false');
        
                  try { expect(false).to_not(be_false()) } catch(e:String) { message = e }
                  expect(message).to(equal(), 'expected false to not be false');
                });
              });
            });
          });
        }
      });
    }
  }
}