library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.adpll_pkg.all;

-- Simple PI digital loop filter for the ADPLL.
entity adpll_filter is
  generic (
    WORD_WIDTH : positive := 32;
    KP         : positive := 64;  -- proportional gain
    KI         : positive := 1     -- integral gain
  );
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    up           : in  std_logic;
    down         : in  std_logic;
    nominal_word : in  unsigned(WORD_WIDTH - 1 downto 0);
    ctrl_word    : out unsigned(WORD_WIDTH - 1 downto 0)
  );
end entity adpll_filter;

architecture rtl of adpll_filter is
  constant ACC_WIDTH : natural := WORD_WIDTH + 4;
  signal phase_err   : signed(ACC_WIDTH - 1 downto 0);
  signal prop_term   : signed(ACC_WIDTH - 1 downto 0);
  signal int_term    : signed(ACC_WIDTH - 1 downto 0) := (others => '0');
  signal nominal_ext : signed(ACC_WIDTH - 1 downto 0);
  signal control_mix : signed(ACC_WIDTH - 1 downto 0);
  signal ctrl_sat    : signed(WORD_WIDTH - 1 downto 0);
begin
  -- Phase error from PFD outputs.
  phase_err <= to_signed(1, ACC_WIDTH) when (up = '1' and down = '0') else
               to_signed(-1, ACC_WIDTH) when (down = '1' and up = '0') else
               (others => '0');

  -- P-term is combinational, scaled by KP.
  prop_term <= resize(phase_err * to_signed(KP, ACC_WIDTH), ACC_WIDTH);

  -- Integral term accumulates KI * phase_err.
  process(clk)
    variable integral_step : signed(ACC_WIDTH - 1 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        int_term <= (others => '0');
      else
        integral_step := resize(phase_err * to_signed(KI, ACC_WIDTH), ACC_WIDTH);
        int_term <= sat_signed(int_term + integral_step, ACC_WIDTH);
      end if;
    end if;
  end process;

  nominal_ext <= resize(signed('0' & nominal_word), ACC_WIDTH);
  control_mix <= sat_signed(prop_term + int_term + nominal_ext, ACC_WIDTH);
  ctrl_sat    <= sat_signed(control_mix, WORD_WIDTH);
  ctrl_word   <= unsigned(ctrl_sat);
end architecture rtl;
