module counter(clk, rst, count, ctrl, init, val, winner, loser);
  //------------- Define Parameter for counter size ---------------
  parameter n = 4;
  //-------------- Define inputs and outputs --------------------
  input clk, rst, ctrl, val, init;
  output count, winner, loser;
  //-------------- Define types of Signals ---------------------
  wire clk, rst;
  reg init, winner, loser;
  bit[1: 0] ctrl;
  reg[n-1: 0] count, val;
  
  //------- Give initial value to winner & loser Signals -----------
  initial begin
    winner = 0;
    loser = 0;
  end

  //------- Always block with positive edge for clk -------------
  always @(posedge clk) begin
    //------ Reset => return counter to initial state -----------
    if (~rst) count <= 0;
    //------------ Init => load a value to counter --------------
    else if (init == 1'b1)
      count <= val;
    
    else begin
      //----------------- CONTROL[1] == 0 (UP) ------------------
      if (ctrl[1] == 1'b0)
        count <= (count + ctrl[0] + 1) % (1 << n);
      //---------------- CONTROL[1] == 1 (DOWN) -----------------
      else
        count <= (count - ctrl[0] - 1) % (1 << n);
    end

    //--------- Disable winner & loser Signals after 1 clk ------
    winner <= 1'b0;
    loser <='b0;
    //---------------- if all ones, winner = 1 ------------------
    if (count == (1 << n)-1)
      winner <= 1'b1;
    //---------------- if all zeros, loser = 1 ------------------
    if (count == 0)
      loser <= 1'b1;
  end
endmodule

//------------------------------------------------------------------

module game(clk, rst, gameover, who, winner, loser);
  //---------------- Define inputs and outputs ----------------
  output gameover, who;
  input wire winner, loser, clk, rst;
  //---------------- Define types of Signals ------------------
  reg gameover;
  reg[1:0] who;
  reg[3:0] countwin, countlose;
  //------------ Give initial values for Signals --------------
  initial begin
    who = 2'b00;
    gameover = 0;
    countwin = 0;
    countlose = 0;
  end

  always @(posedge clk) begin
    //--------- Disable who & gameover signal after 1 clk -------
    who <= 2'b00;
    gameover <= 1'b0;
     //------ Reset => return countwin & countlose to 0 ----------
    if (~rst) begin 
      countwin <= 0;
      countlose <= 0;
    end
    else begin
      //--------------------- winner signal ----------------------
      if (winner == 1'b1)
        countwin <= countwin + 1;
      //--------------------- loser signal ------------------------
      else if (loser == 1'b1)
        countlose <= countlose + 1;
      
      //---------- check countlose reaches 15 counts ------------
      if (countlose == 15) begin
        countlose <= 0;
        countwin <= 0;
        who <= 2'b10;
        gameover <= 1'b1;
      end
      //---------- check countwin reaches 15 counts ------------
      if (countwin == 15) begin
        countlose <= 0;
        countwin <= 0;
        who <= 2'b01;
        gameover <= 1'b1;
      end
    end
  end
endmodule

