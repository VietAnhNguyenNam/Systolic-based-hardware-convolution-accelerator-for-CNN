library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity FSM_and_Slice_tb is
--  Port ( );
end FSM_and_Slice_tb;

architecture Behavioral of FSM_and_Slice_tb is
  constant BIAS_WIDTH         : integer := hyperparam_BIAS_WIDTH;
  constant PACKED_INPUT_WIDTH : integer := hyperparam_PACKED_INPUT_WIDTH;
  constant MUX_SEL_WIDTH      : integer := hyperparam_MUX_SEL_WIDTH;
    
  signal s_axis_data : std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
  signal ifmap_size  : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := "000";
  signal m_axis_data : std_logic_vector(BIAS_WIDTH-1 downto 0);
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal s_axis_valid : std_logic;
  signal s_axis_ready : std_logic;
  signal m_axis_valid : std_logic;
  signal m_axis_ready : std_logic;
  
  constant CYCLE : time := 10 ns;
begin
  FSM_AND_SLICE_INSTANCE : entity work.FSM_and_Slice
    port map (
      s_axis_data => s_axis_data,
      m_axis_data => m_axis_data,
      
      clk => clk, rst => rst,
      s_axis_valid => s_axis_valid,
      m_axis_ready => m_axis_ready,
      s_axis_ready => s_axis_ready,
      m_axis_valid => m_axis_valid
    );

  clk <= not clk after CYCLE/2;
  
  process is 
    procedure shorthand_input_svalid_mready(
      input_val : in std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
      valid_val : in std_logic;
      ready_val : in std_logic
    ) is
    begin
      s_axis_data <= input_val;
      s_axis_valid <= valid_val;
      m_axis_ready <= ready_val;
      wait for CYCLE;
    end procedure;
  begin
    rst <= '1';
    wait for CYCLE*2+CYCLE/2;
    rst <= '0';
    
    wait for CYCLE;
    shorthand_input_svalid_mready(x"00000000001A1387", '1', '1');    -- whh
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000001190CC", '1', '1');    -- wwh
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"000000000030ECD2", '1', '1');    -- www
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"000000000000000A", '1', '1');    -- bbb
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    
    shorthand_input_svalid_mready(x"0000000000000000", '1', '1');    -- nhh
--    s_axis_valid <= '0';
--    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000002A2E00", '1', '1');    -- snh
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000E00A10400", '1', '1');    -- ssn
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000007A1100", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000510500", '1', '0');    -- sss
--    s_axis_valid <= '0';
--    m_axis_ready <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000510500", '1', '1');
    shorthand_input_svalid_mready(x"0000000000C55500", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000BC5E00", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000002BA800", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000934400", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000A87200", '1', '1');    -- sss
    s_axis_valid <= '0';
    m_axis_ready <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000008C9800", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000EE8D00", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000BC7A00", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000EAB400", '1', '1');    -- sss
    
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"000000000000E900", '1', '1');    -- iss
--    s_axis_valid <= '0';
--    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000000000", '1', '1');    -- iis
--    s_axis_valid <= '0';
--    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000057600", '1', '1');    -- iin
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000000066", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000000012", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"000000000000004C", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000000000F3", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000000000CB", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000000051", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000000000A0", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000000000F8", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"0000000000000089", '1', '1');    -- iis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"000000000000A5B4", '1', '1');    -- sis
    s_axis_valid <= '0';
    wait for 4*CYCLE;
    shorthand_input_svalid_mready(x"00000000005BE900", '1', '1');    -- sss
    s_axis_valid <= '0';
    wait for 4*CYCLE;
--    shorthand_input_svalid_mready(x"0000000000000000", '1', '1');    
    wait;
    
  end process;
  
end Behavioral;
