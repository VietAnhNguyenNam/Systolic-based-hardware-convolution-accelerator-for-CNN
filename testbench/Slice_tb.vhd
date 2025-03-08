library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;
use STD.TEXTIO.ALL;

entity Slice_tb is
--  Port ( );
end Slice_tb;

architecture Behavioral of Slice_tb is
  signal packed_input : std_logic_vector(64-1 downto 0);
  signal I_ext  : K_K_B_t;
  signal W_ext  : K_B_t;
  signal bias   : std_logic_vector(32-1 downto 0);
  signal output : std_logic_vector(32-1 downto 0);
  
  signal clk        : std_logic := '0';
  signal rst        : std_logic;
  signal run        : std_logic;
  signal SB_idx     : std_logic_vector(3-1 downto 0);
  signal rows_state : rows_state_t;
  
  constant CYCLE : time := 10 ns;
  
  --------------------------------
  
  constant B : integer := 8;
  constant K : integer := 3;
  constant SB_INDEX : std_logic_vector(2 downto 0) := "000";
  constant IFMAP_WIDTH : integer := 30;
  type ifmap_t is array (0 to IFMAP_WIDTH-1, 0 to IFMAP_WIDTH-1) of std_logic_vector(B-1 downto 0);
  type kernel_t is array(0 to K-1, 0 to K-1) of std_logic_vector(B-1 downto 0);
  signal ifmap : ifmap_t;
  signal kernel : kernel_t;
  
  signal tmp : std_logic_vector(B-1 downto 0);
  
  signal done : std_logic := '0';
begin
  
  process
    file ifmap_file : text open read_mode is "Slice_ifmap28_test.txt";
    file kernel_file : text open read_mode is "Slice_kernel3_test2.txt";
    variable line_buffer : line;
    variable temp_value : integer;
    
  begin
    for i in 0 to IFMAP_WIDTH-1 loop
      readline(ifmap_file, line_buffer);
      for j in 0 to IFMAP_WIDTH-1 loop
        read(line_buffer, temp_value);
        ifmap(i, j) <= std_logic_vector(to_unsigned(temp_value, B));
      end loop;
    end loop;
    file_close(ifmap_file);
    
    for i in 0 to K-1 loop
      readline(kernel_file, line_buffer);
      for j in 0 to K-1 loop
        read(line_buffer, temp_value);
        kernel(i, j) <= std_logic_vector(to_signed(temp_value, B));
      end loop;
    end loop;
    file_close(kernel_file);
    wait;
  end process;

  process
    file log_file : text open write_mode is "Slice_output28_test.txt";
    variable log_line : line;
  begin
    loop
      wait until rising_edge(clk);
      
      write(log_line, to_integer(unsigned(output)));
      writeline(log_file, log_line);
  
      if done = '1' then
        exit;
      end if;
    end loop;
  
    file_close(log_file);
    wait;
  end process;
  
    
  
--  process is begin
--    wait for CYCLE;
--    tmp <= ifmap(0,0);
--    wait for CYCLE;
--    tmp <= ifmap(0,13);
--    wait for CYCLE;
--    tmp <= ifmap(13,0);
--    wait for CYCLE;
--    tmp <= ifmap(13,13);
--    wait for CYCLE;
--    tmp <= ifmap(3,2);
--    wait for CYCLE;
--    
--    tmp <= kernel(0,0);
--    wait for CYCLE;
--    tmp <= kernel(0,2);
--    wait for CYCLE;
--    tmp <= kernel(2,0);
--    wait for CYCLE;
--    tmp <= kernel(2,2);
--    wait for CYCLE;
--    tmp <= kernel(1,1);
--    wait;
--  end process;
  
  
  
  uut : entity work.Slice
    port map (
      packed_input => packed_input,
      output => output,
      
      clk => clk, rst => rst, run => run,
      SB_idx => SB_idx, rows_state => rows_state
    );
    
  clk <= not clk after CYCLE/2;
  
  process is 
    procedure shorthand_state_input(
      r0, r1, r2 : in std_logic_vector(2 downto 0);
      input      : in std_logic_vector(63 downto 0)
    ) is
    begin
      rows_state(0) <= r0;
      rows_state(1) <= r1;
      rows_state(2) <= r2;
      packed_input <= input;
      wait for CYCLE;
    end procedure;
  begin
    rst <= '1';
    run <= '1';
    wait for 2*CYCLE+CYCLE/2;
    
    rst<= '0';
    SB_idx <= SB_INDEX;
    
    shorthand_state_input("100","000","000",x"87131A0000000000");    -- whh
    shorthand_state_input("100","100","000",x"CC90110000000000");    -- wwh
    shorthand_state_input("100","100","100",x"D2EC300000000000");    -- www
    shorthand_state_input("101","101","101",x"0000000A00000000");    -- bbb
                                      
    shorthand_state_input("001","000","000",x"0000000000000000");    -- nhh
    shorthand_state_input("010","001","000",x"002E2A0000000000");    -- snh
    shorthand_state_input("010","010","001",x"0004A1000E000000");    -- ssn
    shorthand_state_input("010","010","010",x"00117A0000000000");    -- sss
    shorthand_state_input("010","010","010",x"0005510000000000");    -- sss
    shorthand_state_input("010","010","010",x"0055C50000000000");    -- sss
    shorthand_state_input("010","010","010",x"005EBC0000000000");    -- sss
    shorthand_state_input("010","010","010",x"00A82B0000000000");    -- sss
    shorthand_state_input("010","010","010",x"0044930000000000");    -- sss
    shorthand_state_input("010","010","010",x"0072A80000000000");    -- sss
    shorthand_state_input("010","010","010",x"00988C0000000000");    -- sss
    shorthand_state_input("010","010","010",x"008DEE0000000000");    -- sss
    shorthand_state_input("010","010","010",x"007ABC0000000000");    -- sss
    shorthand_state_input("010","010","010",x"00B4EA0000000000");    -- sss
                                      
    shorthand_state_input("011","010","010",x"00E9000000000000");    -- iss
    shorthand_state_input("011","011","010",x"0000000000000000");    -- iis
    shorthand_state_input("011","011","001",x"0076050000000000");    -- iin

    

