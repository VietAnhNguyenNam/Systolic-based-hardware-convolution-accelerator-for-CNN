library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity SubBuffer is
  generic (
    B    : integer := hyperparam_B;
    K    : integer := hyperparam_K;
    L_SB : integer := hyperparam_SB_LEN(0)
  );
  port (
    input         : in std_logic_vector(B-1 downto 0);
    last_K_output : out RSRB_out_t;
    shift_output  : out std_logic_vector(B-1 downto 0);
    
    clk, rst, en : in std_logic
  );
end SubBuffer;

architecture rtl of SubBuffer is
  type SB_regs_t is array (0 to L_SB-1) of std_logic_vector(B-1 downto 0);
  signal SB_regs : SB_regs_t;
begin
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        SB_regs <= (others => (others => '0'));
      elsif en = '1' then
        SB_regs(0) <= input;
        for i in 1 to L_SB-1 loop
          SB_regs(i) <= SB_regs(i-1);
        end loop;
      end if;
    end if;
  end process;
  
  GET_LAST_K : for i in 0 to K-1 generate 
    last_K_output(i) <= SB_regs(L_SB-1-i);
  end generate GET_LAST_K;
  
  shift_output <= SB_regs(L_SB-1);

end rtl;
