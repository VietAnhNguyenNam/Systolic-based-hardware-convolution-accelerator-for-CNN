library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_tb is
end counter_tb;

architecture Test of counter_tb is
    -- Set counter width
    constant WIDTH : integer := 8;

    -- Testbench signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal run : std_logic := '0';
    signal load_val   : std_logic_vector(WIDTH-1 downto 0);
    signal count : std_logic_vector(WIDTH-1 downto 0);
    signal done  : std_logic;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

  uut: entity work.counter
    generic map (WIDTH => WIDTH)
    port map (
        clk   => clk,
        rst   => rst,
        load_val => load_val,
        run => run,
        count => count,
        done  => done
    );

  clk <= not clk after CLK_PERIOD/2;

  stim_process: process
  begin
    -- Reset the counter
    load_val  <= std_logic_vector(to_unsigned(10, WIDTH));  -- Load 10
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';
    wait for CLK_PERIOD;

    -- Start counting
    run <= '1';
    wait for (10 * CLK_PERIOD);

    -- Stop counting
    run <= '0';
    wait for 20 ns;
    
    
    load_val  <= std_logic_vector(to_unsigned(5, WIDTH));  -- Load 5
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';
    wait for CLK_PERIOD;

    -- Start counting
    run <= '1';
    wait for 30 ns;
    run <= '0';
    wait for 20 ns;

    wait;
  end process;

end Test;
