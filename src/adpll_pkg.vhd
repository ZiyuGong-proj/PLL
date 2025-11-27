library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package adpll_pkg is
  -- Saturate a signed vector to the requested width.
  function sat_signed(
    value : signed;
    width : positive
  ) return signed;
end package adpll_pkg;

package body adpll_pkg is
  function sat_signed(
    value : signed;
    width : positive
  ) return signed is
    variable result : signed(width - 1 downto 0);
    constant max_val : signed(width - 1 downto 0) := to_signed(2 ** (width - 1) - 1, width);
    constant min_val : signed(width - 1 downto 0) := to_signed(-2 ** (width - 1), width);
  begin
    if value > max_val then
      result := max_val;
    elsif value < min_val then
      result := min_val;
    else
      result := resize(value, width);
    end if;
    return result;
  end function sat_signed;
end package body adpll_pkg;
