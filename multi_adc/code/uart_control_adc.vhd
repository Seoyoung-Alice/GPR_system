library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_control_adc is
  port(
    rstn          : in  std_logic;
    sys_clk       : in  std_logic;
    
    all_done_1    : in  std_logic;
    all_done_2    : in  std_logic;
    all_done_3    : in  std_logic;
    all_done_4    : in  std_logic;
    
--    re_addr_1     : out std_logic_vector(10 downto 0);
--    re_addr_2     : out std_logic_vector(10 downto 0);
--    re_addr_3     : out std_logic_vector(10 downto 0);
--    re_addr_4     : out std_logic_vector(10 downto 0);
    
--    re_data_1     : in  std_logic_vector(15 downto 0);
--    re_data_2     : in  std_logic_vector(15 downto 0);
--    re_data_3     : in  std_logic_vector(15 downto 0);
--    re_data_4     : in  std_logic_vector(15 downto 0);
    
    ram_count     : out std_logic_vector(1 downto 0);
    
    re_data       : in  std_logic_vector(15 downto 0);
    busy          : in  std_logic;
    
    re_en         : out std_logic;
--    re_addr       : out std_logic_vector(16 downto 0);
    re_addr       : out std_logic_vector(14 downto 0);
    data_uart     : out std_logic_vector(7 downto 0);
   -- ram_end       : out std_logic;
    clk_out       : out std_logic;
    start_sig     : out std_logic
  );
end uart_control_adc;

architecture u_uart_control of uart_control_adc is
  
  type state_type is (IDLE, ADDR_INC, READ_DATA, SUM, AVERAGE, LSB_DATA, WAIT_BUSY, MSB_DATA, DATA_COUNT, TEMP, TEMP_2, TEMP_3);
--  type state_type is (IDLE, ADDR_INC, RAM_SEL, READ_DATA, SUM, AVERAGE, LSB_DATA, WAIT_BUSY, MSB_DATA, DATA_COUNT);
  signal  state         : state_type;
--  signal  temp_data     : std_logic_vector(15 downto 0);
  signal  temp_data     : std_logic_vector(15 downto 0);
  signal  re_cnt        : std_logic_vector(14 downto 0);  -- 0~32*1024 : addr
  
  signal  busy_d        : std_logic;
  signal  flag          : std_logic;
  
  signal  flag_busy     : std_logic;
  
  signal  count         : std_logic_vector(5 downto 0);   -- 0~32
  signal  total_data    : std_logic_vector(20 downto 0);  -- 16bit, 32set
  signal  row_addr      : std_logic_vector(13 downto 0);  -- 0~1024 => 1024ea, 32set
--  signal  re_temp_data  : std_logic_vector(15 downto 0);
  
  signal pclk : std_logic;	---- ++++ add
  signal cnt : std_logic_vector(8 downto 0);	---- ++++ add
  
  signal  all_done      : std_logic;  -- add ADC
  signal  temp_ram_count: std_logic_vector(1 downto 0); --count ram number
  
--  signal  temp_all_done
  
--  signal  re_data       : std_logic_vector(15 downto 0);
  
--  signal  count_calc    : std_logic_vector(3 downto 0);
  
begin
  
  process(rstn, sys_clk)    ---- ++++ add process
    begin
      if(rstn = '0') then
        pclk  <=  '0';
        cnt   <=  (others => '0');
      elsif rising_edge(sys_clk) then
        if(cnt = 1) then    -- 115200 bps -> in 200MHz
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
        
        all_done <= '0';
        
      elsif rising_edge(sys_clk) then
        busy_d <= busy;
        
        
        
        --adc
        all_done <= all_done_1 and all_done_2 and all_done_3 and all_done_4;
        
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
        
        --re_temp_data <= (others => '0');
        
        --add ADC
--        re_addr_1  <= (others => '0');
--        re_addr_2  <= (others => '0');
--        re_addr_3  <= (others => '0');
--        re_addr_4  <= (others => '0');
--        ram_count <= "00";
        temp_ram_count <= "00";
        
--        re_data <= (others => '0');
        
--        count_calc <= (others => '0');
          
      elsif rising_edge(pclk) then
        case state is
          when IDLE =>
            if(all_done = '1') or (temp_ram_count >= 1) then
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
            
            --add ADC
