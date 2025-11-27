library ieee;
use ieee.std_logic_1164.all;

-- Digital phase-frequency detector.
entity adpll_pfd is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    ref_in : in  std_logic;
    fb_in  : in  std_logic;
    up     : out std_logic;
    down   : out std_logic
  );
end entity adpll_pfd;

architecture rtl of adpll_pfd is
  signal ref_sync : std_logic_vector(1 downto 0) := (others => '0');
  signal fb_sync  : std_logic_vector(1 downto 0) := (others => '0');
  signal up_int   : std_logic := '0';
  signal dn_int   : std_logic := '0';
  signal ref_rise : std_logic;
  signal fb_rise  : std_logic;
begin
  -- Input synchronizers.
  process(clk)
  begin
    if rising_edge(clk) then
      ref_sync <= ref_sync(0) & ref_in;
      fb_sync  <= fb_sync(0)  & fb_in;
    end if;
  end process;

  ref_rise <= '1' when ref_sync = "01" else '0';
  fb_rise  <= '1' when fb_sync  = "01" else '0';

  -- Phase-frequency detector logic.
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        up_int <= '0';
        dn_int <= '0';
      else
        -- Standard PFD behavior: pulses stretch with phase error.
        if ref_rise = '1' then
          up_int <= '1';
        elsif fb_rise = '1' then
          up_int <= '0';
        end if;

        if fb_rise = '1' then
          dn_int <= '1';
        elsif ref_rise = '1' then
          dn_int <= '0';
        end if;

        -- When both pulses are high for one cycle, clear them.
        if up_int = '1' and dn_int = '1' then
          up_int <= '0';
          dn_int <= '0';
        end if;
      end if;
    end if;
  end process;

  up   <= up_int;
  down <= dn_int;
end architecture rtl;
