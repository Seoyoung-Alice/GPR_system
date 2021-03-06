----------------------------------------------------
-- Graduation Project Version Final
-- 2016.11.30
-- Author : Yoon Seo young
-- Creator : Yoon Seo young, Lim young in, Song min ji
-- 
-- code info.
-- 200Msps RTS and 4 ADC
-- smapling clk : 200MHz
-- number of data : 8EA
-- sum 32 times and divide to 32 (median filter)
------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mj_total is
  port (
	rstn    : in std_logic;
	trig_in    : in std_logic;
	inclk0 : in std_logic;

	--busy	: in std_logic;

	--data_10bit	: out std_logic_vector(9 downto 0)
	orig_sig    :   out std_logic;
	tx_data     :   out std_logic
  );
end mj_total;

architecture u_total of mj_total is

   component altpll2 is
    port (
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
    ); end component;
    
    component trig_cont is
    port (
   rstn    : in std_logic;
   trig_in : in std_logic;
   sys_clk : in std_logic;

   trig : out std_logic
    ); end component;
  
  component ram_clk_gen_32 is
    port (
	rstn    : in std_logic;
   	trig    : in std_logic;
   	sys_clk : in std_logic;
   	ram_end	: in std_logic;
   	done    : in std_logic;

   	ram_clk : out std_logic
    ); end component;

  component clk_gen_32 is
    port (
		trig : in std_logic;
		rstn : in std_logic;
		sys_clk : in std_logic;
		--done    : in std_logic;
		ram_end : in std_logic;

		sam_clk : out std_logic
    ); end component;

  component sig_gen is
    port (
		rstn     : in std_logic;
		trig     : in std_logic;
		sys_clk  : in std_logic;
		ram_end  : in std_logic;
		done    : in std_logic;

		orig_sig : out std_logic
    ); end component;

--  component ADC_Model is
--    port (
--	rstn     : in std_logic;
--	trig     : in std_logic;
--  	sam_clk  : in std_logic;
--  	done    : in std_logic;
--  	ram_end  : in std_logic;

--  	sam_sig  : out std_logic_vector(9 downto 0)
--    ); end component;
    
    component ADC_Model_1 is
      port(
        rstn     : in std_logic;
        trig     : in std_logic;
  
        ram_end  : in std_logic;
        done     : in std_logic;
        sam_clk  : in std_logic;
        sam_sig  : out std_logic_vector(9 downto 0)
      ); end component;
      
      component ADC_Model_2 is
      port(
        rstn     : in std_logic;
        trig     : in std_logic;
  
        ram_end  : in std_logic;
        done     : in std_logic;
        sam_clk  : in std_logic;
        sam_sig  : out std_logic_vector(9 downto 0)
      ); end component;
      
      component ADC_Model_3 is
      port(
        rstn     : in std_logic;
        trig     : in std_logic;
  
        ram_end  : in std_logic;
        done     : in std_logic;
        sam_clk  : in std_logic;
        sam_sig  : out std_logic_vector(9 downto 0)
      ); end component;
      
      component ADC_Model_4 is
      port(
        rstn     : in std_logic;
        trig     : in std_logic;
  
        ram_end  : in std_logic;
        done     : in std_logic;
        sam_clk  : in std_logic;
        sam_sig  : out std_logic_vector(9 downto 0)
      ); end component;

  component Write_RAM is
    port (
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
	all_done : out std_logic;
	done	: out std_logic
    ); end component;

  component altdpram4 is
    port (
    rstn : in std_logic;
	  data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC;
		wraddress		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		wrclock		: IN STD_LOGIC ;
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    ); end component;


  component make_end is
    port(
    rstn	: in std_logic;
    sys_clk : in std_logic;
    done : in std_logic;

    ram_end	: out std_logic
    ); end component;


  component uart_tx is
    port (
	rstn        :   in  std_logic;
      	sys_clk     :   in  std_logic;
      	data_tx_in  :   in  std_logic_vector(7 downto 0);  ----------------
      	start_sig   :   in  std_logic;
      
      	busy        :   out std_logic;
      	tx_data     :   out std_logic
    ); end component;
    
    component uart_control_adc is
      port (
        rstn          : in  std_logic;
        sys_clk       : in  std_logic;
    
        all_done_1    : in  std_logic;
        all_done_2    : in  std_logic;
        all_done_3    : in  std_logic;
        all_done_4    : in  std_logic;
    
        ram_count     : out std_logic_vector(1 downto 0);
        
--        re_data_1     : in  std_logic_vector(15 downto 0);
--        re_data_2     : in  std_logic_vector(15 downto 0);
--        re_data_3     : in  std_logic_vector(15 downto 0);
--        re_data_4     : in  std_logic_vector(15 downto 0);
    
        re_data       : in  std_logic_vector(15 downto 0);
        busy          : in  std_logic;
    
        re_en         : out std_logic;
        re_addr       : out std_logic_vector(14 downto 0);
        data_uart     : out std_logic_vector(7 downto 0);
        clk_out       : out std_logic;
        start_sig     : out std_logic
      ); end component;
      
      component Demux_1x4 is
        port(
          A   : in std_logic;
      
          SEL : in std_logic_vector(1 downto 0);
		
		      Y1  : out std_logic;
          Y2  : out std_logic;
          Y3  : out std_logic;
          Y4  : out std_logic
      ); end component;
      
      component mux_4x1 is
        port(
          A : in std_logic_vector (15 downto 0);
          B : in std_logic_vector (15 downto 0);
          C : in std_logic_vector (15 downto 0);
          D : in std_logic_vector (15 downto 0);
         
          SEL : in std_logic_vector (1 downto 0);
          
          Y : out std_logic_vector (15 downto 0)
      ); end component;

	signal sys_clk : std_logic ;
	
	signal c0      : std_logic ;
	signal locked  : std_logic ;

