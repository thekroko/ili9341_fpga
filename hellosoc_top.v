module hellosoc_top(
	input clk,
	input tft_sdo, output wire tft_sck, output wire tft_sdi, 
	output wire tft_dc, output wire tft_reset, output wire tft_cs,
	output wire[3:0] leds);
	
	// PLL
	wire tft_clk;
	pll pll_inst(clk, tft_clk);
	
	// LEDs
	assign leds = ~{1'b0, 1'b0, 1'b0, 1'b0};

	// *************************** Framebuffer
	reg[0:0] framebuffer [320*240:1];
	reg[16:0] framebufferIndex = 17'd0;
	wire[15:0] fbData;
	wire fbClk;
	always @ (posedge fbClk) begin
		framebufferIndex = (framebufferIndex + 1'b1) % (320*240);
	end
	
	// Convert framebuffer data to RGB565
	wire pixel = framebuffer[framebufferIndex + 1];
	assign fbData = |pixel ? 16'hFFFF : 16'h0000;
	
	// Initialize framebuffer
	initial begin
		framebuffer[320*240:1] = 1'b0;
	end
	
	// *************************** TFT Module
	tft_ili9341 #(.INPUT_CLK_MHZ(160)) tft(tft_clk, tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs, fbData, fbClk);

endmodule