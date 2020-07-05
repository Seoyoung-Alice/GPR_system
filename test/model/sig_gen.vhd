library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
   use ieee.std_logic_arith.all;
	
entity sig_gen is
port(
   rstn    : in std_logic;
   trig    : in std_logic;
   sys_clk : in std_logic;
	ram_end  : in std_logic;
	done     : in std_logic;
   orig_sig : out std_logic
);
end sig_gen;

architecture Young of sig_gen is

	type state_type is (IDLE, COUNT);
	signal state : state_type;
   signal clk_cnt : std_logic_vector(15 downto 0);
   signal temp_sig : std_logic;
	
begin
process(rstn, sys_clk, done, ram_end)
begin
	if(rstn = '0') then
		clk_cnt <= (others => '0');
		temp_sig <= '0';
	elsif rising_edge(sys_clk) then
		case state is
			when IDLE =>
				if (trig = '1') or (ram_end = '1') then
					state <= COUNT;
				else
					state <= IDLE;
				end if;		
				    
					clk_cnt <= (others => '0');
					temp_sig <= '0';
					
			when COUNT =>
				
				
					
--					if (clk_cnt = 49999) then          -- in 50MHz
          if (clk_cnt = 2) then           -- in 20MHz
						temp_sig <= not temp_sig;
						clk_cnt <= (others => '0');
					else 
						clk_cnt <= clk_cnt + 1;
					end if;
					
						if (done='1') then
						state <= IDLE;
						temp_sig <= '0';
					else
						state <= COUNT;
					end if;
					
			when others =>
				state <= IDLE;
			end case;
	end if;
end process;
orig_sig <= temp_sig;
end Young;

