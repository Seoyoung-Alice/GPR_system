library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
   use ieee.std_logic_arith.all;

entity trig_cont is
port(
   rstn    : in std_logic;
   trig_in : in std_logic;
   sys_clk : in std_logic;

   trig    : out std_logic
);
end trig_cont;

architecture Young of trig_cont is

	type state_type is (IDLE, TRIG_GEN, SIG_WAIT);
	signal state : state_type;
	
	signal cnt	: std_logic_vector(13 downto 0);
	
begin
process(rstn, sys_clk, trig_in)
begin
	if(rstn = '0') then
		cnt <= (others=>'0');
		trig	<= '0';
	elsif rising_edge(sys_clk) then
		case state is
			when IDLE =>
				if (trig_in = '1') then
					state <= TRIG_GEN;
				else
					state <= IDLE;
				end if;
				cnt <= (others=>'0');
			when TRIG_GEN =>
				if (cnt =3) then
					state <= SIG_WAIT;
				else 
					cnt <= cnt+'1';
					state <= TRIG_GEN;
				end if;
				trig <= '1';
			when SIG_WAIT =>
				if (trig_in = '0') then
					state <= IDLE;
				else
					state <= SIG_WAIT;
				end if;
				trig <= '0';
			when others =>
				state <= IDLE;
			end case;
	end if;
end process;
end Young;
