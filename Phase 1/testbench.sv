module tb(clk, rst, cnt, ctrl, init, val, winner, loser, gameover, who);
  //------- Define Parameter for counter & clock size ---------
  parameter CLOCK = 10;
  parameter n = 4;
  //---------- Define inputs and outputs with types -----------
  input wire[n-1: 0] cnt;
  input winner, loser;
  output reg clk, rst, init, gameover;
  output reg[1: 0] ctrl, who;
  output reg[n-1: 0] val;

  //--------------------- Generate Clock ----------------------
  always begin
    #(CLOCK / 2) clk = ~clk;
  end
  
  initial begin
    clk = 0;
    init = 0;
    rst = 1;
    //----------- Start Counter down with step = 2 ----------
    ctrl = 2'b11;
    //----------- Reset to start counter with zero ----------
    #2 rst = 0;
    #4 rst = 1;
    //---------- change mode to down with step = 1 ----------
    #35 ctrl = 2'b10;
    //----------- change mode to up with step = 2 -----------
    #40 ctrl = 2'b01;
    //----------- change mode to up with step = 1 -----------
    #45 ctrl = 2'b00;
    
    //-- Repeat loading 14 to fasten reaching the 15 value --
    repeat(14) begin
      #24 val = 4'he;
          init = 1;
      #10 init = 0;
    end
  end
  
  counter c1(clk, rst, cnt, ctrl, init, val, winner, loser);
  game g1(clk, rst, gameover, who, winner, loser);
  
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
    #660 $finish;
  end
endmodule

