module hellosoc_top(
	input clk,
	input tft_sdo, output wire tft_sck, output wire tft_sdi, 
	output wire tft_dc, output wire tft_reset, output wire tft_cs,
	output wire[3:0] leds);
	
	// PLL
	wire tft_clk;
	wire clk_10khz;
	wire gameClk;
	pll pll_inst(clk, tft_clk, clk_10khz);
	
	clkdiv #(.div(80), .bitSize(7)) gameClk_div(clk_10khz, gameClk); // ~ 120 Hz
	
	// JTAG Flash
	wire noe = 1'b0;
	jtagflash jtf(noe);
	
	// LEDs
	reg ledA = 1'b1;
	assign leds = ~{ledA, 1'b0, 1'b0, 1'b0};

	// *************************** Framebuffer
	reg[16:0] framebufferIndex = 17'd0;
	wire fbClk;
	
	initial framebufferIndex = 17'd0;
	
	always @ (posedge fbClk) begin
		framebufferIndex <= (framebufferIndex + 1'b1) % 17'(320*240);
	end
	
	// X,Y calc
	wire[8:0] x = 9'(framebufferIndex / 240);
	wire[7:0] y = 8'(framebufferIndex % 240);
	
	wire b1;
	wire b2;
	wire b3;
	ball #(.X(240), .Y(200), .VX(3), .RADIUS(48)) ball1(x, y, b1, gameClk);
	ball #(.X(120), .Y(130), .VX(-4), .RADIUS(32)) ball2(x, y, b2, gameClk);
	ball #(.X(150), .Y(210), .VX(2), .RADIUS(24)) ball3(x, y, b3, gameClk);
	
	wire[15:0] currentPixel = (b1 ?      16'b1111110000000000 : 16'd0) |
									  (b2 ?      16'b1111110000000101 : 16'd0) |
									  (b3 ?      16'b0000011111100000 : 16'd0) |
									  (y == 32 ? 16'hFFFF : 16'd0) |
									  (y <= 31 && y > 0 
												? (((y % 4) != (x % 4)) ? 16'b0000000000011111 : 16'b0000000000000101)
												: 16'd0);
	
	// *************************** TFT Module
	tft_ili9341 #(.INPUT_CLK_MHZ(100)) tft(tft_clk, tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs, currentPixel, fbClk);

endmodule

module ball(input[8:0] checkX, input[7:0] checkY, output wire isSet, input wire physicsClk);
   parameter X = 30;
	parameter Y = 30;
	parameter VX = 1;
	parameter RADIUS = 32;
	
	localparam MIN_Y = (31 + RADIUS/6) << 6;
	localparam MAX_Y = (240 - RADIUS/6) << 6;
	localparam MIN_X = (0 + RADIUS/6) << 6;
	localparam MAX_X = (320 - RADIUS/6) << 6;	
	
	reg signed [15:0] x = 16'(X) <<< 6;
	reg signed [15:0] y = 16'(Y) <<< 6;
	reg signed [15:0] vx = 10'(VX) <<< 4;
	reg signed [15:0] vy = 10'sd0;
	
	// Physics
	wire signed [15:0] newX = x + vx;
	wire signed [15:0] newY = y - vy;
	
	always @ (posedge physicsClk) begin
		if (newY < MIN_Y || newY > MAX_Y) vy <= -vy - 1'sb1;
		else begin
			y <= newY;
			vy <= vy - 1'sb1;
		end
		
		if (newX < MIN_X || newX > MAX_X) vx <= -vx;
		else x <= newX;
	end

	// Rendering
	wire[15:0] pixelX = (x >>> 6);
	wire[15:0] pixelY = (y >>> 6);
	wire[15:0] signedCheckX = checkX;
	wire[15:0] signedCheckY = checkY;
	wire[31:0] squaredDist = (pixelX - signedCheckX) * (pixelX - signedCheckX) 
								  + (pixelY - signedCheckY) * (pixelY - signedCheckY);
	assign isSet = squaredDist <= RADIUS;
endmodule
