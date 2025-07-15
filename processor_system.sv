`timescale 1ns / 1ps

module processor_system_13 (
  input  logic        clk_i,
  input  logic        resetn_i,

  // Входы и выходы периферии
  input  logic [15:0] sw_i,       // Переключатели

  output logic [15:0] led_o,      // Светодиоды

  input  logic        kclk_i,     // Тактирующий сигнал клавиатуры
  input  logic        kdata_i,    // Сигнал данных клавиатуры

  output logic [ 6:0] hex_led_o,  // Вывод семисегментных индикаторов
  output logic [ 7:0] hex_sel_o,  // Селектор семисегментных индикаторов

  input  logic        rx_i,       // Линия приема по UART
  output logic        tx_o,       // Линия передачи по UART

  output logic [3:0]  vga_r_o,    // красный канал vga
  output logic [3:0]  vga_g_o,    // зеленый канал vga
  output logic [3:0]  vga_b_o,    // синий канал vga
  output logic        vga_hs_o,   // линия горизонтальной синхронизации vga
  output logic        vga_vs_o    // линия вертикальной синхронизации vga
);

//##############################################################################################
//                  tut perenes ot ego bro lsu
// lsu +    D_MEMORY
logic           MEM_REQ;
logic           MEM_WE;
logic         MEM_READY;
logic   [3:0]   MEM_BE;
logic   [31:0]  MEM_WD;
logic   [31:0]  MEM_A;
logic   [31:0]  MEM_RD; 
logic [31:0] MEM_RD_TMP;
//##############################################################################################

//##############################################################################################

logic sysclk, rst;
sys_clk_rst_gen divider(.ex_clk_i(clk_i),.ex_areset_n_i(resetn_i),.div_i(10),.sys_clk_o(sysclk), .sys_reset_o(rst));





logic [255:0] OneHot;              // edinsvenniy 256 na risunke
logic ps2_sb_ctrl_req;              // rezultat druzbi posle i
logic MEM_REQ;              
logic vga_req; 


logic [31:0] mem_rd_ps2;            // read data dlia ps2
        
logic [31:0] A; // dlai peredachi adresse malisham 


assign MEM_READY = 1'b1; // kak v labe edentca

                            
//assign per_sel = 255'b1 << MEM_A[31:24]; // tut reshaem kto rabotaet

assign OneHot = 255'b1 <<  MEM_A[31:24]; // tut reshaem kto rabotaet
logic [7:0] DATA_MULT;
assign DATA_MULT =  MEM_A[31:24];


assign A = {8'd0, MEM_A[23:0]};

assign MEM_REQ = OneHot[0] && LSU_REQ; // dlia req Dmemory
assign ps2_sb_ctrl_req = OneHot[3] && LSU_REQ; // dlia req ps2
assign vga_req = OneHot[7] & LSU_REQ;

//##############################################################################################

always_comb begin
    case(DATA_MULT)
        8'h0: MEM_RD = MEM_RD_TMP;
         8'h3: MEM_RD = mem_rd_ps2;
          8'h7: MEM_RD = mem_rd_vga;
           default : MEM_RD=32'b0;
 endcase
end
//##############################################################################################
// instr mem + core
logic [31:0] instr;
logic [31:0] instr_addr;

instr_mem IMemory (
        .addr_i(instr_addr),            //instr_addr
        .read_data_o(instr)             //instr
    );
//##############################################################################################
// core + lsu
logic           stall;
logic           CORE_REQ;
logic           CORE_WE;
logic   [2:0]   CORE_SIZE;
logic   [31:0]  CORE_WD;
logic   [31:0]  CORE_ADDR;
logic   [31:0]  CORE_RD; 

logic           irq_req;     // not conected
logic           irq_ret;  // not conected

 processor_core core(   
        .clk_i(sysclk),                  //clk_i            
        .rst_i(rst),                  //rst_i
        .instr_addr_o(instr_addr),      //instr_addr
        .instr_i(instr),                //instr
        .mem_rd_i(CORE_RD),                  //mem_rd-----corerd
        .mem_req_o(CORE_REQ),            // mew_REQ
        .mem_we_o(CORE_WE),              //men_WE 
        .mem_size_o(CORE_SIZE),          //mem_szie
        .mem_wd_o(CORE_WD),              //mem_wd
        .mem_addr_o(CORE_ADDR),          //mem_addr
        .stall_i(stall),                 //STAL
        
        .irq_req_i(irq_req ),
        .irq_ret_o(irq_ret)
    );
  

//##############################################################################################
// lsu +    D_MEMORY


lsu LSU (
    .clk_i(sysclk),
    .rst_i(rst),
    .core_req_i(CORE_REQ),
    .core_we_i(CORE_WE),
    .core_size_i(CORE_SIZE),
    .core_addr_i(CORE_ADDR),
    .core_wd_i(CORE_WD),
    .core_rd_o(CORE_RD),
    .core_stall_o(stall),
    .mem_req_o(LSU_REQ),
    .mem_we_o(MEM_WE),
    .mem_be_o(MEM_BE),
    .mem_addr_o(MEM_A),
    .mem_wd_o(MEM_WD),
    .mem_rd_i(MEM_RD),
    .mem_ready_i(MEM_READY)
    );
    
    
data_mem DMemory (
        .clk_i(sysclk),                  //clk_i
        .mem_req_i(MEM_REQ),            //REQ
        .write_enable_i(MEM_WE),        //WE          
        .byte_enable_i(MEM_BE),  //BE
        .write_data_i(MEM_WD),          //WD
        .addr_i(A),              //ADDR
        .read_data_o(MEM_RD_TMP),                //RD
        .ready_o()         // тут мем реди
    );

ps2_sb_ctrl ps2_sb_ctrl(         // tut oooochen akuratno333
    .clk_i          (sysclk),
    .rst_i          (rst),
    .addr_i         (A),
    .req_i          (ps2_sb_ctrl_req),
    .write_data_i   (MEM_WD),
    .write_enable_i (MEM_WE),
    .read_data_o    (mem_rd_ps2)  ,   
    .interrupt_request_o(irq_req),
    .interrupt_return_i(irq_ret),
    
    
        
    .kclk_i(kclk_i),
    .kdata_i(kdata_i)
);


vga_sb_ctrl vga_sb_ctrl(
    .clk_i          (sysclk),
    .clk100m_i      (clk_i),
    .rst_i          (rst),
    .req_i          (vga_req),
    .write_enable_i (MEM_WE),
    .mem_be_i       (MEM_BE),                     /// tut akuratno
    .addr_i         (A),
    .write_data_i   (MEM_WD),
    .read_data_o    (mem_rd_vga),

    .vga_r_o        (vga_r_o),
    .vga_g_o        (vga_g_o),
    .vga_b_o        (vga_b_o),
    .vga_hs_o       (vga_hs_o),
    .vga_vs_o       (vga_vs_o)
);

endmodule