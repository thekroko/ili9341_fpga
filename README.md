# ILI9341 LCD Driver for FPGA

Simple SystemVerilog implementation of a driver for the ILI9341 TFT LCD module.

## Files

* `tft_ili9341.sv` is the core driver
* `tft_ili9341_spi.sv` is the drivers internal SPI implementation
* `hellosoc_top.sv` contains code how to use the driver.

## How does it work?

The driver makes use of the SPI port and Reset line of the display. The display is first reset, then initialized (according to the datasheet), and then continuously
updated at a SPI frequency of around ~50 MHz. A pixel-color input, and pixel-clock output is exported by the module itself.

## Questions? 
Feel free to contact me at _matthias -at- matthiaslinder.com_