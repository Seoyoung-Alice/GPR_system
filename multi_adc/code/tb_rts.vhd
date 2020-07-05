library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_rts is
end tb_rts;

architecture u_tb of tb_rts is
  component mj_total is
    port(
	rstn    : in std_logic;
	trig_in    : in std_logic;
	inclk0 : in std_logic;

	--busy	: in std_logic;

	--data_10bit	: out std_logic_vector(9 downto 0);
	orig_sig    :   out std_logic;
	tx_data     :   out std_logic
    ); end component;

	signal rstn    : std_logic;
	signal trig_in    : std_logic;
	signal inclk0 : std_logic;
	
	signal orig_sig    :   std_logic;
	signal tx_data     :   std_logic;

	--signal busy	: std_logic;

	--signal re_data     :   std_logic_vector(15 downto 0);
	
	--signal count for trig
	
	signal temp_clk : std_logic;
	signal int_cnt : std_logic_vector(99 downto 0);
	
	
	----
	--signal re_en_clk : std_logic;
	--signal re_addr : std_logic_vector(10 downto 0);
	
begin

  process
    begin
	if(NOW = 0 ns) then
	  rstn <= '0', '1' after 5 ns;
	  
	  --busy <= '0', '1' after 300 ns;
	end if;
	wait for 100 ns;
  end process;

  process
    begin
      inclk0 <= '0', '1' after 25 ns;
      wait for 50 ns;
  end process;

   

  process
    begin
      temp_clk <= '0', '1' after 100 ns;
      wait for 200 ns;
    end process;
    
  process(rstn, temp_clk)
    begin
     if(rstn = '0') then
        int_cnt <= (others => '0');
      elsif falling_edge(temp_clk) then
        int_cnt <= int_cnt + 1;
      end if;
    end process;
    
    trig_in <= '1' when int_cnt = 40 or
                     int_cnt = 24000 else
               '0'; 
                
                
      
  u9 : mj_total
  port map (
	rstn	=> rstn,
	trig_in	=> trig_in,
	inclk0	=> inclk0,

  orig_sig => orig_sig,
	tx_data 	=> tx_data );

end u_tb;