-- ram_clk_gen --
	--signal rstn    : std_logic;
   	signal trig    : std_logic;
   	--signal sys_clk : std_logic;
   	--signal ram_end : std_logic;

   	signal ram_clk : std_logic;

-- clk_gen --
	--signal trig : std_logic;
      	--signal rstn : std_logic;
     	--signal sys_clk : std_logic;

      	signal sam_clk : std_logic;

-- sig_gen --
	--signal rstn     : std_logic;
      	--signal trig     : std_logic;
      	--signal sys_clk  : std_logic;

  --    	signal orig_sig : std_logic;

-- ADC_Model --
	--signal rstn     : std_logic;
  	--signal orig_sig : std_logic_vector(9 downto 0);
  	--signal sam_clk  : std_logic;

--  	signal sam_sig  : std_logic_vector(9 downto 0);

-- Write_RAM --
	--signal rstn	: std_logic;
	--signal sam_clk	: std_logic;
	--signal sam_sig	: std_logic_vector(9 downto 0);

--	signal wr_en	: std_logic;
--	signal wr_addr	: std_logic_vector(14 downto 0);
--	signal wr_data	: std_logic_vector(15 downto 0);
	signal done	: std_logic;
--	signal all_done : std_logic;

-- RAM --
	--signal rstn	: std_logic;
	--signal wr_en	: std_logic;
	--signal wr_addr	: std_logic_vector(3 downto 0);
	--signal wr_data	: std_logic_vector(9 downto 0);
	signal wr_clk	: std_logic;		-- = ram_clk

	signal re_en	: std_logic;
	signal re_addr	: std_logic_vector(14 downto 0);
	signal re_clk	: std_logic;

	signal re_data	: std_logic_vector(15 downto 0);


-- altdpram --
    --signal data     		 : STD_LOGIC_VECTOR (15 DOWNTO 0);
		--signal rdaddress		 : STD_LOGIC_VECTOR (8 DOWNTO 0);
		--signal rdclock		   : STD_LOGIC ;
		--signal rden		      : STD_LOGIC;
		--signal wraddress		 : STD_LOGIC_VECTOR (8 DOWNTO 0);
		--signal wrclock		   : STD_LOGIC ;
		--signal wren		      : STD_LOGIC;
		--signal q		: STD_LOGIC_VECTOR (15 DOWNTO 0);


