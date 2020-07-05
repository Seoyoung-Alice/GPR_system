library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mj_total is
  port (
	rstn    : in std_logic;
	trig_in    : in std_logic;
	inclk0 : in std_logic;
	
	--re_clk : in std_logic;
	--re_addr : in std_logic_vector (10 downto 0);
	--re_en : in std_logic;
	--ram_end : in std_logic;

	--busy	: in std_logic;

	--data_10bit	: out std_logic_vector(9 downto 0)
	orig_sig    :   out std_logic;
	re_data     :   out std_logic_vector(15 downto 0)
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
    ram_end : in std_logic;
    done    : in std_logic;
    ram_clk : out std_logic
    ); end component;

  component clk_gen_32 is
    port (
      trig : in std_logic;
      rstn : in std_logic;
      sys_clk : in std_logic;
      ram_end : in std_logic;
      sam_clk : out std_logic
    ); end component;

  component sig_gen is
    port (
		rstn     : in std_logic;
		trig     : in std_logic;
		sys_clk  : in std_logic;
		ram_end  : in std_logic;

		orig_sig : out std_logic
    ); end component;

  component ADC_Model is
    port (
	rstn     : in std_logic;
	trig     : in std_logic;
  	sam_clk  : in std_logic;
  	ram_end  : in std_logic;
  done     : in std_logic;
  	sam_sig  : out std_logic_vector(9 downto 0)
    ); end component;

  component Write_RAM is
    port (
	rstn	: in std_logic;
	trig	: in std_logic;
	wr_clk	: in std_logic;
	sam_sig : in std_logic_vector(9 downto 0);
	
	ram_end : in std_logic;

	wr_en	: out std_logic;
	wr_addr	: out std_logic_vector(10 downto 0);
	wr_data	: out std_logic_vector(15 downto 0);
	
	all_done : out std_logic;
	
	done	: out std_logic
    ); end component;

  component altdpram3 is
    port (
    rstn : in std_logic;
	  data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC;
		wraddress		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		wrclock		: IN STD_LOGIC ;
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    ); end component;
    
    
      component read_control is
    port (
  rstn     : in std_logic;
  all_done     : in std_logic;
  sys_clk  : in std_logic;
  --ram_end  : out std_logic;
 
  re_addr  : out std_logic_vector(10 downto 0);
  re_en    : out std_logic
    ); end component;
    
  component make_end is
  port(
  rstn	: in std_logic;
  sys_clk : in std_logic;
  done : in std_logic;

  ram_end	: out std_logic
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

  	signal sam_sig  : std_logic_vector(9 downto 0);

-- Write_RAM --
	--signal rstn	: std_logic;
	--signal sam_clk	: std_logic;
	--signal sam_sig	: std_logic_vector(9 downto 0);

	signal wr_en	: std_logic;
	signal wr_addr	: std_logic_vector(10 downto 0);
	signal wr_data	: std_logic_vector(15 downto 0);
	signal done	: std_logic;
	
	signal all_done : std_logic;

-- RAM --
	--signal rstn	: std_logic;
	--signal wr_en	: std_logic;
	--signal wr_addr	: std_logic_vector(3 downto 0);
	--signal wr_data	: std_logic_vector(9 downto 0);
	signal wr_clk	: std_logic;		-- = ram_clk
  signal ram_end : std_logic;
	signal re_en	: std_logic;
	signal re_addr	: std_logic_vector(10 downto 0);
	--signal re_clk	: std_logic;

	--signal re_data	: std_logic_vector(15 downto 0);


-- altdpram --
    --signal data     		 : STD_LOGIC_VECTOR (15 DOWNTO 0);
		--signal rdaddress		 : STD_LOGIC_VECTOR (8 DOWNTO 0);
		--signal rdclock		   : STD_LOGIC ;
		--signal rden		      : STD_LOGIC;
		--signal wraddress		 : STD_LOGIC_VECTOR (8 DOWNTO 0);
		--signal wrclock		   : STD_LOGIC ;
		--signal wren		      : STD_LOGIC;
		--signal q		: STD_LOGIC_VECTOR (15 DOWNTO 0);


begin
  sys_clk <= c0 and locked ;
  wr_clk <= ram_clk;
  --re_clk <= sys_clk;

  u11 : altpll2
  port map (
   	inclk0 => inclk0,
	c0 => c0,
	locked => locked	 
  );
  
  u10 : trig_cont
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
	sys_clk	=> sys_clk,
	ram_end	=> ram_end,
	done => done,

	ram_clk	=> ram_clk );

  u1 : clk_gen_32
  port map (
	trig	=> trig,
	rstn	=> rstn,
	sys_clk	=> sys_clk,
	ram_end => ram_end,
	
	sam_clk	=> sam_clk );

  u2 : sig_gen
  port map (
	rstn	=> rstn,
	trig	=> trig,
	sys_clk	=> sys_clk,
	ram_end => ram_end,
	
	orig_sig => orig_sig );

  u3 : ADC_Model
  port map (
	rstn	=> rstn,
	ram_end => ram_end,
	sam_clk	=> sam_clk,
	done => done,
	trig => trig,

	sam_sig	=> sam_sig );

  u4 : Write_RAM
  port map (
	rstn	=> rstn,
	trig	=> trig,
	wr_clk	=> wr_clk,
	sam_sig	=> sam_sig,
	
	ram_end => ram_end,

	wr_en	=> wr_en,
	wr_addr	=> wr_addr,
	wr_data	=> wr_data,
	
	all_done => all_done,
	
	done	=> done );

  u5 : altdpram3
  port map (
    rstn => rstn,
		data		      => wr_data,
		rdaddress	  => re_addr,
		rdclock		   => sys_clk,
		rden		      => re_en,
		wraddress	  => wr_addr,
		wrclock		   => wr_clk,
		wren		      => wr_en,
		
		q           => re_data
  );
  
 
   u6 : read_control
  port map (
    rstn => rstn,
		all_done		      => all_done,
		sys_clk	  => sys_clk,
		re_addr		   => re_addr,
		--ram_end   => ram_end,
		re_en		      => re_en
  );

  u7 : make_end
  port map(
  rstn	=> rstn,
  sys_clk => sys_clk,
  done => done,

  ram_end	=> ram_end
  );
 

end u_total;