----    whh
--    shorthand_state_weight("100","000","000",kernel(2,0),kernel(2,1),kernel(2,2));
----    wwh
--    shorthand_state_weight("100","100","000",kernel(1,0),kernel(1,1),kernel(1,2));
----    www
--    shorthand_state_weight("100","100","100",kernel(0,0),kernel(0,1),kernel(0,2));
----    nhh
--    I_ext(0,0) <= ifmap(0,0); I_ext(0,1) <= ifmap(0,1); I_ext(0,2) <= ifmap(0,2);
--    shorthand_state_weight("001","000","000",   x"00",x"00",x"00");
----    snh
----                      I_ext(0,0) <= std_logic_vector(to_unsigned(10, B));        -- test
--    I_ext(0,2) <= ifmap(0,3);
--    I_ext(1,0) <= ifmap(1,0); I_ext(1,1) <= ifmap(1,1); I_ext(1,2) <= ifmap(1,2);
--    shorthand_state_weight("010","001","000",   x"00",x"00",x"00");
----    ssn
--    I_ext(0,2) <= ifmap(0,4);
--    I_ext(1,2) <= ifmap(1,3);
--    I_ext(2,0) <= ifmap(2,0); I_ext(2,1) <= ifmap(2,1); I_ext(2,2) <= ifmap(2,2);
--    shorthand_state_weight("010","010","001",   x"00",x"00",x"00");
----    sss
--    for i in 5 to IFMAP_WIDTH-1 loop
--      I_ext(0,2) <= ifmap(0,i);
--      I_ext(1,2) <= ifmap(1,i-1);
--      I_ext(2,2) <= ifmap(2,i-2);
--      shorthand_state_weight("010","010","010",   x"00",x"00",x"00");
--    end loop;
--    for i in 1 to IFMAP_WIDTH-2-1 loop
--  --    iss   2
--      I_ext(1,2) <= ifmap(i,IFMAP_WIDTH-1);
--      I_ext(2,2) <= ifmap(i+1,IFMAP_WIDTH-2);
--      shorthand_state_weight("011","010","010",   x"00",x"00",x"00");
--  --    iis   3
--      I_ext(2,2) <= ifmap(i+1,IFMAP_WIDTH-1);
--      shorthand_state_weight("011","011","010",   x"00",x"00",x"00");
--  --    iin   4
--      I_ext(2,0) <= ifmap(i+2,0); I_ext(2,1) <= ifmap(i+2,1); I_ext(2,2) <= ifmap(i+2,2); 
--      shorthand_state_weight("011","011","001",   x"00",x"00",x"00");
----      iis
--      for j in 3 to IFMAP_WIDTH-2-2-1 loop
--        I_ext(2,2) <= ifmap(i+2,j);
--        shorthand_state_weight("011","011","010",   x"00",x"00",x"00");
--      end loop;
--  --    sis     14
--      I_ext(0,2) <= ifmap(i,IFMAP_WIDTH-2);
--      I_ext(2,2) <= ifmap(i+2,IFMAP_WIDTH-4);
--      shorthand_state_weight("010","011","010",   x"00",x"00",x"00");
--  --    sss     15
--      I_ext(0,2) <= ifmap(i,IFMAP_WIDTH-1);
--      I_ext(1,2) <= ifmap(i+1,IFMAP_WIDTH-2);
--      I_ext(2,2) <= ifmap(i+2,IFMAP_WIDTH-3);
--      shorthand_state_weight("010","010","010",   x"00",x"00",x"00");
--    end loop;

    
----    hss
--    I_ext(1,2) <= ifmap(IFMAP_WIDTH-1-1,IFMAP_WIDTH-1);
--    I_ext(2,2) <= ifmap(IFMAP_WIDTH-1,IFMAP_WIDTH-2);
--    shorthand_state_weight("000","010","010",   x"00",x"00",x"00");
----    hhs
--    I_ext(2,2) <= ifmap(IFMAP_WIDTH-1,IFMAP_WIDTH-1);
--    shorthand_state_weight("000","000","010",   x"00",x"00",x"00");
----    hhh
--    shorthand_state_weight("000","000","000",   x"00",x"00",x"00");  
    
    wait for 5*CYCLE;
    done <= '1';
    
    wait;
  end process;

end Behavioral;

