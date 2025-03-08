library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package common is
  function clog2(n : integer) return integer;
  
  constant hyperparam_B : integer := 8;
  constant hyperparam_K : integer := 3;
  constant hyperparam_STRIDE : integer := 1;
  constant hyperparam_BIAS_WIDTH : integer := 32;
  constant hyperparam_PACKED_INPUT_WIDTH : integer := 2**clog2((2*hyperparam_K-1)*hyperparam_B);
  constant hyperparam_COUNTER_WIDTH : integer := 9;
  type K_B_t is array (0 to hyperparam_K-1) of std_logic_vector(hyperparam_B-1 downto 0);
  type K_K_B_t is array (0 to hyperparam_K-1, 0 to hyperparam_K-1) of std_logic_vector(hyperparam_B-1 downto 0);
  type K_K_t is array (0 to hyperparam_K-1) of std_logic_vector(hyperparam_K-1 downto 0);
  
  -- RSRB
  constant hyperparam_MUX_SIZE : integer := 5;
  constant hyperparam_MUX_SEL_WIDTH : integer := clog2(hyperparam_MUX_SIZE);
  
  type RSRB_out_t is array (0 to hyperparam_K-1) of std_logic_vector(hyperparam_B-1 downto 0);
  type ifmap_size_list_t is array (0 to hyperparam_MUX_SIZE-1) of integer;
  type counter_vals_t is array (0 to hyperparam_MUX_SIZE-1) of integer;
  type SB_len_t is array (0 to hyperparam_MUX_SIZE-1) of integer;
  constant hyperparam_IFMAP_SIZE_LIST : ifmap_size_list_t := (14, 28, 56, 112, 224);
                                                    -- ifmap_len+padding-(K-1)-K
  constant hyperparam_PRE_SSS_LIST : counter_vals_t := (11, 25, 53, 109, 221);
                                                    -- ifmap_len+padding-(K-1)-K-(K-1)
  constant hyperparam_PRE_IIS_LIST : counter_vals_t := (9, 23, 51, 107, 219);
                                                    -- ifmap_len+padding-(K-1)-1
  constant hyperparam_ITERATENO_LIST : counter_vals_t := (13, 27, 55, 111, 223);
  constant hyperparam_SB_LEN : SB_len_t := (12, 14, 28, 56, 112);
  
  -- Slice_AdderTree
  constant hyperparam_LEAF_WIDTH : integer := 2*hyperparam_B+hyperparam_K;
--  constant hyperparam_PSUM_OUT_WIDTH : integer := hyperparam_LEAF_WIDTH;
  constant hyperparam_SLICE_TREE_ROOT_WIDTH : integer := hyperparam_LEAF_WIDTH+clog2(hyperparam_K);
  type arr_psum_out_t is array (0 to hyperparam_K-1) of std_logic_vector(hyperparam_LEAF_WIDTH-1 downto 0);
  
  type sel_mux_RSRB_t is array(0 to hyperparam_K-1) of std_logic_vector(hyperparam_MUX_SEL_WIDTH-1 downto 0);
  
  -- 5 states: 001 new, 010 shift, 011 inherit, 100 weight, 101 bias, 000/others halt
  type rows_state_t is array(0 to hyperparam_K-1) of std_logic_vector(2 downto 0);
  
  
  constant hyperparam_P_M : integer := 24;
  type PM_K_K_B_t is array (0 to hyperparam_P_M, 0 to hyperparam_K-1, 0 to hyperparam_K-1) of std_logic_vector(hyperparam_B-1 downto 0);
  -- Core_AdderTree
  constant hyperparam_CORE_TREE_ROOT_WIDTH : integer := hyperparam_LEAF_WIDTH+clog2(hyperparam_K)+clog2(hyperparam_P_M);
  
end package common;

package body common is
--  function clog2(n : integer) return integer is
--  begin
--    return integer(ceil(log2(real(n))));
--  end function clog2;

  function clog2(n : integer) return integer is
  begin
    if n <= 1 then
      return 0;
    else
      return integer(ceil(log(real(n))/log(2.0)));
    end if;
  end function clog2;
end package body common;