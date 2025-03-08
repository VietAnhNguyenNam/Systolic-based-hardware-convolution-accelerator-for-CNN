library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
  generic (
    WIDTH : integer := 8
  );
  port (
    load_val : in std_logic_vector(WIDTH-1 downto 0);
    count    : out std_logic_vector(WIDTH-1 downto 0);
    
    clk, rst, run : in std_logic;
    done          : out std_logic
  );
end counter;

architecture rtl of counter is
  signal counter : unsigned(WIDTH-1 downto 0);
begin
  process (clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        counter <= unsigned(load_val);
      elsif run = '1' and counter > 0 then
        counter <= counter - 1;
      end if;
    end if;
  end process;

  count <= std_logic_vector(counter);
  done  <= '1' when counter = 0 else '0';

end rtl;
