module register_file
import memory_pkg::*;
(
  input  logic         clk_i,          // Тактовый сигнал
  input  logic         write_enable_i, // Разрешение записи
  input  logic [4:0]   read_addr1_i,   // Адрес первого порта чтения
  input  logic [4:0]   read_addr2_i,   // Адрес второго порта чтения
  input  logic [4:0]   write_addr_i,   // Адрес порта записи
  input  logic [31:0]  write_data_i,   // Данные для записи
  output logic [31:0]  read_data1_o,   // Данные первого порта чтения
  output logic [31:0]  read_data2_o    // Данные второго порта чтения
);

  // Регистровый файл
  logic [31:0] rf_mem [31:0];

  // Инициализация нулевого регистра нулевым значением
  initial begin
    rf_mem[0] = 32'b0;
  end

  // Асинхронное чтение из регистрового файла
  assign read_data1_o = (read_addr1_i == 5'b0) ? 32'b0 : rf_mem[read_addr1_i];
  assign read_data2_o = (read_addr2_i == 5'b0) ? 32'b0 : rf_mem[read_addr2_i];

  // Синхронная запись в регистровый файл
  always_ff @(posedge clk_i) begin
    if (write_enable_i && write_addr_i != 5'b0) begin
      rf_mem[write_addr_i] <= write_data_i;
    end
  end

endmodule