-- uart_tx --
	--signal rstn        :   std_logic;
      	--signal sys_clk     :   std_logic;
      	signal data_tx_in  :   std_logic_vector(7 downto 0);
      	signal start_sig   :   std_logic;
      
      	signal busy        :   std_logic;
      	--signal tx_data     :   std_logic;
      	
-- uart_control --
    --rstn    :  std_logic;
    --sys_clk :  std_logic;
    --re_en   :  std_logic;
    --signal  start_sig_ram   :  std_logic;
    --data_10bit  :  std_logic_vector(9 downto 0);
    --busy    :  std_logic;
        
    --re_addr   : std_logic_vector(3 downto 0);
    --signal  data_uart      : std_logic_vector(7 downto 0);
    signal  clk_out   : std_logic;
    --start_sig : std_logic
    
    signal ram_end	: std_logic;
    
    -- uart_control_adc
    signal  ram_count   : std_logic_vector(1 downto 0);
    signal  all_done_1  : std_logic;
    signal  all_done_2  : std_logic;
    signal  all_done_3  : std_logic;
    signal  all_done_4  : std_logic;
    
    signal  re_en_1     : std_logic;
    signal  re_en_2     : std_logic;
    signal  re_en_3     : std_logic;
    signal  re_en_4     : std_logic;
    
    -- ADC Model
    signal  sam_sig_1   : std_logic_vector(9 downto 0);
    signal  sam_sig_2   : std_logic_vector(9 downto 0);
    signal  sam_sig_3   : std_logic_vector(9 downto 0);
    signal  sam_sig_4   : std_logic_vector(9 downto 0);
    
    -- write RAM
    signal  done_1      : std_logic;
    signal  done_2      : std_logic;
    signal  done_3      : std_logic;
    signal  done_4      : std_logic;
    
    signal  wr_en_1     : std_logic;
	  signal  wr_addr_1   : std_logic_vector(14 downto 0);
    signal  wr_data_1   : std_logic_vector(15 downto 0);
    
    signal  wr_en_2     : std_logic;
	  signal  wr_addr_2   : std_logic_vector(14 downto 0);
    signal  wr_data_2   : std_logic_vector(15 downto 0);
    
    signal  wr_en_3     : std_logic;
	  signal  wr_addr_3   : std_logic_vector(14 downto 0);
    signal  wr_data_3   : std_logic_vector(15 downto 0);
    
    signal  wr_en_4     : std_logic;
	  signal  wr_addr_4   : std_logic_vector(14 downto 0);
    signal  wr_data_4   : std_logic_vector(15 downto 0);
    
    signal  ram_end_1   : std_logic;
    signal  ram_end_2   : std_logic;
    signal  ram_end_3   : std_logic;
    signal  ram_end_4   : std_logic;
    
    signal  re_data_1   : std_logic_vector(15 downto 0);
    signal  re_data_2   : std_logic_vector(15 downto 0);
    signal  re_data_3   : std_logic_vector(15 downto 0);
    signal  re_data_4   : std_logic_vector(15 downto 0);


begin
  sys_clk <= c0 and locked ;
  wr_clk <= ram_clk;
  re_clk <= clk_out;
  
  done <= done_1 and done_2 and done_3 and done_4;
  ram_end <= ram_end_1 and ram_end_2 and ram_end_3 and ram_end_4;
  
