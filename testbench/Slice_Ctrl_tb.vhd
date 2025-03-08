--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use work.common.all;

--entity Slice_Ctrl_tb is
----  Port ( );
--end Slice_Ctrl_tb;

--architecture Behavioral of Slice_Ctrl_tb is
--  signal SB_idx     : std_logic_vector(3-1 downto 0);
--  signal rows_state : rows_state_t;
--  signal en_I_ext, en_W_ext, en_I_L, en_psum_out, sel_mux_1, sel_mux_2 : K_K_t;
--  signal sel_mux_RSRB : sel_mux_RSRB_t;
--  signal en_root, en_bias : std_logic;
  
--  constant CYCLE : time := 10 ns;
--begin
--  uut : entity work.Slice_Controller
--    port map (
--      rows_state => rows_state, SB_idx => SB_idx,
      
--      en_I_ext => en_I_ext, en_W_ext => en_W_ext, 
--      en_I_L => en_I_L, en_psum_out => en_psum_out, 
--      sel_mux_1 => sel_mux_1, sel_mux_2 => sel_mux_2,
--      sel_mux_RSRB => sel_mux_RSRB,
--      en_root => en_root, en_bias => en_bias
--    );
    
--  process is begin
--    rows_state(0) <= "001"; rows_state(1) <= "000"; rows_state(2) <= "000";
--    wait for CYCLE;
    
--    rows_state(0) <= "101"; rows_state(1) <= "001"; rows_state(2) <= "000";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "101"; rows_state(2) <= "001";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "101";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "010";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "010";
--    wait for CYCLE;
    
--    rows_state(0) <= "001"; rows_state(1) <= "000"; rows_state(2) <= "000";
--    wait for CYCLE;
    
--    rows_state(0) <= "101"; rows_state(1) <= "001"; rows_state(2) <= "000";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "101"; rows_state(2) <= "001";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "101";
--    wait for CYCLE;
    
--    rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "010";
--    wait for CYCLE;
--    wait;
--  end process;

--end Behavioral;
