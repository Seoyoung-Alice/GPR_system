library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.all;
	
entity ram_clk_gen_32 is
   port(
     rstn    : in std_logic;
    trig    : in std_logic;
    sys_clk : in std_logic;
    ram_end : in std_logic;
    done    : in std_logic;
     ram_clk : out std_logic
   );
   end ram_clk_gen_32;
	
architecture Young of ram_clk_gen_32 is

   type state_type is (IDLE, COUNT, WAIT_1, WAIT_2);
   signal state : state_type;
   signal sam_sig : std_logic;
   signal cnt_32  : std_logic_vector(4 downto 0); 
begin
process(rstn, sys_clk, ram_end, done)
begin
	if(rstn = '0') then
		sam_sig <= '0';
		cnt_32 <= (others => '0');
	elsif rising_edge(sys_clk) then
		case state is
			when IDLE =>
				if trig = '1' then
					state <= COUNT;
					--sam_sig <= '1';--1
				else
					state <= IDLE;
					--sam_sig <= '0';  --1
					--cnt_32 <= (others => '0'); --1
				end if;
					--sam_sig <= '0'; --2
					cnt_32 <= (others => '0'); --2
			when COUNT =>
					if (done = '1') then
					  
					  state <= WAIT_1;
					else
						state <= COUNT;
					end if;
					--sam_sig <= '1'; --2
			when WAIT_1 =>
			  if (done = '0') then
			    state <= WAIT_2;
			  else 
			    state <= WAIT_1;
			  end if;
			  
			when WAIT_2 =>
			  
			  if (ram_end = '1') then
			  	 state <= COUNT;
			  	 cnt_32 <= cnt_32 + '1';
			  else
			    if cnt_32 = 31 then 
						 state <= IDLE;
				  else
					   state <=WAIT_2;
				  end if;
		    end if;
			  
			when others =>
				state <= IDLE;
			end case;
	end if;
end process;
--ram_clk <= sys_clk when sam_sig = '1' else
--           '0';
  ram_clk <= sys_clk when state = COUNT or state = WAIT_1 else
             '0';
  
end Young;




