// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

`include "archinfo_define.svh"

module archinfo_formal;

  (* anyconst *)logic [ 11:0] paddr;
  (* anyconst *)logic         psel;
  (* anyconst *)logic         penable;
  (* anyconst *)logic         pwrite;
  (* anyconst *)logic [127:0] device_id;
  (* anyconst *)logic         device_id_valid;
  (* anyconst *)logic         device_id_read_enable;
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

  always_comb begin
    assert (pready);
    if (!(psel && penable)) begin
      assert (!pslverr);
      assert (prdata == 32'h0000_0000);
    end
    if (psel && penable && pwrite) begin
      assert (pslverr);
      assert (prdata == 32'h0000_0000);
    end
    if (psel && penable && !pwrite && (paddr == `ARCHINFO_COMPONENT_ID_OFFSET)) begin
      assert (!pslverr);
      assert (prdata == `ARCHINFO_COMPONENT_ID_VALUE);
    end
    if (psel && penable && !pwrite && (paddr == `ARCHINFO_DEVICE_ID0_OFFSET) &&
        !(device_id_valid && device_id_read_enable)) begin
      assert (pslverr);
      assert (prdata == 32'h0000_0000);
    end
    if (psel && penable && !pwrite && (paddr == `ARCHINFO_DEVICE_ID0_OFFSET) &&
        device_id_valid && device_id_read_enable) begin
      assert (!pslverr);
      assert (prdata == device_id[31:0]);
    end
    if (psel && penable && !pwrite && (paddr[1:0] != 2'b00)) begin
      assert (pslverr);
      assert (prdata == 32'h0000_0000);
    end
  end

endmodule
