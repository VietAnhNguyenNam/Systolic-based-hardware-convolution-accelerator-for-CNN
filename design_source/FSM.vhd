library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity FSM is
  generic (
    B                  : integer        := hyperparam_B;
    K                  : integer        := hyperparam_K;
    BIAS_WIDTH         : integer        := hyperparam_BIAS_WIDTH;
    PACKED_INPUT_WIDTH : integer        := hyperparam_PACKED_INPUT_WIDTH;
    COUNTER_WIDTH      : integer        := hyperparam_COUNTER_WIDTH;
    MUX_SEL_WIDTH      : integer        := hyperparam_MUX_SEL_WIDTH;
    PRE_SSS_LIST       : counter_vals_t := hyperparam_PRE_SSS_LIST;
    PRE_IIS_LIST       : counter_vals_t := hyperparam_PRE_IIS_LIST;
    ITERATENO_LIST     : counter_vals_t := hyperparam_ITERATENO_LIST
  );
  port (
    s_axis_data  : in std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
    packed_input : out std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
    rows_state   : out rows_state_t;
    SB_idx       : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    
    clk, rst     : in std_logic;
    run          : out std_logic;
    s_axis_valid : in std_logic;
    m_axis_ready : in std_logic;
    m_axis_valid : out std_logic;
    s_axis_ready : out std_logic
  );
end FSM;

architecture Behavioral of FSM is             -- hardcoded FSM for K = 3
  type state_t is (
    RESET, 
    hhh, whh, wwh, www, bbb,
    nhh, snh, ssn, sss,
    iss, iis1, iin, iis2, sis,
    hss, hhs
  );
  signal state, next_state : state_t;
  
  signal ifmap_size : std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
  signal en_ifmap_size : std_logic;
  
  signal count_val_1, count_val_2 : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal rst_counter_1, rst_counter_2 : std_logic;
  signal run_counter_1, run_counter_2 : std_logic;
  signal done_counter_1, done_counter_2 : std_logic;
  signal out_counter_1, out_counter_2 : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  
  signal count_sss_val, count_iis_val : std_logic_vector(COUNTER_WIDTH-1 downto 0);
  signal sel_counter1_val : std_logic;
  
  signal r_result_valid : std_logic_vector(1 downto 0);
  signal sel_result_valid : std_logic;
  signal ready_internal : std_logic;
  
  type result_valid_state_t is (S0, S1);
  signal resvad_state, resvad_nextstate : result_valid_state_t;
  signal m_axis_valid_internal : std_logic;