--            re_addr_1  <= (others => '0');
--            re_addr_2  <= (others => '0');
--            re_addr_3  <= (others => '0');
--            re_addr_4  <= (others => '0');
--            ram_count <= (others => '0');
--            temp_ram_count <= (others => '0');
            
--            re_data <= (others => '0');
            
--            count_calc <= (others => '0');
            
            ram_count <= temp_ram_count;
            
            re_addr <= (others => '0');
            
          when TEMP =>
            
            re_addr <= re_cnt;
            state <= TEMP_2;
            
          when TEMP_2 =>
           
            state <=  TEMP_3;
            
          when TEMP_3 =>
             total_data <= total_data + re_data;
             state <= ADDR_INC;
              
          when ADDR_INC =>
              if(re_cnt < 8) then         -- 8EA, 32set
--              if(re_cnt < 60) then        -- 1024EA, 32set
--                if(row_addr = 0) then
--                  state <= ADDR_INC;
--                  re_cnt <= re_cnt + 8;
--                else
                  if(count = 0) then
                    re_cnt <= re_cnt + 8;
                    state <= READ_DATA;
--                    state <= RAM_SEL;
                  else
                    if(count = 32) then
 --                     state <= RAM_SEL;
                      state <= READ_DATA;
                    else
                      re_cnt <= re_cnt + 8;
--                      state <= RAM_SEL;
                      state  <= READ_DATA;
                    end if;
                  end if;
--                end if;
              else
--                if(row_addr = 0) then
--                  if(re_cnt = 248) then
--                    re_cnt <= re_cnt - 8;
--                    state <= READ_DATA;
                    
 --                 end if;
                  re_cnt <= re_cnt + 8;
                  state  <= READ_DATA;
--                state <= RAM_SEL;
--                end if;
              end if;
              
--              re_addr <= re_cnt(8 downto 0);
              re_addr <= re_cnt;
              
--              ram_count <= temp_ram_count;
              
--          when RAM_SEL =>
--            if(temp_ram_count = 0) then
--              re_addr_1 <= re_cnt(10 downto 0);
--            elsif(temp_ram_count = "01") then
--              re_addr_2 <= re_cnt(10 downto 0);
--            elsif(temp_ram_count = "10") then
--              re_addr_3 <= re_cnt(10 downto 0);
--            elsif(temp_ram_count = "11") then
--              re_addr_4 <= re_cnt(10 downto 0);
 --           else
--              re_addr_1 <= (others => '0');
--              re_addr_2 <= (others => '0');
--              re_addr_3 <= (others => '0');
--              re_addr_4 <= (others => '0');
--            end if;
            
--            state <= READ_DATA;
            
          when READ_DATA =>
            if(re_cnt = 0) and (row_addr = 0) then
              state <= DATA_COUNT;
            else
              state <= SUM;
            end if;
            count <= count + 1;
            
--            re_data <= re_data_1 or  re_data_2 or re_data_3 or re_data_4;
            
          when SUM =>
            if(count = 31) then
--            if(count = 32) then
              if(row_addr = 0) then
--                total_data <= re_data + total_data + re_data;---------------------------
                total_data <= re_data + total_data;
                state <= AVERAGE;
              else
             	  total_data <= re_data + total_data;
                state  <= ADDR_INC;
              end if;
              
            elsif(count = 32) then
--            if(count = 32) then
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
            if(re_cnt = 263) then -- last addr + EA
              state <= IDLE;
              
              temp_ram_count <= temp_ram_count + 1;
              
              --count_calc
              
--            elsif(busy = '0') or (row_addr = 7) then-------------------------------------
            elsif(busy = '0') then
              state <= ADDR_INC;
              
--              re_cnt <= "00000000000" & row_addr;
              re_cnt <= '0' & row_addr;
              total_data <= (others => '0');
              --re_temp_data <= (others => '0');
              
              --add ADC
              --temp_ram_count <= temp_ram_count + '1';
              
            else
              state <= DATA_COUNT;
            end if;
            
          when others => state <= IDLE;
        end case;
      end if;
  end process;
  
  re_en <= '0' when (state = IDLE) else '1';
  start_sig <= '1' when (state = LSB_DATA) or (state = MSB_DATA) else '0';
  
  --add ADC
--  ram_count <= "00" when (state = IDLE) or (state = DATA_COUNT) else temp_ram_count;
      
end u_uart_control;
            
            
