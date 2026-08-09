// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

`include "archinfo_define.svh"

module archinfo_reg #(
    // verilog_format: off
    parameter logic [31:0] VENDOR_ID         = 32'h0000_0000,
    parameter logic [31:0] SOC_REVISION      = 32'h0001_0000,
    parameter logic [63:0] BUILD_ID          = 64'h0000_0000_0000_0000,
    parameter logic [31:0] CONFIG_ID         = 32'h0000_0000,
    parameter logic [31:0] BUILD_STATUS      = 32'h0000_0000,
    parameter logic [31:0] REFERENCE_CLOCK_HZ = 32'd72_000_000,
    parameter logic [31:0] SRAM_BYTES        = 32'h0000_0000,
    parameter logic [31:0] TOPOLOGY          = 32'h0000_0000,
    parameter logic [31:0] FEATURES0         = 32'h0000_0000,
    parameter logic [31:0] TECHNOLOGY        = 32'h0000_0000
    // verilog_format: on
) (
    // verilog_format: off
    input  logic [11:0]  paddr_i,
    input  logic         psel_i,
    input  logic         penable_i,
    input  logic         pwrite_i,
    input  logic [127:0] device_id_i,
    input  logic         device_id_valid_i,
    input  logic         device_id_read_enable_i,
    output logic         pready_o,
    output logic [31:0]  prdata_o,
    output logic         pslverr_o
    // verilog_format: on
);

  logic s_device_id_readable;
  logic s_read_mapped;
  logic s_transfer;

  assign s_transfer           = psel_i && penable_i;
  assign s_device_id_readable = device_id_valid_i && device_id_read_enable_i;
  assign pready_o             = 1'b1;

  always_comb begin
    prdata_o      = '0;
    s_read_mapped = 1'b1;

    unique case (paddr_i)
      `ARCHINFO_COMPONENT_ID_OFFSET:    prdata_o = `ARCHINFO_COMPONENT_ID_VALUE;
      `ARCHINFO_VENDOR_ID_OFFSET:       prdata_o = VENDOR_ID;
      `ARCHINFO_SOC_ID_OFFSET:          prdata_o = `ARCHINFO_SOC_ID_VALUE;
      `ARCHINFO_SOC_REVISION_OFFSET:    prdata_o = SOC_REVISION;
      `ARCHINFO_BUILD_ID_LO_OFFSET:     prdata_o = BUILD_ID[31:0];
      `ARCHINFO_BUILD_ID_HI_OFFSET:     prdata_o = BUILD_ID[63:32];
      `ARCHINFO_CONFIG_ID_OFFSET:       prdata_o = CONFIG_ID;
      `ARCHINFO_BUILD_STATUS_OFFSET:    prdata_o = BUILD_STATUS;
      `ARCHINFO_REFERENCE_CLOCK_OFFSET: prdata_o = REFERENCE_CLOCK_HZ;
      `ARCHINFO_SRAM_BYTES_OFFSET:      prdata_o = SRAM_BYTES;
      `ARCHINFO_TOPOLOGY_OFFSET:        prdata_o = TOPOLOGY;
      `ARCHINFO_FEATURES0_OFFSET:       prdata_o = FEATURES0;
      `ARCHINFO_TECHNOLOGY_OFFSET:      prdata_o = TECHNOLOGY;
      `ARCHINFO_DEVICE_ID_STATUS_OFFSET: begin
        prdata_o = {
          16'h0000, 8'd16, 5'h00, s_device_id_readable, device_id_read_enable_i, device_id_valid_i
        };
      end
      `ARCHINFO_DEVICE_ID0_OFFSET: begin
        prdata_o      = s_device_id_readable ? device_id_i[31:0] : 32'h0000_0000;
        s_read_mapped = s_device_id_readable;
      end
      `ARCHINFO_DEVICE_ID1_OFFSET: begin
        prdata_o      = s_device_id_readable ? device_id_i[63:32] : 32'h0000_0000;
        s_read_mapped = s_device_id_readable;
      end
      `ARCHINFO_DEVICE_ID2_OFFSET: begin
        prdata_o      = s_device_id_readable ? device_id_i[95:64] : 32'h0000_0000;
        s_read_mapped = s_device_id_readable;
      end
      `ARCHINFO_DEVICE_ID3_OFFSET: begin
        prdata_o      = s_device_id_readable ? device_id_i[127:96] : 32'h0000_0000;
        s_read_mapped = s_device_id_readable;
      end
      `ARCHINFO_IP_VERSION_OFFSET:      prdata_o = `ARCHINFO_IP_VERSION_VALUE;
      `ARCHINFO_CAPABILITY_OFFSET:      prdata_o = `ARCHINFO_CAPABILITY_VALUE;
      default: begin
        prdata_o      = '0;
        s_read_mapped = 1'b0;
      end
    endcase

    if (!s_transfer || pwrite_i || (paddr_i[1:0] != 2'b00)) begin
      prdata_o = '0;
    end
  end

  assign pslverr_o = s_transfer && (pwrite_i || (paddr_i[1:0] != 2'b00) || !s_read_mapped);

endmodule
