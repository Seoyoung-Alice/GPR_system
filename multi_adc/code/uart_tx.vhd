library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_tx is
  port(
      rstn        :   in  std_logic;
      sys_clk     :   in  std_logic;
      data_tx_in  :   in  std_logic_vector(7 downto 0);  ----------
      start_sig   :   in  std_logic;
      
      busy        :   out std_logic;
      tx_data     :   out std_logic
  );
end uart_tx;

architecture u_tx of uart_tx is
    type  state_type is (IDLE, START, SEND, PARITY, STOP);
      
      signal  state     :   state_type;
      signal  bit_cnt   :   std_logic_vector(3 downto 0);
      signal  cnt       :   std_logic_vector(8 downto 0);
      signal  tx        :   std_logic_vector(7 downto 0);
      signal  temp_data :   std_logic_vector(7 downto 0); 
      signal  start_d   :   std_logic;
      signal  flag      :   std_logic;
      
      signal  pclk      :   std_logic;

begin
  
  process(rstn, sys_clk)
    begin
      if(rstn = '0') then
        start_d   <=  '0';
        flag      <=  '0';
        temp_data <=  (others => '0');
        
      elsif rising_edge(sys_clk) then
        start_d   <=  start_sig;
        if(start_d = '0') and (start_sig = '1') then
          flag  <=  '1';
          temp_data <=  data_tx_in;   -------------------
        elsif (state = START) then
          flag  <= '0';
        end if;
      end if;
    end process;
    
  process(rstn, sys_clk)
    begin
      if(rstn = '0') then
        pclk  <=  '0';
        cnt   <=  (others => '0');
      elsif rising_edge(sys_clk) then
--        if(cnt = 86) then     -- 115200 bps -> in 20MHz
        if(cnt = 1) then    -- 115200 bps -> in 100MHz
          pclk  <=  not pclk;
          cnt   <=  (others => '0');
        else
          cnt   <=  cnt + 1;
        end if;
      end if;
    end process;
  
  process(rstn, pclk)
    begin
      if(rstn = '0') then
        state       <=  IDLE;
        tx          <= (others => '0');
        bit_cnt     <= (others => '0');
        busy        <= '0';
        
      elsif rising_edge(pclk) then
        case state is
        when  IDLE  =>
          if(flag = '1') then
            state     <=  START;
          else
            state     <=  IDLE;
          end if;
          tx          <= (others => '0');
          bit_cnt     <= (others => '0');
          busy        <=  '0';
          
        when  START =>
          state     <= SEND;
          busy      <=  '1';
          tx        <= temp_data;
          
        when  SEND =>
          if(bit_cnt = 7) then
            bit_cnt <= (others => '0');
--            state   <=  PARITY;
            state   <=  STOP;
          else
            bit_cnt <= bit_cnt + 1;
            state   <=  SEND;
            tx   <= '0' & tx(7 downto 1);
          end if;
          
          busy <= '1';
          
--        when  PARITY  =>
--          state   <=  STOP;
        
        when STOP  =>
          state     <=  IDLE;
          busy      <=  '1';
                    
        when others =>  state <=  IDLE;
        end case;
      end if;
    end process;
    
    tx_data   <=  tx(0)  when state = SEND else
                  '0'    when state = START or state = PARITY else
                  '1';
end u_tx;






