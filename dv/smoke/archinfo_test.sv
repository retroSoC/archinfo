// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.


class ArchInfoTest extends APB4Master;
  string                 name;
  virtual apb4_if.master apb4;

  extern function new(string name = "archinfo_test", virtual apb4_if.master apb4);
  extern task test_reset_reg();
  extern task test_wr_rd_reg(input bit [31:0] run_times = 1000);
endclass

function ArchInfoTest::new(string name, virtual apb4_if.master apb4);
  super.new("apb4_master", apb4);
  this.name = name;
  this.apb4 = apb4;
endfunction

task ArchInfoTest::test_reset_reg();
  super.test_reset_reg();
  this.rd_check(ARCHINFO_SYS_ADDR, "ARCHINFO_SYS_INIT REG", 20'hF_1010, Helper::EQUL, Helper::INFO);
  this.rd_check(ARCHINFO_IDL_ADDR, "ARCHINFO_IDL_INIT REG", 32'hFFFF_2022, Helper::EQUL, Helper::INFO);
  this.rd_check(ARCHINFO_IDH_ADDR, "ARCHINFO_IDH_INIT REG", 24'hFF_FFFF, Helper::EQUL, Helper::INFO);
endtask

task ArchInfoTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();

  for (int i = 0; i < run_times; i++) begin
    // verilog_format: off
    this.wr_rd_check(ARCHINFO_SYS_ADDR, "ARCHINFO_SYS_INIT REG", $random & {$bits(archinfo_sys_reg_t){1'b1}}, Helper::EQUL);
    this.wr_rd_check(ARCHINFO_IDL_ADDR, "ARCHINFO_IDL_INIT REG", $random & {$bits(archinfo_idl_reg_t){1'b1}}, Helper::EQUL);
    this.wr_rd_check(ARCHINFO_IDH_ADDR, "ARCHINFO_IDH_INIT REG", $random & {$bits(archinfo_idh_reg_t){1'b1}}, Helper::EQUL);
    // verilog_format: on
  end

endtask
