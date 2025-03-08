library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity PE2 is
  generic (
    B : integer := hyperparam_B;
    K : integer := hyperparam_K      -- K: one-based
  );
  port (
    I_ext, W_ext, I_D, I_R : in std_logic_vector(B-1 downto 0);
    psum_in                : in std_logic_vector(2*B+K-1-1 downto 0);
    I_L, W                 : out std_logic_vector(B-1 downto 0);
    psum_out               : out std_logic_vector(2*B+K-1 downto 0);
  
    clk, rst, en_I_ext, en_W_ext, en_I_L, en_psum_out : in std_logic;
    sel_mux_1, sel_mux_2                              : in std_logic
  );
end PE2;

architecture rtl of PE2 is
  signal r_I_ext, r_I_R : unsigned(B-1 downto 0);
  signal r_W_ext        : signed(B-1 downto 0);
  
  signal out_mux_1, out_mux_2 : unsigned(B-1 downto 0);
  signal out_mul : signed(2*B-1 downto 0);
  signal out_add : signed(2*B+K-1 downto 0);
  
begin
  out_mux_1 <= unsigned(I_D) when sel_mux_1 = '0' else
               r_I_ext       when sel_mux_1 = '1' else
               (others => '0');
  
  out_mux_2 <= r_I_R         when sel_mux_2 = '0' else
               out_mux_1     when sel_mux_2 = '1' else
               (others => '0');
  
  I_L <= std_logic_vector(out_mux_2);
  
  W <= std_logic_vector(r_W_ext);
  out_mul <= resize(signed(r_W_ext) * signed('0' & out_mux_2), 2*B);
  
  out_add <= resize(out_mul, 2*B+K) + resize(signed(psum_in), 2*B+K);
  
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        r_W_ext  <= (others => '0');
      elsif en_W_ext='1' then
        r_W_ext <= signed(W_ext);
      end if;
    end if;
  end process;
  
  process(clk) begin
    if rising_edge(clk) then 
      if rst = '1' then
        r_I_ext <= (others => '0');
      elsif en_I_ext='1' then
        r_I_ext <= unsigned(I_ext);
      end if;
    end if;
  end process;
  
  process(clk) begin
    if rising_edge(clk) then 
      if rst = '1' then
        r_I_R <= (others => '0');
      elsif en_I_L='1' then
        r_I_R <= unsigned(I_R);
      end if;
    end if;
  end process;
  
  process(clk) begin
    if rising_edge(clk) then 
      if rst = '1' then
        psum_out <= (others => '0');
      elsif en_psum_out='1' then
        psum_out <= std_logic_vector(out_add);
      end if;
    end if;
  end process;

end rtl;
