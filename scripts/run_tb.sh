#!/usr/bin/env bash
set -euo pipefail

iverilog -g2012 -o tb_alu_top.vvp \
  tb_alu_top.v \
  alu_top.v \
  alu_datapath.v \
  alu_control_unit.v \
  booth_radix4_control.v \
  register_param.v \
  mux4_param.v \
  mux2_param.v \
  parallel_adder_9bit.v \
  counter_4bit.v \
  shifter_param.v

vvp tb_alu_top.vvp