--  process(rstn, inclk0)
--    begin
--      if(rstn = '0') then
--        done <= '0';
--        ram_end <= '0';
--      elsif rising_edge(inclk0) then
--        done <= done_1 and done_2 and done_3 and done_4;
--        ram_end <= ram_end_1 and ram_end_2 and ram_end_3 and ram_end_4;
--      end if;
--    end process;
  

  u51 : altpll2
  port map (
   	inclk0 => inclk0,
	c0 => c0,
	locked => locked	 
  );
  
  u50 : trig_cont
  port map (
    rstn => rstn,
    trig_in => trig_in,
    sys_clk => sys_clk,
    
    trig => trig
  );

  u0 : ram_clk_gen_32
  port map (
	rstn	=> rstn,
	trig	=> trig,
	done => done,
	sys_clk	=> sys_clk,
	ram_end	=> ram_end,

	ram_clk	=> ram_clk );

  u1 : clk_gen_32
  port map (
	trig	=> trig,
	rstn	=> rstn,
	--done => done,
	sys_clk	=> sys_clk,
	ram_end => ram_end,
	
	sam_clk	=> sam_clk );

  u2 : sig_gen
  port map (
	rstn	=> rstn,
	trig	=> trig,
	done => done,
	sys_clk	=> sys_clk,
	ram_end => ram_end,
	
	orig_sig => orig_sig );

--  u3 : ADC_Model
--  port map (
--	rstn	=> rstn,
	--orig_sig => orig_sig,
--	done => done,
--	ram_end => ram_end,
--	sam_clk	=> sam_clk,
--	trig => trig,

--	sam_sig	=> sam_sig );
	
	u11 : ADC_Model_1
	port map(
	  rstn     => rstn,
    trig     => trig,
  
    ram_end  => ram_end_1,
    done     => done_1,
    sam_clk  => sam_clk,
    sam_sig  => sam_sig_1
	);
	
	u12 : ADC_Model_2
	port map(
	  rstn     => rstn,
    trig     => trig,
  
    ram_end  => ram_end_2,
    done     => done_2,
    sam_clk  => sam_clk,
    sam_sig  => sam_sig_2
	);
	
	u13 : ADC_Model_3
	port map(
	  rstn     => rstn,
    trig     => trig,
  
    ram_end  => ram_end_3,
    done     => done_3,
    sam_clk  => sam_clk,
    sam_sig  => sam_sig_3
	);
	
	u14 : ADC_Model_4
	port map(
	  rstn     => rstn,
    trig     => trig,
  
    ram_end  => ram_end_4,
    done     => done_4,
    sam_clk  => sam_clk,
    sam_sig  => sam_sig_4
	);

  u21 : Write_RAM
  port map (
	rstn	     => rstn,
	trig   	  => trig,
	wr_clk	   => wr_clk,
	sam_sig	  => sam_sig_1,
	ram_end   => ram_end_1,
	
	sys_clk => sys_clk,
	clk_out => clk_out,

	wr_en	   => wr_en_1,
	wr_addr	 => wr_addr_1,
	wr_data	 => wr_data_1,
	all_done => all_done_1,
	done	    => done_1 );
	
	u22 : Write_RAM
  port map (
	rstn	     => rstn,
	trig   	  => trig,
	wr_clk	   => wr_clk,
	sam_sig	  => sam_sig_2,
	ram_end   => ram_end_2,
	
	sys_clk => sys_clk,
	clk_out => clk_out,

	wr_en	   => wr_en_2,
	wr_addr	 => wr_addr_2,
	wr_data	 => wr_data_2,
	all_done => all_done_2,
	done	    => done_2 );
	
	u23 : Write_RAM
  port map (
	rstn	     => rstn,
	trig   	  => trig,
	wr_clk	   => wr_clk,
	sam_sig	  => sam_sig_3,
	ram_end   => ram_end,
	
	sys_clk => sys_clk,
	clk_out => clk_out,

	wr_en	   => wr_en_3,
	wr_addr	 => wr_addr_3,
	wr_data	 => wr_data_3,
	all_done => all_done_3,
	done	    => done_3 );
	
	u24 : Write_RAM
  port map (
	rstn	     => rstn,
	trig   	  => trig,
	wr_clk	   => wr_clk,
	sam_sig	  => sam_sig_4,
	ram_end   => ram_end,
	
	sys_clk => sys_clk,
	clk_out => clk_out,

	wr_en	   => wr_en_4,
	wr_addr	 => wr_addr_4,
	wr_data	 => wr_data_4,
	all_done => all_done_4,
	done	    => done_4 );

  u31 : altdpram4
  port map (
    rstn => rstn,
		data		      => wr_data_1,
		rdaddress	  => re_addr,
		rdclock		   => re_clk,
		rden		      => re_en_1,
		wraddress	  => wr_addr_1,
		wrclock		   => wr_clk,
		wren		      => wr_en_1,
		
		q           => re_data_1
  );
  
  u32 : altdpram4
  port map (
    rstn => rstn,
		data		      => wr_data_2,
		rdaddress	  => re_addr,
		rdclock		   => re_clk,
		rden		      => re_en_2,
		wraddress	  => wr_addr_2,
		wrclock		   => wr_clk,
		wren		      => wr_en_2,
		
		q           => re_data_2
  );
  
  u33 : altdpram4
  port map (
    rstn => rstn,
		data		      => wr_data_3,
		rdaddress	  => re_addr,
		rdclock		   => re_clk,
		rden		      => re_en_3,
		wraddress	  => wr_addr_3,
		wrclock		   => wr_clk,
		wren		      => wr_en_3,
		
		q           => re_data_3
  );
  
  u34 : altdpram4
  port map (
    rstn => rstn,
		data		      => wr_data_4,
		rdaddress	  => re_addr,
		rdclock		   => re_clk,
		rden		      => re_en_4,
		wraddress	  => wr_addr_4,
		wrclock		   => wr_clk,
		wren		      => wr_en_4,
		
		q           => re_data_4
  );
  
