library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity FSM_and_Slice is
  generic (
    BIAS_WIDTH         : integer := 32;--hyperparam_BIAS_WIDTH;
    PACKED_INPUT_WIDTH : integer := 64;--hyperparam_PACKED_INPUT_WIDTH;
    MUX_SEL_WIDTH      : integer := 3--hyperparam_MUX_SEL_WIDTH
  );
  port (
    s_axis_data        : in std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
    m_axis_data       : out std_logic_vector(BIAS_WIDTH-1 downto 0);
    
    clk, rst     : in std_logic;
    s_axis_valid : in std_logic;
    m_axis_ready : in std_logic;
    s_axis_ready : out std_logic;
    m_axis_valid : out std_logic
  );
end FSM_and_Slice;

architecture rtl of FSM_and_Slice is
  signal packed_input : std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
  signal rows_state : rows_state_t;
  signal SB_idx : std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
  signal run : std_logic;
begin
  FSM_INSTANCE : entity work.FSM
    port map(
      s_axis_data => s_axis_data,
      packed_input => packed_input, rows_state => rows_state, SB_idx => SB_idx,
      
      clk => clk, rst => rst, run => run,
      s_axis_valid => s_axis_valid,
      s_axis_ready => s_axis_ready, 
      m_axis_valid => m_axis_valid,
      m_axis_ready =>m_axis_ready 
    );
  
  SLICE_INSTANCE : entity work.Slice
    port map (
      packed_input => packed_input,
      output => m_axis_data,
      
      clk => clk, rst => rst, run => run,
      SB_idx => SB_idx,
      rows_state => rows_state
    );
end rtl;
