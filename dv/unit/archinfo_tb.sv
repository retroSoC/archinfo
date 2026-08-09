// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

`include "archinfo_define.svh"

module archinfo_tb;

  logic         clk;
  logic [127:0] device_id;
  logic         device_id_valid;
  logic         device_id_read_enable;
  logic [ 11:0] paddr;
  logic         psel;
  logic         penable;
  logic         pwrite;
  logic         pready;
  logic [ 31:0] prdata;
  logic         pslverr;

  archinfo_reg #(
      .VENDOR_ID         (32'h0000_0123),
      .SOC_REVISION      (32'h0002_0001),
      .BUILD_ID          (64'h0123_4567_89AB_CDEF),
      .CONFIG_ID         (32'h7654_3210),
      .BUILD_STATUS      (32'h0000_000B),
      .REFERENCE_CLOCK_HZ(32'd50_000_000),
      .SRAM_BYTES        (32'd131_072),
      .TOPOLOGY          (32'h2006_0101),
      .FEATURES0         (32'h0000_FFFF),
      .TECHNOLOGY        (32'h0002_0082)
  ) u_dut (
      .paddr_i                (paddr),
      .psel_i                 (psel),
      .penable_i              (penable),
      .pwrite_i               (pwrite),
      .device_id_i            (device_id),
      .device_id_valid_i      (device_id_valid),
      .device_id_read_enable_i(device_id_read_enable),
      .pready_o               (pready),
      .prdata_o               (prdata),
      .pslverr_o              (pslverr)
  );

  always #5 clk = ~clk;

  task automatic apb_read(input logic [11:0] address, input logic [31:0] expected_data,
                          input logic expected_error);
    begin
      @(negedge clk);
      paddr   = address;
      psel    = 1'b1;
      penable = 1'b0;
      pwrite  = 1'b0;
      #1;
      if (pslverr !== 1'b0) $fatal(1, "PSLVERR asserted in APB setup phase");
      @(negedge clk);
      penable = 1'b1;
      #1;
      if (pready !== 1'b1) $fatal(1, "PREADY must be asserted");
      if (prdata !== expected_data) begin
        $fatal(1, "read %08x returned %08x, expected %08x", address, prdata, expected_data);
      end
      if (pslverr !== expected_error) begin
        $fatal(1, "read %08x PSLVERR=%b, expected %b", address, pslverr, expected_error);
      end
      @(negedge clk);
      psel    = 1'b0;
      penable = 1'b0;
    end
  endtask

  task automatic apb_write_error(input logic [11:0] address);
    begin
      @(negedge clk);
      paddr   = address;
      psel    = 1'b1;
      penable = 1'b0;
      pwrite  = 1'b1;
      #1;
      if (pslverr !== 1'b0) $fatal(1, "write error asserted in setup phase");
      @(negedge clk);
      penable = 1'b1;
      #1;
      if ((pslverr !== 1'b1) || (prdata !== 32'h0000_0000)) begin
        $fatal(1, "write did not return the strict read-only error response");
      end
      @(negedge clk);
      psel    = 1'b0;
      penable = 1'b0;
      pwrite  = 1'b0;
    end
  endtask

  initial begin
    clk                   = 1'b0;
    device_id             = 128'hFFEEDDCC_BBAA9988_77665544_33221100;
    device_id_valid       = 1'b0;
    device_id_read_enable = 1'b0;
    paddr                 = '0;
    psel                  = 1'b0;
    penable               = 1'b0;
    pwrite                = 1'b0;

    repeat (2) @(negedge clk);
    apb_read(`ARCHINFO_COMPONENT_ID_OFFSET, `ARCHINFO_COMPONENT_ID_VALUE, 1'b0);
    apb_read(`ARCHINFO_VENDOR_ID_OFFSET, 32'h0000_0123, 1'b0);
    apb_read(`ARCHINFO_SOC_ID_OFFSET, `ARCHINFO_SOC_ID_VALUE, 1'b0);
    apb_read(`ARCHINFO_SOC_REVISION_OFFSET, 32'h0002_0001, 1'b0);
    apb_read(`ARCHINFO_BUILD_ID_LO_OFFSET, 32'h89AB_CDEF, 1'b0);
    apb_read(`ARCHINFO_BUILD_ID_HI_OFFSET, 32'h0123_4567, 1'b0);
    apb_read(`ARCHINFO_CONFIG_ID_OFFSET, 32'h7654_3210, 1'b0);
    apb_read(`ARCHINFO_BUILD_STATUS_OFFSET, 32'h0000_000B, 1'b0);
    apb_read(`ARCHINFO_REFERENCE_CLOCK_OFFSET, 32'd50_000_000, 1'b0);
    apb_read(`ARCHINFO_SRAM_BYTES_OFFSET, 32'd131_072, 1'b0);
    apb_read(`ARCHINFO_TOPOLOGY_OFFSET, 32'h2006_0101, 1'b0);
    apb_read(`ARCHINFO_FEATURES0_OFFSET, 32'h0000_FFFF, 1'b0);
    apb_read(`ARCHINFO_TECHNOLOGY_OFFSET, 32'h0002_0082, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID_STATUS_OFFSET, 32'h0000_1000, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID0_OFFSET, 32'h0000_0000, 1'b1);

    device_id_valid = 1'b1;
    apb_read(`ARCHINFO_DEVICE_ID_STATUS_OFFSET, 32'h0000_1001, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID0_OFFSET, 32'h0000_0000, 1'b1);

    device_id_read_enable = 1'b1;
    apb_read(`ARCHINFO_DEVICE_ID_STATUS_OFFSET, 32'h0000_1007, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID0_OFFSET, 32'h3322_1100, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID1_OFFSET, 32'h7766_5544, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID2_OFFSET, 32'hBBAA_9988, 1'b0);
    apb_read(`ARCHINFO_DEVICE_ID3_OFFSET, 32'hFFEE_DDCC, 1'b0);
    apb_read(`ARCHINFO_IP_VERSION_OFFSET, `ARCHINFO_IP_VERSION_VALUE, 1'b0);
    apb_read(`ARCHINFO_CAPABILITY_OFFSET, `ARCHINFO_CAPABILITY_VALUE, 1'b0);

    apb_write_error(`ARCHINFO_COMPONENT_ID_OFFSET);
    apb_read(12'h002, 32'h0000_0000, 1'b1);
    apb_read(12'h048, 32'h0000_0000, 1'b1);
    apb_read(`ARCHINFO_COMPONENT_ID_OFFSET, `ARCHINFO_COMPONENT_ID_VALUE, 1'b0);

    $display("ARCHINFO_TEST_PASS");
    $finish;
  end

endmodule
