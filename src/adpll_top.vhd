library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adpll_top is
  generic (
    WORD_WIDTH   : positive := 32;
    KP           : positive := 64;
    KI           : positive := 1;
    NOMINAL_WORD : unsigned(WORD_WIDTH - 1 downto 0) := to_unsigned(2 ** (WORD_WIDTH - 2), WORD_WIDTH) -- 0.25 * 2^WORD_WIDTH
  );
  port (
    clk        : in  std_logic;  -- system clock used for all logic
    rst        : in  std_logic;
    ref_clk_in : in  std_logic;  -- reference clock to lock to
    pll_clk    : out std_logic;
    ctrl_word  : out unsigned(WORD_WIDTH - 1 downto 0);
    phase_word : out unsigned(WORD_WIDTH - 1 downto 0)
  );
end entity adpll_top;

architecture rtl of adpll_top is
  signal up_sig    : std_logic;
  signal dn_sig    : std_logic;
  signal ctrl_sig  : unsigned(WORD_WIDTH - 1 downto 0);
  signal phase_sig : unsigned(WORD_WIDTH - 1 downto 0);
begin
  pfd_inst : entity work.adpll_pfd
    port map(
      clk    => clk,
      rst    => rst,
      ref_in => ref_clk_in,
      fb_in  => pll_clk,
      up     => up_sig,
      down   => dn_sig
    );

  filter_inst : entity work.adpll_filter
    generic map(
      WORD_WIDTH => WORD_WIDTH,
      KP         => KP,
      KI         => KI
    )
    port map(
      clk          => clk,
      rst          => rst,
      up           => up_sig,
      down         => dn_sig,
      nominal_word => NOMINAL_WORD,
      ctrl_word    => ctrl_sig
    );

  nco_inst : entity work.adpll_nco
    generic map(
      WORD_WIDTH => WORD_WIDTH
    )
    port map(
      clk       => clk,
      rst       => rst,
      ctrl_word => ctrl_sig,
      phase_out => phase_sig,
      pll_clk   => pll_clk
    );

  ctrl_word  <= ctrl_sig;
  phase_word <= phase_sig;
end architecture rtl;