--  u6 : make_end
--  port map(
--  rstn	   => rstn,
--  sys_clk => sys_clk,
--  done    => done,

--  ram_end => ram_end
--  );

  u41 : make_end
  port map(
  rstn	   => rstn,
  sys_clk => sys_clk,
  done    => done,

  ram_end => ram_end_1
  );
  
  u42 : make_end
  port map(
  rstn	   => rstn,
  sys_clk => sys_clk,
  done    => done,

  ram_end => ram_end_2
  );
  
  u43 : make_end
  port map(
  rstn	   => rstn,
  sys_clk => sys_clk,
  done    => done,

  ram_end => ram_end_3
  );
  
  
u44 : make_end
  port map(
  rstn	   => rstn,
  sys_clk => sys_clk,
  done    => done,

  ram_end => ram_end_4
  );

  
  u7 : uart_control_adc
  port map(
      rstn            =>  rstn,
      sys_clk         =>  sys_clk,
    
      --
      all_done_1      =>  all_done_1,
      all_done_2      =>  all_done_2,
      all_done_3      =>  all_done_3,
      all_done_4      =>  all_done_4,
      
      -- mux
      ram_count       =>  ram_count,
      
--      re_data_1       =>  re_data_1,
--      re_data_2       =>  re_data_2,
--      re_data_3       =>  re_data_3,
--      re_data_4       =>  re_data_4,
    
      re_data         =>  re_data,
      busy            =>  busy,
    
      re_en           =>  re_en,
      re_addr         =>  re_addr,
      data_uart       =>  data_tx_in,
      clk_out         =>  clk_out,
      start_sig       =>  start_sig
  );

  u8 : uart_tx
  port map (
	   rstn	=> rstn,
	   sys_clk	=> sys_clk,
	   data_tx_in	=> data_tx_in,
	   start_sig	=> start_sig,

	   busy	=> busy,
	   tx_data	=> tx_data );
	
	u9 : Demux_1x4
	port map(
	  
	   A     =>  re_en,
	  
	  -- when SEL "00"
	   Y1     => re_en_1,
	   -- when SEL "01"
	   Y2     => re_en_2,
	   -- when SEL "10"
	   Y3     => re_en_3,
	   -- when SEL "11"
	   Y4     => re_en_4,
	   
	   SEL   =>  ram_count
	);
	
	u10 : mux_4x1
	port map(
	   -- when SEL "00"
	   A     =>  re_data_1,
	   -- when SEL "01"
	   B     =>  re_data_2,
	   -- when SEL "10"
	   C     =>  re_data_3,
	   -- when SEL "11"
	   D     =>  re_data_4,
	   
	   SEL   =>  ram_count,
	   
     Y     =>  re_data
	   
	);

end u_total;

