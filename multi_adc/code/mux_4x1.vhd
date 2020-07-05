library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.all;
   
entity mux_4x1 is
   port(
      A : in std_logic_vector (15 downto 0);
      B : in std_logic_vector (15 downto 0);
      C : in std_logic_vector (15 downto 0);
      D : in std_logic_vector (15 downto 0);
      SEL : in std_logic_vector (1 downto 0);
      Y : out std_logic_vector (15 downto 0)
   );
end mux_4x1;

architecture beh of mux_4x1 is
begin
   Y <= A when SEL = "00" else
        B when SEL = "01" else
        C when SEL = "10" else
        D when SEL = "11" else
        (others => '0');
end beh;