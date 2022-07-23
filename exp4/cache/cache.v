`timescale 1ns / 1ps

module cache (
    // ȫ���ź�
    input             clk,
    input             reset,
    // ��CPU���ķ����ź�
    input wire [12:0] addr_from_cpu,    // CPU���ĵ�ַ
    input wire        rreq_from_cpu,    // CPU���Ķ�����
    input wire        wreq_from_cpu,    // CPU����д����
    input wire [ 7:0] wdata_from_cpu,   // CPU����д����
    // ���²��ڴ�ģ�������ź�
    input wire [31:0] rdata_from_mem,   // �ڴ��ȡ������
    input wire        rvalid_from_mem,  // �ڴ��ȡ���ݿ��ñ�־
    // �����CPU���ź�
    output wire [7:0] rdata_to_cpu,     // �����CPU������
    output wire       hit_to_cpu,       // �����CPU�����б�־
    // ������²��ڴ�ģ����ź�
    output reg        rreq_to_mem,      // ������²��ڴ�ģ��Ķ�����
    output reg [12:0] raddr_to_mem,     // ������²�ģ���ͻ�������׵�ַ
    output reg        wreq_to_mem,      // ������²��ڴ�ģ���д����
    output reg [12:0] waddr_to_mem,     // ������²��ڴ�ģ���д��ַ
    output reg [ 7:0] wdata_to_mem      // ������²��ڴ�ģ���д����
);

reg [3:0] current_state, next_state;
localparam READY     = 4'b0000,
           TAG_CHECK = 4'b0010,
           REFILL    = 4'b0001,
           WRITE_CHECK = 4'b0011,   //д���м��
           WMISS       = 4'b0100,   //дȱʧ
           WDATA       = 4'b0101;   //д���У�������д��cache������

wire        wea;                        // Cacheдʹ���ź�
wire [37:0] cache_line_r = /* TODO */current_state == WDATA ? (offset == 2'b00 ? {cache_line[31:8], wdata_from_cpu} : (offset == 2'b01) ? {cache_line[31:16], {wdata_from_cpu, cache_line[7:0]}} :(offset == 2'b10) ? {cache_line[31:24], {wdata_from_cpu, cache_line[15:0]}} : {wdata_from_cpu, cache_line[23:0]}):
                                                    {1, {tag_from_cpu, rdata_from_mem}};   // ��д��Cache��Cache������
                                                    
wire [37:0] cache_line;                 // ��Cache�ж�����Cache������

wire [ 5:0] cache_index    = /* TODO */addr_from_cpu[7:2];         // �����ַ�е�Cache����/Cache��ַ
wire [ 4:0] tag_from_cpu   = /* TODO */addr_from_cpu[12:8];         // �����ַ��Tag
wire [ 1:0] offset         = /* TODO */addr_from_cpu[1:0];         // Cache���ڵ��ֽ�ƫ��
wire        valid_bit      = /* TODO */cache_line[37];         // Cache�е���Чλ
wire [ 4:0] tag_from_cache = /* TODO */cache_line[36:32];         // Cache�е�Tag

wire hit  = /* TODO */tag_from_cache == tag_from_cpu && /* TODO */valid_bit && /* TODO */(current_state == TAG_CHECK || current_state == WRITE_CHECK);
wire miss = (tag_from_cache != tag_from_cpu) | (~valid_bit);

// ����Cache�е��ֽ�ƫ�ƣ���Cache����ѡȡCPU������ֽ�����
assign rdata_to_cpu = (offset == 2'b00) ? cache_line[7:0] :(offset == 2'b01) ? cache_line[15:8] :
                      (offset == 2'b10) ? cache_line[23:16] : cache_line[31:24];
                      

assign hit_to_cpu = hit;

// ʹ��Block RAM IP����ΪCache�������洢��
blk_mem_gen_0 u_cache (
    .clka   (clk         ),
    .wea    (wea         ),
    .addra  (cache_index ),
    .dina   (cache_line_r),
    .douta  (cache_line  )
);


always @(posedge clk) begin
    if (reset) begin
        current_state <= READY;
    end else begin
        current_state <= next_state;
    end
end

// ����ָ����/PPT��״̬ת��ͼ��ʵ�ֿ���Cache��ȡ��״̬ת��
always @(*) begin
    case(current_state)
        READY: begin
            if (/* TODO */rreq_from_cpu) begin
                next_state = /* TODO */TAG_CHECK;
            end else if (wreq_from_cpu) begin
                next_state = WRITE_CHECK;
            end else begin
                next_state = /* TODO */READY;
            end
        end
        TAG_CHECK: begin
            if (/* TODO */miss) begin
                next_state = /* TODO */REFILL;
            end else begin
                next_state = /* TODO */READY;
            end
        end
        REFILL: begin
            if (/* TODO */rvalid_from_mem) begin
                next_state = /* TODO */TAG_CHECK;
            end else begin 
                next_state = /* TODO */REFILL;
            end
        end
        WRITE_CHECK: begin
            if (/* TODO */miss) begin
                next_state = /* TODO */WMISS;
            end else begin
                next_state = /* TODO */WDATA;
            end
        end
        WMISS: begin
            next_state = READY;
        end
        WDATA: begin  
            next_state = READY;
        end
        default: begin
            next_state = READY;
        end
    endcase
end

// ����Block RAM��дʹ���ź�
assign wea = ((current_state == /* TODO */REFILL) && /* TODO */rvalid_from_mem) || (wreq_to_mem);  //��ȱʧ�Լ�д����ʱ��Ҫдcache

// ���ɶ�ȡ����������źţ����������ź�rreq_to_mem�Ͷ���ַ�ź�raddr_to_mem
always @(posedge clk) begin
    if (reset) begin
        raddr_to_mem <= 0;
        rreq_to_mem <= 0;
    end else begin
        case (next_state)
            READY: begin
                raddr_to_mem <= /* TODO */0;
                rreq_to_mem  <= /* TODO */0;
            end
            TAG_CHECK: begin
                raddr_to_mem <= /* TODO */0;
                rreq_to_mem  <= /* TODO */0;
            end
            REFILL: begin
                raddr_to_mem <= /* TODO */addr_from_cpu;
                rreq_to_mem  <= /* TODO */1;
            end
            default: begin
                raddr_to_mem <= 0;
                rreq_to_mem  <= 0;
            end
        endcase
    end
end



// д���д�����дֱ�﷨����д����ʱ����Ҫ����Cache�飬ҲҪ�����ڴ�����
/* TODO */
always @(posedge clk) begin
    if(reset) begin
        wreq_to_mem <= 0;
    end
    else if(wreq_from_cpu && hit) begin
        wreq_to_mem <= 1;
    end
    else begin
        wreq_to_mem <= 0;
    end
end

always @(posedge clk) begin
    if(reset) begin
        waddr_to_mem <= 0;
    end
    else if(wreq_from_cpu && hit) begin
       waddr_to_mem <= addr_from_cpu;
    end
    else begin
        waddr_to_mem <= 0;
    end
end

always @(posedge clk) begin
    if(reset) begin
        wdata_to_mem <= 0;
    end
    else if (wreq_from_cpu && hit) begin
        wdata_to_mem <= wdata_from_cpu;
    end
    else begin
       wdata_to_mem <= 0;
    end
end

endmodule