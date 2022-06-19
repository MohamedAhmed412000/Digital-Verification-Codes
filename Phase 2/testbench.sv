interface intf(input clk);
  parameter n = 4;
  //---------- Define inputs and outputs with types -------
  logic winner, loser;
  reg rst, init, gameover;
  reg[1: 0] ctrl, who;
  reg[n-1: 0] val, count;
  reg[3:0] countwin, countlose;
  
  clocking cb @(posedge clk);
    output gameover, who, ctrl, rst, val, init;
    input winner, loser, count;
  endclocking
  
  modport ctr(input clk, rst, ctrl, val, init, output winner, loser, count);
  
  modport gm(input clk, winner, loser, rst, output gameover, who, countwin, countlose);
  
  modport tb(input clk, countwin, countlose, count, winner, loser, output rst, init, gameover, ctrl, who, val);
endinterface

//------------------------------------------------------------------

program tb(intf.tb c);
  parameter n = 4;
  
  initial begin
    c.init <= 0;
    c.rst <= 1;
    //----------- Start Counter down with step = 2 ----------
    c.ctrl <= 2'b11;
    //----------- Reset to start counter with zero ----------
    #2 c.rst <= 0;
    #4 c.rst <= 1;
    //---------- change mode to down with step = 1 ----------
    #35 c.ctrl <= 2'b10;
    //----------- change mode to up with step = 2 -----------
    #40 c.ctrl <= 2'b01;
    //----------- change mode to up with step = 1 -----------
    #45 c.ctrl <= 2'b00;
    	c.val <= 4'he;
    
    //-- Repeat loading 14 to fasten reaching the 15 value --
    repeat(14) begin
      #24 c.init <= 1;
      #10 c.init <= 0;
    end
  end
  
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
    #660 $finish;
  end
  
  property check_15;
    @(posedge c.clk) disable iff (~c.rst)
    ((c.countlose == 15) or (c.countwin == 15)) |-> ((c.gameover == 1) and ((c.who == 2'b10) or (c.who == 2'b01)));
  endproperty
  
  property check_15_after;
    @(posedge c.clk) disable iff (~c.rst)
    ((c.countlose == 15) or (c.countwin == 15)) |-> ##1 ((c.countwin == 0) and (c.countlose == 0) and (c.who == 2'b00));
  endproperty
  
  property check_loading_value;
    @(posedge c.clk) disable iff (~c.rst)
    (c.init == 1) |-> ##1 (c.count == c.val);
  endproperty
  
  property valid_who;
    @(posedge c.clk) disable iff (~c.rst)
    c.who != 2'b11;
  endproperty
  
  property check_rst;
  	@(posedge c.clk) 
    ~c.rst |-> ##1 (c.count == 0 and c.loser == 1);
  endproperty
    
  a1: assert property(check_15);
  a2: assert property(check_15_after);
  a3: assert property(check_loading_value);
  a4: assert property(valid_who);
  a5: assert property(check_rst);
endprogram
