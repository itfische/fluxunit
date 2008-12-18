package flux_unit.spec {
  import flux_unit.Flux;
  
  import flash.utils.setTimeout;
  
  import mx.core.Container;
  
  
  public dynamic class BehaviorSpec {
    
    public function BehaviorSpec() {
      var self:BehaviorSpec = this;
      new Flux(this).Unit(function():void {
        var global_before:Boolean = false;
        var global_after:Boolean = false;
        self.global_before_invoked = function(b:Boolean = false):Boolean { if (b) global_before = b; return global_before; };
        self.global_after_invoked = function(b:Boolean = false):Boolean { if (b) global_after = b; return global_after; };
        self.reset_global_before_and_after = function():void { global_before = false; global_after = false; };
        with (self) {
          before(function():void { global_before_invoked(true); });
          after(function():void { global_after_invoked(true); });
          
          describe('Behaviors', function():void {
            describe('#run', function():void {
              describe('a simple [describe]', function():void {
                it('invokes the global [before] before an [it]', function():void {
                  expect(global_before_invoked()).to(equal(), true);
                  reset_global_before_and_after();
                });
        
                it('invokes the global [before] before each [it]', function():void {
                  expect(global_before_invoked()).to(equal(), true);
                  reset_global_before_and_after();
                });
        
                it('invokes the global [after] after an [it]', function():void {
                  expect(global_after_invoked()).to(equal(), true);
                });
              });
              
              describe('a [describe] with a [before] and [after] block', function():void {
                var before_invoked:Boolean = false, after_invoked:Boolean = false;
                before(function():void { before_invoked = true });
                after(function():void { after_invoked = true });
              
                describe('[after] blocks', function():void {
                  it('does not invoke the [after] until after the first [it]', function():void {
                    expect(after_invoked).to(equal(), false);
                  });
                  
                  it('invokes the [after] after the first [it]', function():void {
                    expect(after_invoked).to(equal(), true);
                    after_invoked = false;
                  });
                  
                  it('invokes the [after] after each [it]', function():void {
                    expect(after_invoked).to(equal(), true);
                  });
                });
              
                describe('[before] blocks', function():void {
                  it('invokes the [before] before an it', function():void {
                    expect(before_invoked).to(equal(), true);
                    before_invoked = false;
                  });
              
                  it('invokes the [before] before each it', function():void {
                    expect(before_invoked).to(equal(), true);
                  });
                });
              });
        
              describe('A [describe] with two [before] and two [after] blocks', function():void {
                var before_invocations:Array = [], after_invocations:Array = [];
                before(function():void { before_invocations.push('before 1'); });
                before(function():void { before_invocations.push('before 2'); });
                
                after(function():void { after_invocations.push('after 1'); });
                after(function():void { after_invocations.push('after 2'); });
                
                it('invokes the [before]s in lexical order before each [it]', function():void {
                  expect(before_invocations).to(equal(), ['before 1', 'before 2']);
                });
        
                it('invokes the [after]s in lexical order after each [it]', function():void {
                  expect(after_invocations).to(equal(), ['after 1', 'after 2']);
                });
              });
        
              describe('A describe with a nested describe', function():void {
                var before_invocations:Array = [], after_invocations:Array = [];
                before(function():void {
                  before_invocations = [];
                  before_invocations.push('outermost before');
                });
        
                after(function():void {
                  after_invocations = [];
                  after_invocations.push('outermost after');
                });
              
                it("outside a nested [describe], does not invoke any of the nested's [before]s", function():void {
                  expect(before_invocations).to(equal(), ['outermost before']);
                });
                
                it("outside a nested [describe], does not invoke any of the nested's [after]s", function():void {
                  expect(after_invocations).to(equal(), ['outermost after']);
                });
                
                describe('a nested [describe]', function():void {
                  before(function():void {
                    before_invocations.push('inner before');
                  });
        
                  after(function():void {
                    after_invocations.push('inner after');
                  });
        
                  it('runs [before]s in the parent [describe] before each [it]', function():void {
                    expect(before_invocations).to(equal(), ['outermost before', 'inner before']);
                  });
        
                  it('runs [after]s in the parent [describe] after each [it]', function():void {
                    expect(after_invocations).to(equal(), ['outermost after', 'inner after']);
                  });
                  
                  describe('a doubly nested [describe]', function():void {
                    before(function():void {
                      before_invocations.push('innermost before');
                    });
        
                    after(function():void {
                      after_invocations.push('innermost after');
                    });
          
                    describe('[before] blocks', function():void {
                      it('runs [before]s in all ancestors before an [it]', function():void {
                        expect(before_invocations).to(equal(), ['outermost before', 'inner before', 'innermost before']);
                      });
          
                      it('runs [before]s in all ancestors before each [it]', function():void {
                        expect(before_invocations).to(equal(), ['outermost before', 'inner before', 'innermost before']);
                      });
                    });
                    
                    describe('[after] blocks', function():void {
                      it('runs [after]s in all ancestors after an [it]', function():void {
                        expect(after_invocations).to(equal(), ['outermost after', 'inner after', 'innermost after']);
                      });
          
                      it('runs [after]s in all ancestors after each [it]', function():void {
                        expect(after_invocations).to(equal(), ['outermost after', 'inner after', 'innermost after']);
                      });
                    });
                  });
                });
              });
              
              describe('A describe block with callbacks', function():void {
                it('sets a callback with unlimited time to complete', function():void {
                  setTimeout(eventually(function():void {
                    expect(true).to(equal(), true);
                  }), 5000);
                });

                it('sets a callback with enough time to complete', function():void {
                  setTimeout(eventually(function():void {
                    expect(true).to(equal(), true);
                  }), 2000);
                }).but_times_out_after(3000);

                it('sets a callback without enough time to complete', function():void {
                  setTimeout(eventually(function():void {
                    expect(true).to(equal(), true);
                  }), 3000);
                }).but_times_out_after(2000);

                it('sets a callback that fails', function():void {
                  setTimeout(eventually(function():void {
                    expect(true).to(equal(), false);
                  }), 2000);
                });

              });
        
              describe('A describe block with exceptions', function():void {
                var after_invoked:Boolean = false;
                after(function():void {
                  after_invoked = true;
                });
                
                describe('an exception in a test', function():void {
                  it('fails because it throws an exception', function():void {
                    throw('an exception');
                  });
                  
                  it('invokes [after]s even if the previous [it] raised an exception', function():void {
                    expect(after_invoked).to(equal(), true);
                  });
                });
              });
            });
          });
        }
      });
    }
  }
}