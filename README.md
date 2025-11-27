# FPGA All-Digital PLL (VHDL)

This repository provides a small, self-contained All-Digital Phase-Locked Loop (ADPLL) written in VHDL for use with Xilinx Vivado. The design uses a digital phase-frequency detector, PI loop filter, and numerically controlled oscillator (NCO) to synthesize a clock locked to an incoming reference.

## Files
- `src/adpll_pkg.vhd` – Utility package that contains the signed-saturation helper.
- `src/adpll_pfd.vhd` – Two-flop synchronizers and a phase-frequency detector that generate `up`/`down` pulses.
- `src/adpll_filter.vhd` – Proportional-integral (PI) digital loop filter that produces the NCO tuning word.
- `src/adpll_nco.vhd` – Phase accumulator whose MSB forms the synthesized clock.
- `src/adpll_top.vhd` – Top-level wrapper connecting the PFD, loop filter, and NCO.

## Usage in Vivado
1. Create a new RTL project in Vivado and add all files under `src/` to the project (enable VHDL-2008 for numeric operations).
2. Instantiate `adpll_top` in your design. Connect the `clk` port to a system clock that is several times faster than the reference frequency; connect `ref_clk_in` to the reference you want to lock to; drive `rst` high to reset the loop.
3. Set the generics as needed:
   - `WORD_WIDTH` sets the NCO/loop-filter accumulator width (default 32 bits).
   - `NOMINAL_WORD` is the open-loop tuning word. For a system clock `f_clk` and target output frequency `f_out`, use `NOMINAL_WORD = round((f_out / f_clk) * 2^WORD_WIDTH)`.
   - `KP`/`KI` adjust the proportional and integral gains; start from the defaults and tune for your stability/lock-time goals.
4. The synthesized clock appears on `pll_clk`. Optional debug outputs `ctrl_word` and `phase_word` expose the internal tuning word and NCO phase accumulator.

## Notes
- The design avoids asynchronous resets inside the PFD and relies on clock-domain synchronizers for the reference and feedback inputs.
- Gains are integer-scaled; wideners and saturation logic keep the PI math bounded.
- For simulation, you can wrap `adpll_top` in a testbench that drives `ref_clk_in` at the desired frequency and observes the tuning word and phase outputs.
