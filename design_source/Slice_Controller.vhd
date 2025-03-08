library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity Slice_Controller is
  generic (
    K                  : integer := hyperparam_K;
    B                  : integer := hyperparam_B;
    MUX_SEL_WIDTH      : integer := hyperparam_MUX_SEL_WIDTH;
    BIAS_WIDTH         : integer := hyperparam_BIAS_WIDTH;
    PACKED_INPUT_WIDTH : integer := hyperparam_PACKED_INPUT_WIDTH
  );
  port (
    rows_state            : in rows_state_t;
    SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    packed_input          : in std_logic_vector(PACKED_INPUT_WIDTH-1 downto 0);
    en_I_ext, en_W_ext, 
    en_I_L, en_psum_out, 
    sel_mux_1, sel_mux_2  : out K_K_t;
    sel_mux_RSRB          : out sel_mux_RSRB_t;
    en_RSRB               : out std_logic_vector(K-1 downto 0);
    en_root, en_bias      : out std_logic;
    I_ext                 : out K_K_B_t;
    W_ext                 : out K_B_t;
    bias                  : out std_logic_vector(BIAS_WIDTH-1 downto 0);
    
    clk, rst, run : in std_logic
  );
end Slice_Controller;

architecture Behavioral of Slice_Controller is
  signal concat_rows_state : std_logic_vector(8 downto 0);
  type unpacked_input_t is array(0 to 2*K-1-1) of std_logic_vector(B-1 downto 0);
  signal unpacked_input : unpacked_input_t;
  
  signal r_sel_mux_1, r_sel_mux_2, r_en_psum_out : K_K_t;
  signal en_r_sel_mux : std_logic_vector(K-1 downto 0);
  
  procedure row_new (
    signal SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_I_ext, en_W_ext, 
           en_I_L, en_psum_out, 
           sel_mux_1, sel_mux_2  : out std_logic_vector(K-1 downto 0);
    signal sel_mux_RSRB          : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_sel_mux, en_RSRB   : out std_logic
  ) is 
  begin
    en_I_ext <= (others => '1');
    en_W_ext <= (others => '0');
    en_I_L <= (others => '1');
    sel_mux_1 <= (others => '1');
    sel_mux_2 <= (others => '1');
    en_psum_out <= (others => '1');
    sel_mux_RSRB <= SB_idx;
    en_sel_mux <= '1'; en_RSRB <= '1';
  end procedure;
  
  procedure row_shift (
    signal SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_I_ext, en_W_ext, 
           en_I_L, en_psum_out, 
           sel_mux_1, sel_mux_2  : out std_logic_vector(K-1 downto 0);
    signal sel_mux_RSRB          : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_sel_mux, en_RSRB   : out std_logic
  ) is
    variable tmp_sel_mux_2 : std_logic_vector(K-1 downto 0);
  begin
    en_I_ext(K-1 downto 1) <= (others => '0');
    en_I_ext(0) <= '1';
    
    en_W_ext <= (others => '0');
    en_I_L <= (others => '1');
   
    sel_mux_1 <= (others => '1');
    sel_mux_2(K-1 downto 1) <= (others => '0');
    sel_mux_2(0) <= '1';
    
    en_psum_out <= (others => '1');
    sel_mux_RSRB <= SB_idx;
    en_sel_mux <= '1'; en_RSRB <= '1';
  end procedure;
  
  procedure row_inherit (
    signal SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_I_ext, en_W_ext, 
           en_I_L, en_psum_out, 
           sel_mux_1, sel_mux_2  : out std_logic_vector(K-1 downto 0);
    signal sel_mux_RSRB          : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_sel_mux, en_RSRB   : out std_logic
  ) is
  begin
    en_I_ext <= (others => '0');
    en_W_ext <= (others => '0');
    en_I_L <= (others => '1');
    sel_mux_1 <= (others => '0');
    sel_mux_2 <= (others => '1');
    en_psum_out <= (others => '1');
    sel_mux_RSRB <= SB_idx;
    en_sel_mux <= '1'; en_RSRB <= '1';
  end procedure;
  
  procedure row_halt (
    signal SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_I_ext, en_W_ext, 
           en_I_L, en_psum_out, 
           sel_mux_1, sel_mux_2  : out std_logic_vector(K-1 downto 0);
    signal sel_mux_RSRB          : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_sel_mux, en_RSRB   : out std_logic
  ) is
  begin
    en_I_ext <= (others => '0');
    en_W_ext <= (others => '0');
    en_I_L <= (others => '0');
    sel_mux_1 <= (others => '0');
    sel_mux_2 <= (others => '0');
    en_psum_out <= (others => '0');
    sel_mux_RSRB <= SB_idx;
    en_sel_mux <= '0'; en_RSRB <= '0';
  end procedure;
  
  procedure row_weight (
    signal SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_I_ext, en_W_ext, 
           en_I_L, en_psum_out, 
           sel_mux_1, sel_mux_2  : out std_logic_vector(K-1 downto 0);
    signal sel_mux_RSRB          : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_sel_mux, en_RSRB   : out std_logic
  ) is
  begin
    en_I_ext <= (others => '0');
    en_W_ext <= (others => '1');
    en_I_L <= (others => '0');
    sel_mux_1 <= (others => '0');
    sel_mux_2 <= (others => '0');
    en_psum_out <= (others => '0');
    sel_mux_RSRB <= SB_idx;
    en_sel_mux <= '1'; en_RSRB <= '1';
  end procedure;
  
  procedure row_bias (
    signal SB_idx                : in std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_I_ext, en_W_ext, 
           en_I_L, en_psum_out, 
           sel_mux_1, sel_mux_2  : out std_logic_vector(K-1 downto 0);
    signal sel_mux_RSRB          : out std_logic_vector(MUX_SEL_WIDTH-1 downto 0);
    signal en_sel_mux, en_RSRB   : out std_logic
  ) is
  begin
    en_I_ext <= (others => '0');
    en_W_ext <= (others => '0');
    en_I_L <= (others => '0');
    sel_mux_1 <= (others => '0');
    sel_mux_2 <= (others => '0');
    en_psum_out <= (others => '0');
    sel_mux_RSRB <= SB_idx;
    en_sel_mux <= '1'; en_RSRB <= '1';
  end procedure;
