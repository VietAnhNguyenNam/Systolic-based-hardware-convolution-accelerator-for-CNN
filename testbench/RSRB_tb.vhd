library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity RSRB_tb is
--  Port ( );
end RSRB_tb;

architecture Behavioral of RSRB_tb is
  constant B : integer := 8;
  constant K : integer := 3;
  constant MUX_SEL_WIDTH : integer := 3;
  constant SB_LEN : SB_len_t := hyperparam_SB_LEN;
  constant MUX_SIZE : integer := 5;
  
  signal clk : std_logic := '0';
  signal rst : std_logic;
  
  signal input : std_logic_vector(B-1 downto 0);
  signal sel : std_logic_vector(2 downto 0) := "000";
  signal output : RSRB_out_t;
  
  constant CYCLE : time := 10 ns;
begin
  GEN_RSRB : for i in 1 to K-1 generate
    RSRB_INSTANCE : entity work.RSRB
      generic map (
        B => B, K => K,
        MUX_SIZE => MUX_SIZE, MUX_SEL_WIDTH => MUX_SEL_WIDTH,
        SB_LEN => SB_LEN
      )
      port map (
        input => input,
        output => output,
        
        clk => clk, rst => rst, 
        sel => sel
      );
  end generate GEN_RSRB;
  
  clk <= not clk after CYCLE/2;
  
  process is begin
    rst <= '1';
    wait for 2*CYCLE;
    
    rst <= '0';
    
    input <= std_logic_vector(to_unsigned(1, B));
    wait for CYCLE;
    
    input <= std_logic_vector(to_unsigned(2, B));
    wait for CYCLE;
    
    input <= std_logic_vector(to_unsigned(3, B));
    wait for CYCLE;
    
    input <= std_logic_vector(to_unsigned(4, B));
    wait for CYCLE;
    
    input <= std_logic_vector(to_unsigned(5, B));
    wait for CYCLE;
    
    input <= std_logic_vector(to_unsigned(0, B));
    wait for CYCLE;
    
    input <= std_logic_vector(to_unsigned(6, B));
    wait for CYCLE;
    
    wait;
  end process;

end Behavioral;