begin
  
  process (clk) is begin
    if rising_edge(clk) then
      if rst = '1' then
        r_result_valid <= (others => '0');
      else
        r_result_valid <= (s_axis_valid and ready_internal) & r_result_valid(1);
      end if;
    end if;
  end process;
  process (clk) is begin
    if rising_edge(clk) then
      if rst = '1' then
        resvad_state <= S0;
      else
        resvad_state <= resvad_nextstate;
      end if;
    end if;
  end process;
  process (resvad_state, r_result_valid(0), m_axis_ready) is begin
    m_axis_valid_internal <= '1';
    resvad_nextstate <= resvad_state;
    case (resvad_state) is
        when S0 =>
          if r_result_valid(0) = '1' then
            if m_axis_ready = '0' then
              resvad_nextstate <= S1;
            end if;
          else
            m_axis_valid_internal <= '0';
          end if;
        when S1 =>
          if m_axis_ready = '0' then
            resvad_nextstate <= S1;
          else
            resvad_nextstate <= S0;
          end if;
        when others => null;
    end case;
  end process;
  m_axis_valid <= m_axis_valid_internal when sel_result_valid = '1' else '0';         

  count_sss_val <= std_logic_vector(to_unsigned(PRE_SSS_LIST(0), COUNTER_WIDTH)) when ifmap_size = "000" else
                   std_logic_vector(to_unsigned(PRE_SSS_LIST(1), COUNTER_WIDTH)) when ifmap_size = "001" else
                   std_logic_vector(to_unsigned(PRE_SSS_LIST(2), COUNTER_WIDTH)) when ifmap_size = "010" else
                   std_logic_vector(to_unsigned(PRE_SSS_LIST(3), COUNTER_WIDTH)) when ifmap_size = "011" else
                   std_logic_vector(to_unsigned(PRE_SSS_LIST(4), COUNTER_WIDTH)) when ifmap_size = "100" else
                   (others => '0');
  count_iis_val <= std_logic_vector(to_unsigned(PRE_IIS_LIST(0), COUNTER_WIDTH)) when ifmap_size = "000" else
                   std_logic_vector(to_unsigned(PRE_IIS_LIST(1), COUNTER_WIDTH)) when ifmap_size = "001" else
                   std_logic_vector(to_unsigned(PRE_IIS_LIST(2), COUNTER_WIDTH)) when ifmap_size = "010" else
                   std_logic_vector(to_unsigned(PRE_IIS_LIST(3), COUNTER_WIDTH)) when ifmap_size = "011" else
                   std_logic_vector(to_unsigned(PRE_IIS_LIST(4), COUNTER_WIDTH)) when ifmap_size = "100" else
                   (others => '0');
  count_val_1   <= count_sss_val when sel_counter1_val = '0' else
                   count_iis_val;
  count_val_2   <= std_logic_vector(to_unsigned(ITERATENO_LIST(0), COUNTER_WIDTH)) when ifmap_size = "000" else
                   std_logic_vector(to_unsigned(ITERATENO_LIST(1), COUNTER_WIDTH)) when ifmap_size = "001" else
                   std_logic_vector(to_unsigned(ITERATENO_LIST(2), COUNTER_WIDTH)) when ifmap_size = "010" else
                   std_logic_vector(to_unsigned(ITERATENO_LIST(3), COUNTER_WIDTH)) when ifmap_size = "011" else
                   std_logic_vector(to_unsigned(ITERATENO_LIST(4), COUNTER_WIDTH)) when ifmap_size = "100" else
                   (others => '0');
  
  COUNTER_1 : entity work.counter
    generic map (WIDTH => COUNTER_WIDTH)
    port map (
      load_val => count_val_1, count => out_counter_1,
      clk => clk, rst => rst_counter_1, run => run_counter_1, done => done_counter_1
    );
    
  COUNTER_2 : entity work.counter
    generic map (WIDTH => COUNTER_WIDTH)
    port map (
      load_val => count_val_2, count => out_counter_2,
      clk => clk, rst => rst_counter_2, run => run_counter_2, done => done_counter_2
    );
  
  packed_input <= s_axis_data;
  SB_idx <= ifmap_size;
  
  SYNC_PROC: process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= RESET;
        ifmap_size <= (others => '0');
      else
        state <= next_state;
        if en_ifmap_size = '1' then
          ifmap_size <= s_axis_data(BIAS_WIDTH+MUX_SEL_WIDTH-1 downto BIAS_WIDTH);
        end if;
      end if;
    end if;
  end process;
  run <= s_axis_valid and ready_internal;
 
  s_axis_ready <= ready_internal;
  OUTPUT_DECODE: process (state, m_axis_ready)
  begin
    ready_internal <= m_axis_ready;
    case (state) is
      when RESET =>
        rows_state(0) <= "000"; rows_state(1) <= "000"; rows_state(2) <= "000";
        ready_internal <= '0';
      when hhh =>
        rows_state(0) <= "000"; rows_state(1) <= "000"; rows_state(2) <= "000";
        ready_internal <= '0';
      when whh =>
        rows_state(0) <= "100"; rows_state(1) <= "000"; rows_state(2) <= "000";
      when wwh =>
        rows_state(0) <= "100"; rows_state(1) <= "100"; rows_state(2) <= "000";
      when www =>
        rows_state(0) <= "100"; rows_state(1) <= "100"; rows_state(2) <= "100";
      when bbb =>
        rows_state(0) <= "101"; rows_state(1) <= "101"; rows_state(2) <= "101";
      when nhh =>
        rows_state(0) <= "001"; rows_state(1) <= "000"; rows_state(2) <= "000";
      when snh =>
        rows_state(0) <= "010"; rows_state(1) <= "001"; rows_state(2) <= "000";
      when ssn =>
        rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "001";
      when sss =>
        rows_state(0) <= "010"; rows_state(1) <= "010"; rows_state(2) <= "010";
      when iss =>
        rows_state(0) <= "011"; rows_state(1) <= "010"; rows_state(2) <= "010";
      when iis1 =>
        rows_state(0) <= "011"; rows_state(1) <= "011"; rows_state(2) <= "010";
      when iin =>
        rows_state(0) <= "011"; rows_state(1) <= "011"; rows_state(2) <= "001";
      when iis2 =>
        rows_state(0) <= "011"; rows_state(1) <= "011"; rows_state(2) <= "010";
      when sis =>
        rows_state(0) <= "010"; rows_state(1) <= "011"; rows_state(2) <= "010";
      when hss =>
        rows_state(0) <= "000"; rows_state(1) <= "010"; rows_state(2) <= "010";
      when hhs =>
        rows_state(0) <= "000"; rows_state(1) <= "000"; rows_state(2) <= "010";
      when others =>
        rows_state(0) <= "000"; rows_state(1) <= "000"; rows_state(2) <= "000";
        ready_internal <= '0';
    end case;
  end process;
 
  NEXT_STATE_DECODE: process (state, s_axis_valid, ready_internal, done_counter_1, done_counter_2, sel_counter1_val)
  begin
    next_state <= state;
    
    en_ifmap_size <= '0';
    sel_result_valid <= '1';
    
    rst_counter_1 <= '0'; run_counter_1 <= '0';
    rst_counter_2 <= '0'; run_counter_2 <= '0';
    sel_counter1_val <= '0';
    case (state) is
      when RESET =>
        sel_result_valid <= '0';
        rst_counter_1 <= '1';
        rst_counter_2 <= '1';
        next_state <= whh;
      when whh =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= wwh;
        end if;
      when wwh =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= www;
        end if;
      when www =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= bbb;
        end if;
      when bbb =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= nhh;
          en_ifmap_size <= '1';
        end if;
      
      when nhh =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= snh;
        end if;
      when snh =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= ssn;
        end if;
      when ssn =>
        sel_result_valid <= '0';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= sss;
          run_counter_1 <= '1';
        end if;
      when sss =>
        if s_axis_valid = '1' and ready_internal = '1' then
          if done_counter_2 = '1' then
            next_state <= hss;
          else
            if sel_counter1_val = '1' then
              next_state <= iss;
            else
              if done_counter_1 = '1' then
                next_state <= iss;
              else
                next_state <= sss;
                run_counter_1 <= '1';
              end if;
            end if;
          end if;
        end if;
      
      when iss =>
        sel_counter1_val <= '1';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= iis1;
          rst_counter_1 <= '1';
          run_counter_2 <= '1';
        end if;
      when iis1 =>
        sel_counter1_val <= '1';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= iin;
        end if;
      when iin =>
        sel_counter1_val <= '1';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= iis2;
          run_counter_1 <= '1';
        end if;
      when iis2 =>
        sel_counter1_val <= '1';
        if s_axis_valid = '1' and ready_internal = '1' then
          run_counter_1 <= '1';
          if done_counter_1 = '1' then
            next_state <= sis;
          else
            next_state <= iis2;
          end if;
        end if;
      when sis =>
        sel_counter1_val <= '1';
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= sss;
        end if;
        
      when hss =>
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= hhs;
        end if;
      when hhs =>
        if s_axis_valid = '1' and ready_internal = '1' then
          next_state <= hhh;
        end if;
      when hhh =>
        next_state <= hhh;
      when others =>
        next_state <= hhh;
     end case;
  end process;
  
  
end Behavioral;
