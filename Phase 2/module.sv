module counter(intf.ctr a);
  parameter n = 4;
  
  //------- Give initial value to winner & loser Signals -----------
  initial begin
    a.winner = 0;
    a.loser = 0;
  end

  //------- Always block with positive edge for clk -------------
  always @(posedge a.clk) begin
    //------ Reset => return counter to initial state -----------
    if (~a.rst) a.count = 0;
    //------------ Init => load a value to counter --------------
    else if (a.init == 1'b1)
      a.count = a.val;
    
    else begin
      //----------------- CONTROL[1] == 0 (UP) ------------------
      if (a.ctrl[1] == 1'b0)
        a.count = (a.count + a.ctrl[0] + 1) % (1 << n);
      //---------------- CONTROL[1] == 1 (DOWN) -----------------
      else
        a.count = (a.count - a.ctrl[0] - 1) % (1 << n);
    end

    //--------- Disable winner & loser Signals after 1 clk ------
    a.winner = 1'b0;
    a.loser ='b0;
    //---------------- if all ones, winner = 1 ------------------
    if (a.count == (1 << n)-1)
      a.winner = 1'b1;
    //---------------- if all zeros, loser = 1 ------------------
    if (a.count == 0)
      a.loser = 1'b1;
  end
endmodule

//------------------------------------------------------------------

module game(intf.gm b);
  //------------ Give initial values for Signals --------------
  initial begin
    b.who = 2'b00;
    b.gameover = 0;
    b.countwin = 0;
    b.countlose = 0;
  end

  always @(posedge b.clk) begin
    //--------- Disable who & gameover signal after 1 clk -------
    b.who = 2'b00;
    b.gameover = 1'b0;
     //------ Reset => return countwin & countlose to 0 ----------
    if (~b.rst) begin 
      b.countwin = 0;
      b.countlose = 0;
    end
    else begin
      //--------------------- winner signal ----------------------
      if (b.winner == 1'b1)
        b.countwin = b.countwin + 1;
      //--------------------- loser signal ------------------------
      else if (b.loser == 1'b1)
        b.countlose = b.countlose + 1;
      
      //---------- check countlose reaches 15 counts ------------
      if (b.countlose == 15) begin
        b.who = 2'b10;
        b.gameover = 1'b1;
        @(posedge b.clk)
        b.who = 2'b00;
   		b.gameover = 1'b0;
        b.countlose = 0;
        b.countwin = 0;
      end
      //---------- check countwin reaches 15 counts ------------
      if (b.countwin == 15) begin
        b.who = 2'b01;
        b.gameover = 1'b1;
        @(posedge b.clk)
        b.who = 2'b00;
   		b.gameover = 1'b0;
        b.countlose = 0;
        b.countwin = 0;
      end
    end
  end
endmodule

//------------------------------------------------------------------

module top;
  bit clk;
  parameter CLOCK = 10;
  always #(CLOCK/2) clk = ~clk;
  
  intf f1(clk);
  counter c(f1.ctr);
  game g(f1.gm);
  tb t(f1.tb);
endmodule
