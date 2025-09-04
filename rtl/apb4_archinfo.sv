// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "apb4_if.svh"
`include "archinfo_define.svh"

module apb4_archinfo (
`ifdef __VERILOG__
    `apb4_slave_if(apb4)
`else
    apb4_if.slave apb4
`endif
);

`ifndef __VERILOG__
  `apb4_slave_if2wire(apb4, apb4);
`endif

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`ARCHINFO_SYS_WIDTH-1:0] s_arch_sys_d, s_arch_sys_q;
  logic s_arch_sys_en;
  logic [`ARCHINFO_IDL_WIDTH-1:0] s_arch_idl_d, s_arch_idl_q;
  logic s_arch_idl_en;
  logic [`ARCHINFO_IDH_WIDTH-1:0] s_arch_idh_d, s_arch_idh_q;
  logic s_arch_idh_en;

  assign s_apb4_addr     = apb4_paddr[5:2];
  assign s_apb4_wr_hdshk = apb4_psel && apb4_penable && apb4_pwrite;
  assign s_apb4_rd_hdshk = apb4_psel && apb4_penable && (~apb4_pwrite);
  assign apb4_pready     = 1'b1;
  assign apb4_pslverr    = 1'b0;

  assign s_arch_sys_en   = s_apb4_wr_hdshk && s_apb4_addr == `ARCHINFO_SYS;
  assign s_arch_sys_d    = apb4_pwdata[`ARCHINFO_SYS_WIDTH-1:0];
  dfferc #(`ARCHINFO_SYS_WIDTH, `SYS_VAL) u_arch_sys_dfferc (
      apb4_pclk,
      apb4_presetn,
      s_arch_sys_en,
      s_arch_sys_d,
      s_arch_sys_q
  );

  assign s_arch_idl_en = s_apb4_wr_hdshk && s_apb4_addr == `ARCHINFO_IDL;
  assign s_arch_idl_d  = apb4_pwdata[`ARCHINFO_IDL_WIDTH-1:0];
  dfferc #(`ARCHINFO_IDL_WIDTH, `IDL_VAL) u_arch_idl_dfferc (
      apb4_pclk,
      apb4_presetn,
      s_arch_idl_en,
      s_arch_idl_d,
      s_arch_idl_q
  );

  assign s_arch_idh_en = s_apb4_wr_hdshk && s_apb4_addr == `ARCHINFO_IDH;
  assign s_arch_idh_d  = apb4_pwdata[`ARCHINFO_IDH_WIDTH-1:0];
  dfferc #(`ARCHINFO_IDH_WIDTH, `IDH_VAL) u_arch_idh_dfferc (
      apb4_pclk,
      apb4_presetn,
      s_arch_idh_en,
      s_arch_idh_d,
      s_arch_idh_q
  );

  always_comb begin
    apb4_prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `ARCHINFO_SYS: apb4_prdata[`ARCHINFO_SYS_WIDTH-1:0] = s_arch_sys_q;
        `ARCHINFO_IDL: apb4_prdata[`ARCHINFO_IDL_WIDTH-1:0] = s_arch_idl_q;
        `ARCHINFO_IDH: apb4_prdata[`ARCHINFO_IDH_WIDTH-1:0] = s_arch_idh_q;
        default:       apb4_prdata = '0;
      endcase
    end
  end

endmodule
