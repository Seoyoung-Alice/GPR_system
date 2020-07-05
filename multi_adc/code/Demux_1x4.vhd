library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.all;
   
entity Demux_1x4 is
   port(
      A   : in std_logic;
      
      SEL : in std_logic_vector(1 downto 0);
		
		  Y1  : out std_logic;
      Y2  : out std_logic;
      Y3  : out std_logic;
      Y4  : out std_logic
   );
end Demux_1x4;

architecture beh of Demux_1x4 is
begin
   Y1 <= A when SEL = "00" else '0';
   Y2 <= A when SEL = "01" else '0';
   Y3 <= A when SEL = "10" else '0';
   Y4 <= A when SEL = "11" else '0';
end beh;