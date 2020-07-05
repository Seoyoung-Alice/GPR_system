library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity make_end is
  port(
  rstn	: in std_logic;
  sys_clk : in std_logic;
  done : in std_logic;

  ram_end	: out std_logic
  );
end make_end;

architecture u_make_end of make_end is
  
  type state_type is (WAIT_D1, WAIT_D0);
	signal state : state_type;
	
	signal end_cnt : std_logic_vector(4 downto 0);
	signal cnt : std_logic_vector(1 downto 0);

begin
  process (rstn, sys_clk, done)
    begin
      if (rstn = '0') then
        ram_end <= '0';
        end_cnt <= (others => '0');
        cnt <= (others => '0');
        
       state <= WAIT_D1;
      elsif rising_edge (sys_clk) then
        case state is
        when WAIT_D1 =>
          ram_end <= '0';
          if (done = '1') then
            state <= WAIT_D0;
          else
            state <= WAIT_D1;
          end if;
          
        when WAIT_D0 =>
          if (end_cnt = 31) then  -- ram_end is needed 31ea
            end_cnt <= (others => '0');
            state <= WAIT_D1;
          else
            if (done = '0') then
              if (cnt = 1) then
                cnt <= cnt + '1';
                ram_end <= '1';
                state <= WAIT_D0;
              elsif (cnt = 2) then
                cnt <= (others => '0');
                ram_end <= '1';
                end_cnt <= end_cnt + '1';
                state <= WAIT_D1;
              else
                cnt <= cnt + '1';
                state <= WAIT_D0;
              end if;
            end if;
          end if;
          
        when others =>
          state <= WAIT_D1;
          
        end case;
      end if;
  end process;
end u_make_end;