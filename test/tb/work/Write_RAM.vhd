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
	wr_addr	: out std_logic_vector(10 downto 0);
	wr_data	: out std_logic_vector(15 downto 0);
	
	all_done : out std_logic; -----------
	done	: out std_logic
  );
end Write_RAM;

architecture u_Write_RAM of Write_RAM is

	type state_type is (IDLE, WRITE_CNT, DONE_DELAY, WAIT_END);
	type state_type_2 is (IDLE_2, CLK_CHECK, WAIT_CLK_1, WAIT_CLK_0);
	
	signal state 	: state_type;
	signal state_2 : state_type_2;

	signal	wr_cnt	: std_logic_vector(15 downto 0);
	
	signal bit_cnt : std_logic_vector(9 downto 0); -----------------
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
		  wr_cnt    <= (others => '0');
		  bit_cnt   <= (others => '0');  --------------

		  if (trig = '1') then
		    state <= WRITE_CNT;
		  else
		    state <= IDLE;
		  end if;
		  

		when WRITE_CNT =>
		  if (bit_cnt = 59) then  --1023
		    bit_cnt   <= (others => '0'); ----------
		    wr_cnt  <= wr_cnt + '1';  -------------------------------------
		    
		    state     <= DONE_DELAY; 
		  else
		    wr_cnt  <= wr_cnt + '1';
        bit_cnt <= bit_cnt + '1'; -----------
        
		    state   <= WRITE_CNT;
		  end if;
      
      
		when DONE_DELAY =>  
		  if (wr_cnt = 1920) then -- 32768
		    state <= IDLE;
		  else
		    state <= WAIT_END;
		  end if;  
  	   
	   when WAIT_END =>
	     if (wr_cnt = 1919) then -- 32767
	       wr_cnt   <= (others => '0');
	       
	       state    <= IDLE;
	     else
	         if (ram_end = '1') then
	           state <= WRITE_CNT;
	         else
	           state <= WAIT_END;
	         end if;
	     end if;


		when others =>
		  state <= IDLE;
	  end case;
  end if;
  end process;
  
  --type state_type_2 is (IDLE_2, clk_check,wait_clk_1, wait_clk_0);
  
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
            state_2 <= CLK_CHECK;
          else
            state_2 <= IDLE_2;
            all_done <= '0';
          end if;
          
            
        when CLK_CHECK =>
          if (clk_out = '0') then
            state_2 <= WAIT_CLK_1;
          else
            state_2 <= WAIT_CLK_0;
          end if;
         
        
        when WAIT_CLK_1 =>
          if(clk_out = '1') then
           state_2 <= IDLE_2;
          else
           state_2 <= wait_clk_1;
          end if;
            
        when WAIT_CLK_0 =>
          if (clk_out = '0')then
           state_2 <= WAIT_CLK_1;
          else 
           state_2 <= WAIT_CLK_0;
          end if;
        
        when others =>
          state_2 <= IDLE_2;
        
        end case;
      end if;
    end process;
      
      
  wr_en   <= '1' when state = WRITE_CNT else '0';
  wr_addr <= wr_cnt(10 downto 0);
  wr_data <= "000000" & sam_sig when state = WRITE_CNT else (others => '0');
  
  done     <= '1' when (state = DONE_DELAY) else '0';
  done_flag <= '1' when (wr_cnt = 1920) else '0'; --((wr_cnt = 256) and (state = DONE_DELAY)) else '0';
								-- 32768
  
end u_Write_RAM;