begin
  
--------------------------------------------------------------------------- hardcoded for K=3
  UNPACK : for i in 0 to 2*K-1-1 generate
    unpacked_input(i) <= packed_input(i*B+B-1 downto i*B);
  end generate UNPACK;
  
  concat_rows_state <= rows_state(0) & rows_state(1) & rows_state(2) when run = '1' else
                       (others => '0'); -- halt
  
  process(concat_rows_state, 
          unpacked_input(0), 
          unpacked_input(1), 
          unpacked_input(2), 
          unpacked_input(3), 
          unpacked_input(4)) is begin
    for i in 0 to K-1 loop 
      for j in 0 to K-1 loop
        I_ext(i,j) <= (others => '0');
      end loop;
      W_ext(i) <= (others => '0');
    end loop;
    bias <= (others => '0');
--   hhh, whh, wwh, www, bbb,
--   nhh, snh, ssn, sss,
--   iss, iis, iin, sis,
--   hss, hhs
--   001 new, 010 shift, 011 inherit, 100 weight, 101 bias, 000/others halt
    case concat_rows_state is
      when "000000000" => --hhh
        null;
      when "100000000" => --whh
        W_ext(0) <= unpacked_input(0);
        W_ext(1) <= unpacked_input(1);
        W_ext(2) <= unpacked_input(2);
      when "100100000" => --wwh
        W_ext(0) <= unpacked_input(0);
        W_ext(1) <= unpacked_input(1);
        W_ext(2) <= unpacked_input(2);
      when "100100100" => --www
        W_ext(0) <= unpacked_input(0);
        W_ext(1) <= unpacked_input(1);
        W_ext(2) <= unpacked_input(2);
      when "101101101" => --bbb
        bias <= unpacked_input(3) & unpacked_input(2) & unpacked_input(1) & unpacked_input(0);
      when "001000000" => --nhh
        I_ext(0,0) <= unpacked_input(0); I_ext(0,1) <= unpacked_input(1); I_ext(0,2) <= unpacked_input(2);
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= (others => '0');
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= (others => '0');
      when "010001000" => --snh
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= unpacked_input(3);
        I_ext(1,0) <= unpacked_input(0); I_ext(1,1) <= unpacked_input(1); I_ext(1,2) <= unpacked_input(2);
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= (others => '0');
      when "010010001" => --ssn
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= unpacked_input(3);
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= unpacked_input(4);
        I_ext(2,0) <= unpacked_input(0); I_ext(2,1) <= unpacked_input(1); I_ext(2,2) <= unpacked_input(2);
      when "010010010" => --sss
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= unpacked_input(0);
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= unpacked_input(1);
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= unpacked_input(2);
      when "011010010" => --iss
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= (others => '0'); 
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= unpacked_input(0);
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= unpacked_input(1);
      when "011011010" => --iis
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= (others => '0'); 
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= (others => '0'); 
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= unpacked_input(0);
      when "011011001" => --iin
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= (others => '0');  
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= (others => '0');  
        I_ext(2,0) <= unpacked_input(0); I_ext(2,1) <= unpacked_input(1); I_ext(2,2) <= unpacked_input(2);
      when "010011010" => --sis
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= unpacked_input(0);
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= (others => '0');  
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= unpacked_input(1);
      when "000010010" => --hss
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= (others => '0');  
        I_ext(1,0) <= (others => '0');   I_ext(1,1) <= (others => '0');   I_ext(1,2) <= unpacked_input(0);
        I_ext(2,0) <= (others => '0');   I_ext(2,1) <= (others => '0');   I_ext(2,2) <= unpacked_input(1);
      when "000000010" => --hhs
        I_ext(0,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= (others => '0');  
        I_ext(1,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= (others => '0');  
        I_ext(2,0) <= (others => '0');   I_ext(0,1) <= (others => '0');   I_ext(0,2) <= unpacked_input(0);
      when others =>
        null;
    end case;
  end process;
---------------------------------------------------------------------------
  
  GEN_CTRL : for i in 0 to K-1 generate
    process (rows_state(i), SB_idx, run) is begin
      en_r_sel_mux(i) <= '1';
      en_RSRB(i) <= '1';
      if run = '1' then
        case rows_state(i) is
          when "001" => row_new     (SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                                     r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                                     en_r_sel_mux(i), en_RSRB(i));
          when "010" => row_shift   (SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                                     r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                                     en_r_sel_mux(i), en_RSRB(i));
          when "011" => row_inherit (SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                                     r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                                     en_r_sel_mux(i), en_RSRB(i));
          when "100" => row_weight  (SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                                     r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                                     en_r_sel_mux(i), en_RSRB(i));
          when "101" => row_bias    (SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                                     r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                                     en_r_sel_mux(i), en_RSRB(i));
                                     
          -- when "000"
          when others => row_halt   (SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                                     r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                                     en_r_sel_mux(i), en_RSRB(i));
        end case;
      else
        row_halt(SB_idx, en_I_ext(i), en_W_ext(i), en_I_L(i), r_en_psum_out(i), 
                 r_sel_mux_1(i), r_sel_mux_2(i), sel_mux_RSRB(i),
                 en_r_sel_mux(i), en_RSRB(i));
      end if;
    end process;
  end generate GEN_CTRL;
  
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        for i in 0 to K-1 loop
          sel_mux_1(i)  <= (others => '0');
          sel_mux_2(i)  <= (others => '0');
          en_psum_out(i) <= (others => '1');
        end loop;
      else
        for i in 0 to K-1 loop
          if en_r_sel_mux(i) = '1' then
            sel_mux_1(i) <= r_sel_mux_1(i);
            sel_mux_2(i) <= r_sel_mux_2(i);
          end if;
          en_psum_out(i) <= r_en_psum_out(i);
        end loop;
      end if;
    end if;
  end process;
  
  -- temporarily leave en_root always high for now
  en_root <= '1';
  en_bias <= '1' when concat_rows_state = "101101101" else '0';
  
end Behavioral;
