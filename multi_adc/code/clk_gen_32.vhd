library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.all;
	
entity clk_gen_32 is
   port(
      trig : in std_logic;
      rstn : in std_logic;
      sys_clk : in std_logic;
      ram_end : in std_logic;
      sam_clk : out std_logic
   );
   end clk_gen_32;
	
architecture Young of clk_gen_32 is

   type state_type is (IDLE, COUNT, WAIT_32);
   signal state : state_type;
   --signal sys_cnt : std_logic_vector(7 downto 0);
   signal sam_sig : std_logic;
   signal cnt_32  : std_logic_vector(4 downto 0);
   signal sam_cnt : std_logic_vector(9 downto 0); ---------- counter signal
--   signal sam_cnt : std_logic_vector(7 downto 0); ---------- counter signal

begin
process(rstn, sys_clk, ram_end)
begin
	if(rstn = '0') then
		sam_sig <= '0';
		sam_cnt <= (others => '0');
		cnt_32 <= (others => '0');
	elsif rising_edge(sys_clk) then
		case state is
			when IDLE =>
				if trig = '1' then
					state <= COUNT;
					sam_sig <= '1'; --1
				else
					state <= IDLE;
					sam_sig <= '0'; --1 
					sam_cnt <= (others => '0'); --1
					cnt_32 <= (others => '0'); --1
				end if;
									--sam_sig <= '0';  --2
					--sam_cnt <= (others => '0'); --2
					--cnt_32 <= (others => '0'); --2
			when COUNT =>
					if sam_cnt = 7 then
--          if sam_cnt = 255 then
					  cnt_32 <= cnt_32 + '1'; 
		        if cnt_32 = 31 then 
						  state <= IDLE;
						  sam_sig <= '0'; --1
						  --sam_clk <= '0'; --3
						else
						  state <= WAIT_32;
						  sam_sig <= '0'; --1
						  --sam_clk <= '0'; --3 
						end if;
						  
					else
						sam_cnt <= sam_cnt + '1';
						state <= COUNT;
						sam_sig <= '1'; --1
					end if;
					sam_sig <= '1'; --2
			when WAIT_32 =>
			   if (ram_end = '1') then
			  		 state <= COUNT;
			  		 sam_sig <= '1'; --1
		     else
		       state <= WAIT_32;
		       sam_sig <= '0'; --1
		       --sam_clk <= '0'; --3
		       sam_cnt <= (others => '0'); --1
		     end if;
		      
			when others =>
				state <= IDLE;
			end case;
	end if;
end process;
sam_clk <= sys_clk when state = COUNT else
           '0';
end Young;












