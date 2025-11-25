// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

import archinfo_reg_pkg::*;

module archinfo_reg (
    apb4_if.slave apb4
);

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  archinfo_sys_reg_t s_arch_sys_d, s_arch_sys_q;
  archinfo_idl_reg_t s_arch_idl_d, s_arch_idl_q;
  archinfo_idh_reg_t s_arch_idh_d, s_arch_idh_q;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;


  assign s_arch_sys_d    = apb4.pwdata[ARCHINFO_SYS_WIDTH-1:0];
  dfferc #(
      .REG_TYPE  (archinfo_sys_reg_t),
      .RESET_VAL (ARCHINFO_SYS_INIT)
  ) u_arch_sys_dfferc (
      apb4.pclk,
      apb4.presetn,
      s_apb4_wr_hdshk && s_apb4_addr == ARCHINFO_SYS,
      s_arch_sys_d,
      s_arch_sys_q
  );


  assign s_arch_idl_d = apb4.pwdata[ARCHINFO_IDL_WIDTH-1:0];
  dfferc #(
      .REG_TYPE  (archinfo_idl_reg_t),
      .RESET_VAL (ARCHINFO_IDL_INIT)
  ) u_arch_idl_dfferc (
      apb4.pclk,
      apb4.presetn,
      s_apb4_wr_hdshk && s_apb4_addr == ARCHINFO_IDL,
      s_arch_idl_d,
      s_arch_idl_q
  );


  assign s_arch_idh_d = apb4.pwdata[ARCHINFO_IDH_WIDTH-1:0];
  dfferc #(
      .REG_TYPE  (archinfo_idh_reg_t),
      .RESET_VAL (ARCHINFO_IDH_INIT)
  ) u_arch_idh_dfferc (
      apb4.pclk,
      apb4.presetn,
      s_apb4_wr_hdshk && s_apb4_addr == ARCHINFO_IDH,
      s_arch_idh_d,
      s_arch_idh_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        ARCHINFO_SYS: apb4.prdata[ARCHINFO_SYS_WIDTH-1:0] = s_arch_sys_q;
        ARCHINFO_IDL: apb4.prdata[ARCHINFO_IDL_WIDTH-1:0] = s_arch_idl_q;
        ARCHINFO_IDH: apb4.prdata[ARCHINFO_IDH_WIDTH-1:0] = s_arch_idh_q;
        default:      apb4.prdata = '0;
      endcase
    end
  end

endmodule
