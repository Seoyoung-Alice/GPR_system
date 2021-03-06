library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_control is
  port(
    rstn          : in  std_logic;
    sys_clk       : in  std_logic;
    all_done      : in  std_logic;
    re_data       : in  std_logic_vector(15 downto 0);
    busy          : in  std_logic;
    
    re_en         : out std_logic;
--    re_addr       : out std_logic_vector(16 downto 0);
    re_addr       : out std_logic_vector(10 downto 0);
    data_uart     : out std_logic_vector(7 downto 0);
   -- ram_end       : out std_logic;
    clk_out       : out std_logic;
    start_sig     : out std_logic
  );
end uart_control;

architecture u_uart_control of uart_control is
  
  type state_type is (IDLE, ADDR_INC, READ_DATA, SUM, AVERAGE, LSB_DATA, WAIT_BUSY, MSB_DATA, DATA_COUNT, TEMP, TEMP_2, TEMP_3);
  signal  state         : state_type;
  signal  temp_data     : std_logic_vector(15 downto 0);
  signal  re_cnt        : std_logic_vector(11 downto 0);  -- 0~32*1024 : addr
  
  signal  busy_d        : std_logic;
  signal  flag          : std_logic;
  
  signal  flag_busy     : std_logic;
  
  signal  count         : std_logic_vector(5 downto 0);   -- 0~32
  signal  total_data    : std_logic_vector(20 downto 0);  -- 16bit, 32set
  signal  row_addr      : std_logic_vector(10 downto 0);  -- 0~1024 => 1024ea, 32set
  signal  re_temp_data  : std_logic_vector(15 downto 0);
  
  signal pclk : std_logic;	---- ++++ add
  signal cnt : std_logic_vector(8 downto 0);	---- ++++ add
  
begin
  
  process(rstn, sys_clk)    ---- ++++ add process
    begin
      if(rstn = '0') then
        pclk  <=  '0';
        cnt   <=  (others => '0');
      elsif rising_edge(sys_clk) then
        if(cnt = 433) then    -- 115200 bps -> in 200MHz
--        if(cnt = 86) then       -- 115200 bps -> in 20MHz
          pclk  <=  not pclk;
          cnt   <=  (others => '0');
        else
          cnt   <=  cnt + 1;
        end if;
        
      end if;
    end process;
    
  process(rstn, sys_clk)
    begin
      if(rstn = '0') then
        busy_d <= '0';
      elsif rising_edge(sys_clk) then
        busy_d <= busy;
      end if;
    end process;
    
    flag_busy <= '1' when (busy_d = '1') and (busy = '0') else '0';
    
    clk_out  <= pclk;
  
  process(rstn, pclk)
    begin
      if(rstn = '0') then
        state <= IDLE;
        temp_data <= (others => '0');
       -- ram_end <= '0';
        re_cnt  <= (others => '0');
        re_addr <= (others => '0');
        data_uart    <= (others => '0');
        flag    <= '0';
        
        row_addr <= (others => '0');
        count <= (others => '0');
        total_data <= (others => '0');
        
        re_temp_data <= (others => '0');
          
      elsif rising_edge(pclk) then
        case state is
          when IDLE =>
            if(all_done = '1') then
              state <= TEMP;
            else
              state <= IDLE;
            end if;
            re_cnt <= (others => '0');
           -- ram_end <= '0';
            
            row_addr <= (others => '0');
            count <= (others => '0');
            total_data <= (others => '0');
            
            flag <= '0';
            
            
          when TEMP =>
            
            re_addr <= re_cnt(10 downto 0);
            state <= TEMP_2;
            
          when TEMP_2 =>
           
            state <=  TEMP_3;
            
          when TEMP_3 =>
             total_data <= total_data + re_data;
             state <= ADDR_INC;
            
              
          when ADDR_INC =>
--              if(re_cnt < 8) then         -- 8EA, 32set
              if(re_cnt < 60) then        -- 1024EA, 32set
                if(row_addr = 0) then
                  state <= ADDR_INC;
                  re_cnt <= re_cnt + 60;
                else
                  if(count = 0) then
                    re_cnt <= re_cnt + 60;
                    state <= READ_DATA;
                  else
                    if(count = 32) then
                      state <= READ_DATA;
                    else
                      re_cnt <= re_cnt + 60;
                      state  <= READ_DATA;
                    end if;
                  end if;
                end if;
              else
                re_cnt <= re_cnt + 60;
                state  <= READ_DATA;
              end if;
              
--              re_addr <= re_cnt(8 downto 0);
              re_addr <= re_cnt(10 downto 0);
            
          when READ_DATA =>
            if(re_cnt = 0) and (row_addr = 0) then
              state <= DATA_COUNT;
            else
              state <= SUM;
            end if;
            count <= count + 1;
            
          when SUM =>
            if(count = 31) then
              if(row_addr = 0) then
                total_data <= re_data + total_data;
                state <= AVERAGE;
              else
             	  total_data <= re_data + total_data;
                state  <= ADDR_INC;
              end if;
              
            elsif(count = 32) then
              total_data <= re_data + total_data;
              state <= AVERAGE;

            else
              total_data <= re_data + total_data;
              state  <= ADDR_INC;
            end if;
            
          when AVERAGE => -- divide to 32
            temp_data <= total_data(20 downto 5);
            flag <= '1';
            state <= LSB_DATA;
            count <= (others => '0');
            
          when LSB_DATA =>
            if(busy = '0') and (flag = '1') then
              data_uart <= temp_data(7 downto 0);
              state <= WAIT_BUSY;
            else
              state  <= LSB_DATA;
            end if;
            
          when WAIT_BUSY =>
            if(busy = '0') then
              if(flag = '1') then
                state <= MSB_DATA;
              end if;
            else
              state <= WAIT_BUSY;
            end if;
            
          when MSB_DATA =>
            if(busy = '0') then
              data_uart <= temp_data(15 downto 8);
              state <= DATA_COUNT;
              row_addr <= row_addr + 1;
            else
              state <= MSB_DATA;
            end if;
            
          when DATA_COUNT =>
            if(re_cnt = 1979) then
              state <= IDLE;
              
            elsif(busy = '0') then
              state <= ADDR_INC;
              
--              re_cnt <= "00000000000" & row_addr;
              re_cnt <= '0' & row_addr;
              total_data <= (others => '0');
              re_temp_data <= (others => '0');
              
            else
              state <= DATA_COUNT;
            end if;
            
          when others => state <= IDLE;
        end case;
      end if;
  end process;
  
  re_en <= '0' when (state = IDLE) else '1';
  start_sig <= '1' when (state = LSB_DATA) or (state = MSB_DATA) else '0';
      
end u_uart_control;
            
            
