library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
   use ieee.std_logic_arith.all;
   
entity ADC_Model is
port(
  rstn     : in std_logic;
  trig     : in std_logic;
  
  ram_end  : in std_logic;
  done     : in std_logic;
  sam_clk  : in std_logic;
  sam_sig  : out std_logic_vector(9 downto 0)
  );
end ADC_Model;

architecture Young of ADC_Model is
   type state_type is (IDLE, COUNT, WAIT_32);
	signal state : state_type;
	signal cnt : std_logic_vector(9 downto 0);
	signal cnt_32 : std_logic_vector(4 downto 0);
	
  begin
   process(rstn, sam_clk, done, ram_end)
	begin
	if(rstn = '0') then
		cnt <= (others => '0');
		cnt_32 <= (others => '0');
	elsif rising_edge(sam_clk) then
		case state is
			when IDLE =>
				if trig = '1' then
					state <= COUNT;
					cnt <= "0000000001";
				else 
					state <= IDLE;
				end if;
				cnt_32 <= (others => '0');
			when COUNT =>
			  if (cnt = 8) then
			    cnt <= (others => '0');
			  else
			    cnt <= cnt + 1;
			  end if;
			  
			  if (done = '1') then
			    state <= WAIT_32;
			    cnt_32 <= cnt_32 + '1'; 
			  else
			    state <= COUNT;
			    end if;
				
									
			when WAIT_32 =>
			  if (cnt_32 = 31) then
			    state <= IDLE;
			
			  	else
		       state <= WAIT_32;
		     end if;
		     
		     if (ram_end = '1') then
			  		 state <= COUNT;
			  		 else
			  		   state <= WAIT_32;
			  		   end if;
			  		   
		      cnt <= (others => '0');
				
			when others =>
				state <= IDLE;
			end case;
	end if;
end process;

sam_sig <= cnt ;
    end Young;

  
  