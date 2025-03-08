library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity SA_tb is
--  Port ( );
end SA_tb;

architecture Behavioral of SA_tb is
  constant K : integer := 3;
  constant B : integer := 8;
  
  signal W_ext: K_B_t;
  signal I_D, I_ext : K_K_B_t;
  signal I_L : K_B_t;
  signal psum_out : arr_psum_out_t;
  
  signal clk : std_logic := '0';
  signal rst: std_logic;
  signal en_I_ext, en_W_ext, en_I_L, en_psum_out, sel_mux_1, sel_mux_2 : K_K_t;
  
  constant CYCLE : time := 10 ns;
begin
  uut : entity work.SA
    generic map (B => B, K => K)
    port map (
      W_ext => W_ext, I_ext => I_ext, I_D => I_D, I_L => I_L,
      psum_out => psum_out,
      
      clk => clk, rst => rst, 
      en_I_ext => en_I_ext, en_W_ext => en_W_ext, 
      en_I_L => en_I_L, en_psum_out => en_psum_out,
      sel_mux_1 => sel_mux_1, sel_mux_2 => sel_mux_2
    );
    
  clk <= not clk after CYCLE/2;
  
  process is 
--    procedure shorthand_assign(
--      W_ext_row, I_ext_row, I_D_row : in K_B_t;
--      en_I_ext, en_W_ext, en_I_L, en_psum_out,
--      sel_mux_1, sel_mux_2 : in K_K_t
--    ) is
      
--    end procedure;
  begin
    rst <= '1';
    wait for CYCLE*2+CYCLE/2;
    
    rst <= '0';
    en_psum_out(0) <= (others => '1'); en_psum_out(1) <= (others => '1'); en_psum_out(2) <= (others => '1');
    en_I_L(0) <= (others => '0'); en_I_L(1) <= (others => '0'); en_I_L(2) <= (others => '0');
    sel_mux_1(0) <= (others => '0'); sel_mux_1(1) <= (others => '0'); sel_mux_1(2) <= (others => '0');
    sel_mux_2(0) <= (others => '0'); sel_mux_2(1) <= (others => '0'); sel_mux_2(2) <= (others => '0');
    en_I_ext(0) <= (others => '0'); en_I_ext(1) <= (others => '0'); en_I_ext(2) <= (others => '0');
    
    en_W_ext(0) <= "111";
    W_ext(0) <= std_logic_vector(to_signed(-121, B)); 
    W_ext(1) <= std_logic_vector(to_signed(19, B));
    W_ext(2) <= std_logic_vector(to_signed(26, B));
    wait for CYCLE;
    
    en_W_ext(1) <= "111";
    W_ext(0) <= std_logic_vector(to_signed(-52, B)); 
    W_ext(1) <= std_logic_vector(to_signed(-112, B));
    W_ext(2) <= std_logic_vector(to_signed(-17, B));
    wait for CYCLE;
    
    en_W_ext(2) <= "111";
    W_ext(0) <= std_logic_vector(to_signed(-46, B)); 
    W_ext(1) <= std_logic_vector(to_signed(-20, B));
    W_ext(2) <= std_logic_vector(to_signed(48, B));
    wait for CYCLE;
    
    en_W_ext(0) <= "000"; en_W_ext(1) <= "000"; en_W_ext(2) <= "000";
    
--    nhh
    en_I_L(0) <= "111";
    sel_mux_1(0) <= "111";
    sel_mux_2(0) <= "111";
    en_I_ext(0) <= "111"; en_I_ext(1) <= "000"; en_I_ext(2) <= "000";
    I_ext(0,0) <= std_logic_vector(to_unsigned(46, B));
    I_ext(0,1) <= std_logic_vector(to_unsigned(42, B));
    I_ext(0,2) <= std_logic_vector(to_unsigned(14, B));
    wait for CYCLE;
    
--    snh
    en_I_L(0) <= "111"; en_I_L(1) <= "111";
    sel_mux_1(0) <= "111"; sel_mux_1(1) <= "111";
    sel_mux_2(0) <= "111"; sel_mux_2(1) <= "111";
    en_I_ext(0) <= "001"; en_I_ext(1) <= "111"; en_I_ext(2) <= "000";
    I_ext(0,2) <= std_logic_vector(to_unsigned(17, B));
    I_ext(1,0) <= std_logic_vector(to_unsigned(4, B));
    I_ext(1,1) <= std_logic_vector(to_unsigned(161, B));
    I_ext(1,2) <= std_logic_vector(to_unsigned(122, B));
    wait for CYCLE;
    
--    ssn
    en_I_L(0) <= "111"; en_I_L(1) <= "111"; en_I_L(2) <= "111";
    sel_mux_1(0) <= "111"; sel_mux_1(1) <= "111"; sel_mux_1(2) <= "111";
    sel_mux_2(0) <= "001"; sel_mux_2(1) <= "111"; sel_mux_2(2) <= "111";
    en_I_ext(0) <= "001"; en_I_ext(1) <= "001"; en_I_ext(2) <= "111";
    I_ext(0,2) <= std_logic_vector(to_unsigned(5, B));
    I_ext(1,2) <= std_logic_vector(to_unsigned(81, B));
    I_ext(2,0) <= std_logic_vector(to_unsigned(118, B));
    I_ext(2,1) <= std_logic_vector(to_unsigned(5, B));
    I_ext(2,2) <= std_logic_vector(to_unsigned(102, B));
    wait for CYCLE;
    
--    sss
    sel_mux_1(0) <= "111"; sel_mux_1(1) <= "111"; sel_mux_1(2) <= "111";
    sel_mux_2(0) <= "001"; sel_mux_2(1) <= "001"; sel_mux_2(2) <= "111";
    en_I_ext(0) <= "001"; en_I_ext(1) <= "001"; en_I_ext(2) <= "001";
    I_ext(0,2) <= std_logic_vector(to_unsigned(85, B));
    I_ext(1,2) <= std_logic_vector(to_unsigned(197, B));
    I_ext(2,2) <= std_logic_vector(to_unsigned(18, B));
    wait for CYCLE;

----    test
--    en_I_L(0) <= "111";
--    sel_mux_1(0) <= "111";
--    sel_mux_2(0) <= "111";
--    en_I_ext(0) <= "111";
--    I_ext(0,0) <= std_logic_vector(to_unsigned(46, B));
--    I_ext(0,1) <= std_logic_vector(to_unsigned(42, B));
--    I_ext(0,2) <= std_logic_vector(to_unsigned(14, B));
--    wait for CYCLE;
    
--    sel_mux_1(0) <= "111";
--    sel_mux_2(0) <= "001";
--    wait for CYCLE;
        
    wait;
  end process;

end Behavioral;
