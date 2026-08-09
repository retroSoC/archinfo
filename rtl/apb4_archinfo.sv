// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

module apb4_archinfo #(
    // verilog_format: off
    parameter logic [31:0] VENDOR_ID          = 32'h0000_0000,
    parameter logic [31:0] SOC_REVISION       = 32'h0001_0000,
    parameter logic [63:0] BUILD_ID           = 64'h0000_0000_0000_0000,
    parameter logic [31:0] CONFIG_ID          = 32'h0000_0000,
    parameter logic [31:0] BUILD_STATUS       = 32'h0000_0000,
    parameter logic [31:0] REFERENCE_CLOCK_HZ = 32'd72_000_000,
    parameter logic [31:0] SRAM_BYTES         = 32'h0000_0000,
    parameter logic [31:0] TOPOLOGY           = 32'h0000_0000,
    parameter logic [31:0] FEATURES0          = 32'h0000_0000,
    parameter logic [31:0] TECHNOLOGY         = 32'h0000_0000
    // verilog_format: on
) (
    // verilog_format: off
    input logic [127:0] device_id_i,
    input logic         device_id_valid_i,
    input logic         device_id_read_enable_i,
    apb4_if.slave       apb4
    // verilog_format: on
);

  archinfo_reg #(
      .VENDOR_ID         (VENDOR_ID),
      .SOC_REVISION      (SOC_REVISION),
      .BUILD_ID          (BUILD_ID),
      .CONFIG_ID         (CONFIG_ID),
      .BUILD_STATUS      (BUILD_STATUS),
      .REFERENCE_CLOCK_HZ(REFERENCE_CLOCK_HZ),
      .SRAM_BYTES        (SRAM_BYTES),
      .TOPOLOGY          (TOPOLOGY),
      .FEATURES0         (FEATURES0),
      .TECHNOLOGY        (TECHNOLOGY)
  ) u_archinfo_reg (
      .paddr_i                (apb4.paddr[11:0]),
      .psel_i                 (apb4.psel),
      .penable_i              (apb4.penable),
      .pwrite_i               (apb4.pwrite),
      .device_id_i            (device_id_i),
      .device_id_valid_i      (device_id_valid_i),
      .device_id_read_enable_i(device_id_read_enable_i),
      .pready_o               (apb4.pready),
      .prdata_o               (apb4.prdata),
      .pslverr_o              (apb4.pslverr)
  );

`ifndef SV_ASSRT_DISABLE
  xchecker #(
      .DATA_WIDTH(2)
  ) u_device_id_control_xchecker (
      .clk_i(apb4.pclk),
      .dat_i({device_id_valid_i, device_id_read_enable_i})
  );
`endif

endmodule
