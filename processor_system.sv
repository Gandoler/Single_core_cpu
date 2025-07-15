`timescale 1ns / 1ps

/* -----------------------------------------------------------------------------
* Project Name   : Architectures of Processor Systems (APS) lab work
* Organization   : National Research University of Electronic Technology (MIET)
* Department     : Institute of Microdevices and Control Systems
* Author(s)      : Andrei Solodovnikov
* Email(s)       : hepoh@org.miet.ru

See https://github.com/MPSU/APS/blob/master/LICENSE file for licensing details.
* ------------------------------------------------------------------------------
*/
module processor_system();

    reg clk;
    reg rst;

    processor_system_11 DUT(
    .clk_i(clk),
    .rst_i(rst)
    );

        logic [31:0] RD2;
        logic [31:0] result_o;
        logic [31:0] PC;
        logic [31:0] WD;
        logic [31:0] instr;   


        assign RD2 = DUT.core.mem_wd_o;
        assign result_o = DUT.core.mem_addr_o;
        assign PC = DUT.core.instr_addr_o;
        assign instr = DUT.core.instr_i;
        assign WD = DUT.core.WD;
    
//######################################################################### 
// dllia proverki csr i irq

 logic        irq_ret_o;
 logic [31:0] irq_cause_o;
 logic        irq_o;
 
  assign irq_ret_o = DUT.core.IRQ.irq_ret_o;
  assign irq_cause_o = DUT.core.IRQ.irq_cause_o;
  assign irq_o = DUT.core.IRQ.irq_o;
  
  
  
  
    logic [31:0] read_data_o;
    logic [31:0] mie_o;
    logic [31:0] mepc_o;
    logic [31:0] mtvec_o;
    logic [31:0] mcause_i;
    
  assign mcause_i = DUT.core.CSR.mcause_i;
  assign read_data_o = DUT.core.CSR.read_data_o;
  assign mie_o = DUT.core.CSR.mie_o;
  assign mepc_o = DUT.core.CSR.mepc_o;  
  assign mtvec_o = DUT.core.CSR.mtvec_o;  
//######################################################################### 

    
    initial begin
      repeat(1000) begin
        @(posedge clk);
      end
      $fatal(1, "Test has been interrupted by watchdog timer");
    end

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $display( "\nTest has been started");
        DUT.irq_req = 0;
        rst = 1;
        #40;
        rst = 0;
        repeat(20)@(posedge clk);
        DUT.irq_req = 1;
        while(DUT.irq_ret == 0) begin
          @(posedge clk);
        end
        DUT.irq_req = 0;
        repeat(20)@(posedge clk);
        $display("\n The test is over \n See the internal signals of the module on the waveform \n");
        $finish;
    end

endmodule
