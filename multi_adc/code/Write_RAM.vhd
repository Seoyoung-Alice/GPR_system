library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Write_RAM is
  port(
	rstn	: in std_logic;
	trig	: in std_logic;
	wr_clk	: in std_logic;
	sam_sig : in std_logic_vector(9 downto 0); 
	
	ram_end : in std_logic;
	
	sys_clk : in std_logic;
	clk_out : in std_logic;

	wr_en	: out std_logic;
	wr_addr	: out std_logic_vector(14 downto 0);
	wr_data	: out std_logic_vector(15 downto 0);
	
	all_done : out std_logic; -----------
	done	: out std_logic
  );
end Write_RAM;

architecture u_Write_RAM of Write_RAM is

	type state_type is (IDLE, WRITE_CNT, DONE_DELAY, WAIT_END);
	type state_type_2 is (IDLE_2, DONE_OUT, DELAY);
	
	signal state 	: state_type;
	signal state_2 : state_type_2;

	signal	wr_cnt	: std_logic_vector(14 downto 0);
--	signal	done_cnt	: std_logic_vector(10 downto 0);
	
	signal bit_cnt : std_logic_vector(3 downto 0); -----------------
	signal done_flag : std_logic;
	

begin

  process (rstn, wr_clk, wr_cnt, bit_cnt, ram_end)   ---------------
    begin
	if(rstn = '0') then
	  --wr_en	  <= '0';
	  --wr_addr <= (others => '0');
	  --wr_data <= (others => '0');
--	  done	<= '0';

	  wr_cnt   <= (others => '0');
--	  done_cnt <= (others => '0');
	  
	  bit_cnt  <= (others => '0');  ---------------
--	  all_done <= '0';

	  state <= IDLE;
	elsif rising_edge(wr_clk) then
	  case state is

		when IDLE =>
		  --wr_en	    <= '0';
		  --wr_addr   <= (others => '0');
		  --wr_data <= (others => '0');
--		  done      <= '0';

		  wr_cnt    <= (others => '0');
--		  done_cnt  <= (others => '0');
		  
		  bit_cnt   <= (others => '0');  --------------

		  if (trig = '1') then
		    --wr_en <= '1';
		
		    state <= WRITE_CNT;
		  else
		    state <= IDLE;
		  end if;

		when WRITE_CNT =>
		  if (bit_cnt = 7) then
--		    done      <= '1';
		    --wr_cnt  <= (others => '0');
		    bit_cnt   <= (others => '0'); ----------
		    --wr_en     <= '0';
		    wr_cnt  <= wr_cnt + '1';  -------------------------------------
		    state     <= DONE_DELAY; 
		  else
		    --wr_addr <= wr_cnt;
		    wr_cnt  <= wr_cnt + '1';
        --wr_data <= "000000" & sam_sig;
        
        bit_cnt <= bit_cnt + '1'; -----------
        
		    state   <= WRITE_CNT;
		  end if;
      
		when DONE_DELAY =>  
		  if (wr_cnt = 256) then
		    state <= IDLE;
		  else
		    state <= WAIT_END;
		  end if;  
--		  if (done_cnt = 5) then
--		    done    <= '0';
		    
--		    state   <= WAIT_END;   
--		  else
--		    done     <= '1';
--		    done_cnt <= done_cnt + '1';
		    
--		    state    <= DONE_DELAY;
--  	   end if;
  	   
	   when WAIT_END =>
	     if (wr_cnt = 255) then
--	       all_done <= '1';
	       wr_cnt   <= (others => '0');
	       
	       state    <= IDLE;
	     else
	         if (ram_end = '1') then
	           state <= WRITE_CNT;
	         else
	           state <= WAIT_END;
	         end if;
	     end if;
	     
	       
--      wr_en <= '0';
--      if (ram_end = '1') then
--        done <= '0';
        
--        state <= WAIT_ACC;
--      else 
--        done  <= '1';
        
--        state <= DONE_DELAY;
--      end if;


		when others =>
		  state <= IDLE;
	  end case;
  end if;
  end process;
  
  --type state_type_2 is (IDLE_2, DONE_OUT, DELAY);
  
  process (rstn, sys_clk, clk_out, done_flag)
    begin
      if(rstn = '0') then
        all_done <= '0';
        state_2 <= IDLE_2;
        
      elsif rising_edge (sys_clk) then
        case state_2 is

		    when IDLE_2 =>
		      if(done_flag = '1') then
		        all_done <= '1';
            state_2 <= DONE_OUT;
          else
            state_2 <= IDLE_2;
            all_done <= '0';
          end if;
          
            
        when DONE_OUT =>
          if(clk_out = '1') then
            state_2 <= DELAY;
          else
            state_2 <= DONE_OUT;
          end if;
          
--        when DELAY =>
--          if(clk_out = '0') then
--            state_2 <= DONE_OUT;
--          else
--            state_2 <= DELAY;
--          end if;   
          
        when others =>
          state_2 <= IDLE_2;
        
        end case;
      end if;
    end process;
      
      
  wr_en   <= '1' when state = WRITE_CNT else '0';
  wr_addr <= wr_cnt;
  wr_data <= "000000" & sam_sig when state = WRITE_CNT else (others => '0');
  
  done     <= '1' when (state = DONE_DELAY) else '0';
  done_flag <= '1' when (wr_cnt = 256) else '0'; --((wr_cnt = 256) and (state = DONE_DELAY)) else '0';
  
end u_Write_RAM;