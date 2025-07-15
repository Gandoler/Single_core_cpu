module vga_sb_ctrl (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        clk100m_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [3:0]  mem_be_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o,
  
  output logic [3:0]  vga_r_o,
  output logic [3:0]  vga_g_o,
  output logic [3:0]  vga_b_o,
  output logic        vga_hs_o,
  output logic        vga_vs_o
);

logic        char_map_req_i;  

logic        char_map_we_i;   
logic [31:0] char_map_rdata;

                               
logic        col_map_req_i;      
logic        col_map_we_i;    
logic [31:0] col_map_rdata;
                               
logic        char_tiff_req_i;  
logic        char_tiff_we_i;   
logic [31:0] char_tiff_rdata;




vgachargen vgachar_inst
 (
  .clk_i(clk_i),             // системный синхроимпульс
  .clk100m_i(clk100m_i),         // клок с частотой 100МГц
  .rst_i(rst_i),             // сигнал сброса
 
  .char_map_req_i(char_map_req_i),    // запрос к памяти выводимых символов
  .char_map_addr_i(addr_i[11:2]),   // адрес позиции выводимого символа
  .char_map_we_i(char_map_we_i),     // сигнал разрешения записи кода
  .char_map_be_i(mem_be_i),     // сигнал выбора байтов для записи
  .char_map_wdata_i(write_data_i),  // ascii-код выводимого символа
  .char_map_rdata_o(char_map_rdata),  // сигнал чтения кода символа
  
  
  .col_map_req_i(col_map_req_i),     // запрос к памяти цветов символов
  .col_map_addr_i(addr_i[11:2]),    // адрес позиции устанавливаемой схемы
  .col_map_we_i(col_map_we_i),      // сигнал разрешения записи схемы
  .col_map_be_i(mem_be_i),      // сигнал выбора байтов для записи
  .col_map_wdata_i(write_data_i),   // код устанавливаемой цветовой схемы
  .col_map_rdata_o(col_map_rdata),   // сигнал чтения кода схемы
 
  .char_tiff_req_i(char_tiff_req_i),   // запрос к памяти шрифтов символов
  .char_tiff_addr_i(addr_i[11:2]),  // адрес позиции устанавливаемого шрифта
  .char_tiff_we_i(char_tiff_we_i),    // сигнал разрешения записи шрифта
  .char_tiff_be_i(mem_be_i),    // сигнал выбора байтов для записи
  .char_tiff_wdata_i(write_data_i), // отображаемые пиксели в текущей позиции шрифта
  .char_tiff_rdata_o(char_tiff_rdata), // сигнал чтения пикселей шрифта
  
  .vga_r_o(vga_r_o),           // красный канал vga
  .vga_g_o(vga_g_o),           // зеленый канал vga
  .vga_b_o(vga_b_o),           // синий канал vga
  .vga_hs_o(vga_hs_o),          // линия горизонтальной синхронизации vga
  .vga_vs_o(vga_vs_o)           // линия вертикальной синхронизации vga
);


  // Мультиплексирование сигналов write_enable_i
  always_comb begin
                           char_tiff_req_i = 1'b0;
                           char_tiff_we_i =  1'b0;
                           col_map_req_i = 1'b0;
                           col_map_we_i = 1'b0;
                           char_map_req_i = 1'b0;
                           char_map_we_i  = 1'b0;
    case(addr_i[13:12])
        2'b00: begin char_map_req_i = req_i;
                       char_map_we_i = write_enable_i;
                        read_data_o = char_map_rdata;
                end
         2'b01: begin col_map_req_i = req_i;
                       col_map_we_i = write_enable_i;
                        read_data_o = col_map_rdata;
                end
          2'b10: begin char_tiff_req_i = req_i;
                        char_tiff_we_i = write_enable_i;
                         read_data_o = char_tiff_rdata;
                end
           default :begin 
                           read_data_o = 32'b0;
                          
            end   
    endcase
    end
//s
endmodule
