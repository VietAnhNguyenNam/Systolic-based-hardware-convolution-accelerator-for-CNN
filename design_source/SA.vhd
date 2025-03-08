library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity SA is
  generic (
--    STRIDE         : integer := hyperparam_STRIDE;
    B              : integer := hyperparam_B;
    K              : integer := hyperparam_K      -- K: one-based

  );
  
  port ( 
    W_ext        : in K_B_t;
    I_D, I_ext   : in K_K_B_t;
    I_L          : out K_B_t;
    psum_out     : out arr_psum_out_t;
    
    clk, rst             : in std_logic;
    en_I_ext, en_W_ext, 
    en_I_L, en_psum_out,
    sel_mux_1, sel_mux_2 : in K_K_t
  );
end SA;

architecture rtl of SA is
  type net_psum_t is array(0 to K+1-1, 0 to K-1) of std_logic_vector(2*B+K-1 downto 0);
  type net_Wext_W_t is array(0 to K+1-1, 0 to K-1) of std_logic_vector(B-1 downto 0);
  type net_IR_IL_t is array(0 to K-1, 0 to K+1-1) of std_logic_vector(B-1 downto 0);
  signal net_psum : net_psum_t;
  signal net_Wext_W : net_Wext_W_t;
  signal net_IR_IL : net_IR_IL_t;
begin
  NET_MAPPING : for i in 0 to K-1 generate
    net_psum(0,i) <= (others => '0');
    psum_out(i) <= net_psum(K,i);
    
    net_Wext_W(0,i) <= W_ext(i);
    
    net_IR_IL(i,K) <= (others => '0');
    I_L(i) <= net_IR_IL(i, 0);
  end generate NET_MAPPING;

  GEN_ROW : for i in 0 to K-1 generate
    GEN_COL : for j in 0 to K-1 generate
      PE_INSTANCE : entity work.PE
        generic map (B => B, K => i+1)
        port map (
          W_ext => net_Wext_W(i,j),
          I_ext => I_ext(i,j), 
          I_D => I_D(i,j), 
          I_R => net_IR_IL(i,j+1),
          psum_in => net_psum(i,j)(2*B+i+1-1-1 downto 0),
          I_L => net_IR_IL(i,j),
          W => net_Wext_W(i+1,j),
          psum_out => net_psum(i+1,j)(2*B+i+1-1 downto 0),
          
          clk => clk, rst => rst, 
          en_I_ext => en_I_ext(i)(K-1-j), en_W_ext => en_W_ext(i)(K-1-j), 
          en_I_L => en_I_L(i)(K-1-j), en_psum_out => en_psum_out(i)(K-1-j),
          sel_mux_1 => sel_mux_1(i)(K-1-j), sel_mux_2 => sel_mux_2(i)(K-1-j)
        );
    end generate GEN_COL;
  end generate GEN_ROW;

end rtl;
