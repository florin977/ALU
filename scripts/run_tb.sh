#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v iverilog >/dev/null 2>&1 && [ -d /c/iverilog/bin ]; then
  export PATH="/c/iverilog/bin:$PATH"
fi

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
  twos_complement_param.v \
  counter_4bit.v \
  shifter_param.v

vvp tb_alu_top.vvp
