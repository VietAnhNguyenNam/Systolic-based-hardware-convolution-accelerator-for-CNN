library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
use work.common.all;

entity AdderTree is
  generic (
    B          : integer := hyperparam_B;
    K          : integer := hyperparam_K;
    LEAFNO     : integer := hyperparam_K;
    LEAF_WIDTH : integer := hyperparam_LEAF_WIDTH;
    ROOT_WIDTH : integer := hyperparam_SLICE_TREE_ROOT_WIDTH;
    BIAS_WIDTH : integer := hyperparam_BIAS_WIDTH
  );
  Port (
    arr_psum_out : in arr_psum_out_t;
    bias         : in std_logic_vector(BIAS_WIDTH-1 downto 0);
    output       : out std_logic_vector(BIAS_WIDTH-1 downto 0);
    
    clk, rst, en_root, en_bias : std_logic
  );
end AdderTree;

architecture rtl of AdderTree is
  constant TREE_HEIGHT : integer := clog2(LEAFNO);
  
  type tree_info_t is array(0 to TREE_HEIGHT*2-1) of integer;    -- 2nd idx: 0 even, 1 odd
  function get_tree_info return tree_info_t is
    variable res : tree_info_t;
  begin
    res(0) := integer(ceil(real(LEAFNO)/2.0));
    if LEAFNO mod 2 = 0 then
      res(1) := 0;
    else
      res(1) := 1;
    end if;
    for i in 1 to TREE_HEIGHT-1 loop 
      res(i*2) := integer(ceil(real(res(i*2-2))/2.0));
      if res(i*2-2) mod 2 = 0 then
        res(i*2+1) := 0;
      else
        res(i*2+1) := 1;
      end if;
    end loop;
    return res;
  end function;

  type net_t is array(0 to TREE_HEIGHT, 0 to LEAFNO-1) of signed(ROOT_WIDTH-1 downto 0);
  signal net : net_t;
  constant tree_info : tree_info_t := get_tree_info;
  signal sum, r_bias : signed(BIAS_WIDTH-1 downto 0);
begin
  INPUT2NET : for i in 0 to LEAFNO-1 generate 
    net(0,i) <= resize(signed(arr_psum_out(i)), ROOT_WIDTH);
  end generate INPUT2NET; 
  
  GEN_TREE : for i in 0 to TREE_HEIGHT-1 generate 
    GEN_EVEN : if tree_info(i*2+1) = 0 generate
      EVEN_CASE : for j in 0 to tree_info(i*2)-1 generate 
        net(i+1,j) <= net(i,j*2) + net(i,j*2+1);    -- resize: ROOT_WIDTH-TREE_HEIGHT+1+i
      end generate EVEN_CASE;
    end generate GEN_EVEN; 
    
    GEN_ODD : if tree_info(i*2+1) = 1 generate
      ODD_CASE : for j in 0 to tree_info(i*2)-1-1 generate 
        net(i+1,j) <= net(i,j*2) + net(i,j*2+1);
      end generate ODD_CASE;
      net(i+1,tree_info(i*2)-1) <= net(i,2*tree_info(i*2)-2);
    end generate GEN_ODD;
  end generate GEN_TREE;
  
--  process(clk) begin
--    if rising_edge(clk) then
--      if rst = '1' then
--        sum <= (others => '0');
--      else
--        if en_root = '1' then
--          sum <= resize(net(TREE_HEIGHT,0),BIAS_WIDTH);
--        end if;
--      end if;
--    end if;
--  end process;
  
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        r_bias <= (others => '0');
      else
        if en_bias = '1' then
          r_bias <= signed(bias);
        end if;
      end if;
    end if;
  end process;
  
--  output <= std_logic_vector(sum+r_bias);
  output <= std_logic_vector(resize(net(TREE_HEIGHT,0),BIAS_WIDTH)+r_bias);
  
end rtl;


--7 0
--4 1
--2 0
--1 0