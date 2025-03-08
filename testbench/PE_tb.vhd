library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PE_tb is
end PE_tb;

architecture Behavioral of PE_tb is
  constant K : integer := 3;
  constant B : integer := 8;
  signal I_ext, W_ext, I_D, I_R : std_logic_vector(B-1 downto 0);
  signal psum_in                : std_logic_vector(2*B+K-1-1 downto 0);
  signal I_L, W                 : std_logic_vector(B-1 downto 0);
  signal psum_out               : std_logic_vector(2*B+K-1 downto 0);
    
  signal clk : std_logic := '0';
  signal rst : std_logic;
  signal en_I_ext, en_W_ext, en_I_L, en_psum_out : std_logic;
  signal sel_mux_1, sel_mux_2 : std_logic;
  
  constant CYCLE : time := 10 ns;
begin
  uut : entity work.PE2
    generic map (B => 8, K => 3)
    port map (
      I_ext => I_ext, W_ext => W_ext, I_D => I_D, I_R => I_R,
      psum_in => psum_in, I_L => I_L, W => W,
      psum_out => psum_out,
    
      clk => clk, rst => rst, 
      en_I_ext => en_I_ext, en_W_ext => en_W_ext, en_I_L => en_I_L, 
      en_psum_out => en_psum_out,
      sel_mux_1 => sel_mux_1, sel_mux_2 => sel_mux_2
    );
    
  clk <= not clk after CYCLE/2;
  
  process is begin
    rst <= '1';
    wait for 2*CYCLE;
    
    rst <= '0';
    wait for CYCLE/2;
    
    en_psum_out <= '1';
    en_I_L <= '1';
    
    W_ext <= std_logic_vector(to_signed(5, B));
    I_ext <= std_logic_vector(to_signed(11, B));
    I_D <= std_logic_vector(to_signed(12, B));
    I_R <= std_logic_vector(to_signed(13, B));
    psum_in <= (others => '0');
    
    en_W_ext <= '1';
    wait for CYCLE;
    
    en_W_ext <= '0';
    en_I_ext <= '1';
    wait for CYCLE;
    
    en_I_ext <= '0';
    sel_mux_1 <= '1';
    sel_mux_2 <= '1';
    wait for CYCLE;
    
    sel_mux_1 <= '1';
    sel_mux_2 <= '0';
    wait for CYCLE;
    
    sel_mux_1 <= '0';
    sel_mux_2 <= '1';
    wait for CYCLE;
    
    
    
    W_ext <= std_logic_vector(to_signed(9, B));
    I_ext <= std_logic_vector(to_signed(100, B));
    I_D <= std_logic_vector(to_signed(101, B));
    I_R <= std_logic_vector(to_signed(102, B));
    
    en_W_ext <= '1';
    wait for CYCLE;
    
    en_W_ext <= '0';
    en_I_ext <= '1';
    wait for CYCLE;
    
    en_I_ext <= '0';
    sel_mux_1 <= '1';
    sel_mux_2 <= '1';
    wait for CYCLE;
    
    sel_mux_1 <= '1';
    sel_mux_2 <= '0';
    wait for CYCLE;
    
    sel_mux_1 <= '0';
    sel_mux_2 <= '1';
    wait for CYCLE;
    
    wait;
  end process;

end Behavioral;
