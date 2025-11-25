// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

package archinfo_reg_pkg;

  typedef struct packed {
    logic [11:0] clock;
    logic [7:0]  sram;
  } archinfo_sys_reg_t;

  typedef struct packed {
    logic [1:0]  typ;
    logic [7:0]  vendor;
    logic [15:0] process;
    logic [5:0]  cust;
  } archinfo_idl_reg_t;

  typedef struct packed {logic [23:0] date;} archinfo_idh_reg_t;

  parameter logic [3:0] ARCHINFO_SYS = 4'b0000;  // BASEADDR + 0x00
  parameter logic [3:0] ARCHINFO_IDL = 4'b0001;  // BASEADDR + 0x04
  parameter logic [3:0] ARCHINFO_IDH = 4'b0010;  // BASEADDR + 0x08

  parameter logic [31:0] ARCHINFO_SYS_ADDR = {26'b0, ARCHINFO_SYS, 2'b00};
  parameter logic [31:0] ARCHINFO_IDL_ADDR = {26'b0, ARCHINFO_IDL, 2'b00};
  parameter logic [31:0] ARCHINFO_IDH_ADDR = {26'b0, ARCHINFO_IDH, 2'b00};

  parameter ARCHINFO_SYS_WIDTH = 20;
  parameter ARCHINFO_IDL_WIDTH = 32;
  parameter ARCHINFO_IDH_WIDTH = 24;

  parameter archinfo_sys_reg_t ARCHINFO_SYS_INIT = 20'hF_1010;
  parameter archinfo_idl_reg_t ARCHINFO_IDL_INIT = 32'hFFFF_2022;
  parameter archinfo_idh_reg_t ARCHINFO_IDH_INIT = 24'hFF_FFFF;

endpackage
