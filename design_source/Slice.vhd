library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity Slice is
  generic (
    B                  : integer  := hyperparam_B;
    K                  : integer  := hyperparam_K;
    PACKED_INPUT_WIDTH : integer  := hyperparam_PACKED_INPUT_WIDTH;
    BIAS_WIDTH         : integer  := hyperparam_BIAS_WIDTH;
    MUX_SIZE           : integer  := hyperparam_MUX_SIZE;
    MUX_SEL_WIDTH      : integer  := hyperparam_MUX_SEL_WIDTH;
    SB_LEN             : SB_len_t := hyperparam_SB_LEN;
    LEAFNO             : integer  := hyperparam_K;
    LEAF_WIDTH         : integer  := hyperparam_LEAF_WIDTH;
    ROOT_WIDTH         : integer  := hyperparam_SLICE_TREE_ROOT_WIDTH
  );
  port (
    packed_input : in std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
    output      : out std_logic_vector(BIAS_WIDTH-1 downto 0);
    
    clk, rst, run : in std_logic;
    SB_idx        : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    rows_state    : in rows_state_t
  );
end Slice;

architecture rtl of Slice is
  type ID_row_t is array(0 to K-1) of RSRB_out_t;
  
  signal I_ext : K_K_B_t;
  signal W_ext : K_B_t;
  signal bias : std_logic_vector(BIAS_WIDTH-1 downto 0);
  signal ID_row : ID_row_t;
  signal I_D : K_K_B_t;
  signal I_L : K_B_t;
  signal psum_out : arr_psum_out_t;
  signal en_I_ext, en_W_ext, en_I_L, en_psum_out, sel_mux_1, sel_mux_2 : K_K_t;
  
  signal sel_mux_RSRB : sel_mux_RSRB_t;
  signal en_RSRB : std_logic_vector(K-1 downto 0);
  
  signal en_root, en_bias : std_logic;
begin
  SLICE_CTRL_INSTANCE : entity work.Slice_Controller
    generic map (
      K => K,
      MUX_SEL_WIDTH => MUX_SEL_WIDTH,
      BIAS_WIDTH => BIAS_WIDTH,
      PACKED_INPUT_WIDTH => PACKED_INPUT_WIDTH
    )
    port map (
      rows_state => rows_state, SB_idx => SB_idx,
      packed_input => packed_input,
      I_ext => I_ext, W_ext => W_ext, bias => bias,
      
      en_I_ext => en_I_ext, en_W_ext => en_W_ext, 
      en_I_L => en_I_L, en_psum_out => en_psum_out, 
      sel_mux_1 => sel_mux_1, sel_mux_2 => sel_mux_2,
      sel_mux_RSRB => sel_mux_RSRB, en_RSRB => en_RSRB,
      en_root => en_root, en_bias => en_bias,
      
      clk => clk, rst => rst, run => run
    );
  
  SA_INSTANCE : entity work.SA
    generic map (B => B, K => K)
    port map (
      W_ext => W_ext, I_ext => I_ext, I_D => I_D, I_L => I_L,
      psum_out => psum_out,
      
      clk => clk, rst => rst, 
      en_I_ext => en_I_ext, en_W_ext => en_W_ext, 
      en_I_L => en_I_L, en_psum_out => en_psum_out,
      sel_mux_1 => sel_mux_1, sel_mux_2 => sel_mux_2
    );
    
  ID2IDROWi : for i in 0 to K-1 generate
    ID2IDROWj : for j in 0 to K-1 generate
      I_D(i,j) <= ID_row(i)(j);
    end generate ID2IDROWj;
  end generate ID2IDROWi;
  ID_row(K-1) <= (others => (others => '0'));
  
  GEN_RSRB : for i in 1 to K-1 generate
    RSRB_INSTANCE : entity work.RSRB
      generic map (
        B => B, K => K,
        MUX_SIZE => MUX_SIZE, MUX_SEL_WIDTH => MUX_SEL_WIDTH,
        SB_LEN => SB_LEN
      )
      port map (
        input => I_L(i),
        output => ID_row(i-1),
        
        clk => clk, rst => rst, en => en_RSRB(i),
        sel => sel_mux_RSRB(i)
      );
  end generate GEN_RSRB;

  ADDER_TREE_INSTANCE : entity work.AdderTree
    generic map (
      B => B, K => K, LEAFNO => LEAFNO,
      LEAF_WIDTH => LEAF_WIDTH, ROOT_WIDTH => ROOT_WIDTH, BIAS_WIDTH => BIAS_WIDTH
    )
    port map (
      arr_psum_out => psum_out, bias => bias,
      output => output,
      
      clk => clk, rst => rst, en_root => en_root, en_bias => en_bias
    );

end rtl;
