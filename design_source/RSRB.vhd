library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity RSRB is
  generic (
    B             : integer      := hyperparam_B;
    K             : integer      := hyperparam_K;
    MUX_SIZE      : integer      := hyperparam_MUX_SIZE;
    MUX_SEL_WIDTH : integer      := hyperparam_MUX_SEL_WIDTH;
    SB_LEN        : SB_len_t     := hyperparam_SB_LEN
  );
  port (
    input  : in std_logic_vector(B-1 downto 0);
    output : out RSRB_out_t;
    
    clk, rst, en : in std_logic;
    sel          : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0)
  );
end RSRB;

architecture rtl of RSRB is
  type mux_input_t is array(0 to MUX_SIZE-1) of RSRB_out_t;
  type net_SB_t is array(0 to MUX_SIZE+1-1) of std_logic_vector(B-1 downto 0);
  signal mux_input : mux_input_t;
  signal net_SB : net_SB_t;
begin
  net_SB(0) <= input;
  
  GEN_SBs : for i in 0 to MUX_SIZE-1 generate 
    SBs : entity work.SubBuffer
      generic map(B => B, K => K, L_SB => SB_LEN(i))
      port map(
        input => net_SB(i), last_K_output => mux_input(i), shift_output => net_SB(i+1), 
        clk => clk, rst => rst, en => en
      );
  end generate GEN_SBs;
  
  -- can be further improved by disabling some left-most SBs for some specific ifmaps
  output <= mux_input(0) when sel = "000" else
            mux_input(1) when sel = "001" else
            mux_input(2) when sel = "010" else
            mux_input(3) when sel = "011" else
            mux_input(4) when sel = "100" else
            (others => (others => '0'));

end rtl;
