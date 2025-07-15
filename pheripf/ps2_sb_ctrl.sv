module ps2_sb_ctrl(
    /*33
        Часть интерфейса модуля, отвечающая за подключение к системной шине
    */
    input  logic         clk_i,
    input  logic         rst_i,
    input  logic [31:0]  addr_i,
    input  logic         req_i,
    input  logic [31:0]  write_data_i,
    input  logic         write_enable_i,
    output logic [31:0]  read_data_o,

    /*
        Часть интерфейса модуля, отвечающая за отправку запросов на прерывание
        процессорного ядра
    */
    output logic        interrupt_request_o,
    input  logic        interrupt_return_i,

    /*
        Часть интерфейса модуля, отвечающая за подключение к модулю,
        осуществляющему прием данных с клавиатуры
    */
    input  logic kclk_i,
    input  logic kdata_i
);

    logic [7:0] scan_code;
    logic       scan_code_is_unread;
    
    assign interrupt_request_o = scan_code_is_unread;
    // promejutki
    logic [7:0]  keycode_o;
    logic         keycode_valid_o;

    // Экземпляр модуля PS2Receiver
    PS2Receiver PS2Receiver_inst(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .kclk_i(kclk_i),
        .kdata_i(kdata_i),
        .keycodeout_o(keycode_o),
        .keycode_valid_o(keycode_valid_o)
    );

    
    always_ff @(posedge clk_i or posedge rst_i) begin
    
            if(rst_i) begin
            scan_code<= 8'b0;
        scan_code_is_unread <= 1'b0;
    end else
            
            
            if (keycode_valid_o) begin
                scan_code <= keycode_o;
                scan_code_is_unread <= 1'b1;
                if ( req_i && !write_enable_i&& addr_i==32'h00) begin
                        read_data_o <= { 24'b0, scan_code};
                    end
                
            end else if ( req_i && !write_enable_i&& addr_i==32'h00) begin

                                        read_data_o <= { 24'b0, scan_code};
                                        scan_code_is_unread <= 1'b0;
                                        
            end else if  (interrupt_return_i) begin
                            scan_code_is_unread <= 1'b0;
                            
            end else if   ( req_i && !write_enable_i&& addr_i==32'h04) begin
                            read_data_o <= {31'h0, scan_code_is_unread};

             end else if   ( req_i && write_enable_i && addr_i==32'h24  && write_data_i == 1'b1) begin
                           scan_code_is_unread <= 1'b0;
                           scan_code<= 1'b0;
              end

    end


  


    
     
//  

endmodule
