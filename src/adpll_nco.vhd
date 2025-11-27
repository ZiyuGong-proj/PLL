library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Numerically controlled oscillator generating the feedback clock.
entity adpll_nco is
  generic (
    WORD_WIDTH : positive := 32
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    ctrl_word : in  unsigned(WORD_WIDTH - 1 downto 0);
    phase_out : out unsigned(WORD_WIDTH - 1 downto 0);
    pll_clk   : out std_logic
  );
end entity adpll_nco;

architecture rtl of adpll_nco is
  signal phase_acc : unsigned(WORD_WIDTH - 1 downto 0) := (others => '0');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        phase_acc <= (others => '0');
      else
        phase_acc <= phase_acc + ctrl_word;
      end if;
    end if;
  end process;

  phase_out <= phase_acc;
  pll_clk   <= phase_acc(WORD_WIDTH - 1);
end architecture rtl;
