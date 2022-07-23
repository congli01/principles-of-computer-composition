module booth (
    input  wire        clk  ,
	input  wire        rst_n,
	input  wire [15:0] x    ,
	input  wire [15:0] y    ,
	input  wire        start,
	output reg  [31:0] z    ,
	output wire        busy 
);

reg[16:0] mul1;     //被乘数的双符号位补码
reg[16:0] nmul1;    //被乘数相反数的双符号位补码
reg[16:0] mul2;     //带附加位的乘数
reg[31:0] result1;  //相加后的结果
reg[31:0] result2;  //移位后的结果
reg flag;           //运算开始标志
reg busy1;
reg[4:0] cnt; //计数器

initial begin
    flag = 0;
    cnt = 0;
    result1 = 32'b0;
    result2 = 32'b0;
end

//运算开始标志置1
always @(negedge clk) begin
    if (start == 1) begin
        flag <= 1;
    end
    else if (busy1 == 0) begin 
        flag <= 0;
    end
    else begin
        flag <= flag;
    end
end

//用寄存器保存被乘数，被乘数相反数、带附加位的乘数
always @(posedge flag) begin
    mul1 <= {x[15],x[15:0]};
end

always @(posedge flag) begin
    nmul1 <= {~x[15],~x[15:0]} + 1;
end

always @(posedge flag) begin
    mul2 <= {y[15:0], 1'b0};
end 


always @(posedge clk or negedge rst_n) begin
     if (start == 1) begin
        busy1 <= 1;
     end
     else if (cnt == 16) begin
        busy1 <= 0;
     end
     else 
        busy1 <= busy1;
end

//周期计数
always @(posedge clk or negedge rst_n) begin
    if (flag == 1 && cnt <= 15 && busy1 == 1) begin
        cnt <= cnt+1;
    end
    else 
        cnt <= 0;
end

//booth算法 加
always @(posedge clk or negedge rst_n) begin
    if(flag == 1 && cnt <= 15) begin
        if(mul2[cnt+1] - mul2[cnt] == 1) begin
            result1 <= result2 + {nmul1[16:0], 15'b0};
        end
        else if (mul2[cnt+1] - mul2[cnt] == -1) begin
            result1 <= result2 + {mul1[16:0], 15'b0};
        end
        else begin
            result1 <= result2;
        end
    end
    else begin
        result1 <= 0;
    end
end

//booth算法 移位
always @(negedge clk) begin
    if(busy == 1 && cnt >=1 && cnt <= 15) begin
        result2 <= {result1[31], result1[31:1]};
    end
    //最后一次不移位
    else if (cnt == 16) begin
        result2 <= result1;
    end
    else begin
        result2 <= 0;
    end
end

//将结果赋值给z
always @(posedge clk or negedge rst_n) begin
    if(cnt == 16) begin
        z <= result2;
    end
    else if (start == 1) begin
        z <= 0;
    end
    else begin
        z <= z;
    end
end

assign busy = busy1;

endmodule