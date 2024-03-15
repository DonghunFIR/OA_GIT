----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/17 12:51:53
-- Design Name: 
-- Module Name: USB_interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity USB_interface is
port(
	--===== INPUT =====--
    -- CLOCK --
    m_3014_PCLK           : in std_logic;
    m_FPGA_CLK_40M        : in std_logic;
    -- Enable CONTROL --
    m_3014_RAM_REN        : in std_logic;
    m_3014_WEN            : in std_logic;
    m_3014_REN            : in std_logic;
    -- Data by IP --
    m_IP_TxBF             : in std_logic_vector(15 downto 0);
    m_IP_RTC              : in std_logic_vector(15 downto 0);
    m_IP_AFE              : in std_logic_vector(15 downto 0);
    
    m_RTC                 : in std_logic;
    m_TxPG_T              : in std_logic;
    m_TxPG_D              : in std_logic;
    m_RxBF                : in std_logic;
    m_USB                 : in std_logic;  
    --===== OUTPUT =====--
    -- CYUSB3014 --
    m_3014_VALID          : out std_logic;
    m_3014_POLLING_FLAG   : out std_logic;

    m_3014_REG_READ_EN    : out std_logic;
    m_3014_REG_WRITE_EN   : out std_logic;

	-- BUS --
    m_Address_Bus         : out std_logic_vector(15 downto 0);
    m_Data_Bus            : out std_logic_vector(15 downto 0);
     
    
    --===== INOUT =====--
    m_3014_DQ             : inout std_logic_vector(31 downto 0)

);
end USB_interface;

architecture Behavioral of USB_interface is

type   REG_SINGLE_WR is ( idle , WRITE_STATE, IP_DATA_DRIVE ,READ_TO_SIGNAL, READ_40M_DATA, READ_100M_DOUT);
signal state           : REG_SINGLE_WR := idle;

--100M/40M DATA SIGNAL--
signal s_3014_DQ_40M    : std_logic_vector(31 downto 0) ;
signal s_3014_DQ_in     : std_logic_vector(31 downto 0) ;


--single write--
signal s_reg_write_en   : std_logic;
signal s_3014_WEN_40M   : std_logic;
signal s_3014_WEN_40M_2 : std_logic;
signal s_3014_WEN_trig  : std_logic := '0';
signal s_3014_WEN_DELAY : std_logic;

--single read--
signal s_reg_read_en    : std_logic;
signal s_3014_REN_40M   : std_logic;
signal s_3014_REN_40M_2 : std_logic;
signal s_3014_REN_40M_3 : std_logic;
signal s_3014_REN_trig  : std_logic := '0';
signal s_3014_valid     : std_logic ;


-- data out timing control -- 
signal s_single_WR_dout_en : std_logic;
signal s_single_WR_valid   : std_logic;
signal s_3014_DQ_OUT_40M   : std_logic_vector(31 downto 0);
signal s_3014_DQ_OUT_100M  : std_logic_vector(31 downto 0);

signal s_single_WR_dout_en_1 : std_logic;
signal s_single_WR_dout_en_2 : std_logic;

signal s_RTC               : std_logic;
signal s_TxPG_T            : std_logic;
signal s_TxPG_D            : std_logic;
signal s_RxBF              : std_logic;
signal s_USB               : std_logic;

signal s_ipdata_get        : std_logic;


--
---
begin
---
--

--===== LATCH AND MAKE TRIG =====--
LATCH_WEN_MAKE_TRIG : process(m_FPGA_CLK_40M)
begin
if rising_edge(m_FPGA_CLK_40M) then

   s_3014_WEN_40M    <= m_3014_WEN;
   s_3014_WEN_40M_2  <= s_3014_WEN_40M;
   s_3014_WEN_trig   <= s_3014_WEN_40M and (not(s_3014_WEN_40M_2));

   s_3014_REN_40M    <= m_3014_REN;
   s_3014_REN_40M_2  <= s_3014_REN_40M;
   s_3014_REN_40M_3  <= s_3014_REN_40M_2;

   s_3014_REN_trig   <= s_3014_REN_40M and (not(s_3014_REN_40M_2));  

   s_3014_DQ_40M      <= m_3014_DQ;

   s_3014_WEN_DELAY  <= s_3014_WEN_40M;

end if;
end process;

LATCH_DATA_TO_SIGNAL : process(m_FPGA_CLK_40M)
begin
if rising_edge(m_FPGA_CLK_40M) then
   if s_3014_WEN_trig = '1' or s_3014_REN_trig = '1' then
      s_3014_DQ_in   <= s_3014_DQ_40M;
   end if;
end if;
end process;

--===== SINGLE READ =====--
process(m_FPGA_CLK_40M)
begin
if rising_edge(m_FPGA_CLK_40M) then
   case state is 
      when idle => 
      		if s_3014_WEN_trig = '1' then
            	state <= WRITE_STATE;
            elsif s_3014_REN_trig = '1' then
               state <= IP_DATA_DRIVE;
            else 
            	state <= idle;
            end if;

      when WRITE_STATE => 
            state <= idle;
                
      when IP_DATA_DRIVE =>
         state <= READ_TO_SIGNAL;               
      
      when READ_TO_SIGNAL =>  -- READ DATA FROM IP TO SAVE SIGNAL
         if s_3014_REN_40M = '0' and s_3014_REN_40M_2 = '0' and s_3014_REN_40M_3 = '0' then
            state <= READ_40M_DATA;
         else
            state <= READ_TO_SIGNAL;
         end if;

      when READ_40M_DATA =>   -- WAIT 40M DATA TO OUT
         state <= READ_100M_DOUT;

      when READ_100M_DOUT =>  -- 40M -> 100M DOUT
         state <= idle;

      when others =>
         state <= idle;
      end case;         
end if;
end process;

process(m_3014_PCLK)
begin
   if rising_edge(m_3014_PCLK) then

      s_3014_DQ_OUT_100M   <= s_3014_DQ_OUT_40M;
      s_single_WR_dout_en_1<= s_single_WR_dout_en;
      s_single_WR_dout_en_2<= s_single_WR_dout_en_1;
      s_3014_valid         <= s_single_WR_valid;

   end if;
end process;

--===== DATA/ADDR BUS =====--

m_Address_Bus     <= s_3014_DQ_in(31 downto 16);
m_Data_Bus        <= s_3014_DQ_in(15 downto 0) ;

--IP TO PC--
s_3014_DQ_OUT_40M    <= x"0000" & m_IP_TxBF  when s_ipdata_get = '1' and (m_TxPG_D ='1' or m_TxPG_T='1')  else
                        x"0000" & m_IP_RTC   when s_ipdata_get = '1' and m_RTC  ='1' else
                        x"0000" & m_IP_AFE   when s_ipdata_get = '1' and m_RxBF ='1' else
                        (others => 'Z');

m_3014_DQ            <= s_3014_DQ_OUT_100M               when s_single_WR_dout_en ='1' or s_single_WR_dout_en_1 = '1' or s_single_WR_dout_en_2 = '1'else (others => 'Z');

--===== Write/Read State machine =====--

s_reg_write_en       <= '1' when state = WRITE_STATE else '0';

s_reg_read_en        <= '1' when state = IP_DATA_DRIVE or state = READ_TO_SIGNAL or state = READ_40M_DATA or state = READ_100M_DOUT else '0'; 
s_ipdata_get         <= '1' when state = READ_TO_SIGNAL or state = READ_40M_DATA or state = READ_100M_DOUT else '0'; 
s_single_WR_dout_en  <= '1' when state = READ_40M_DATA or state = READ_100M_DOUT else '0';
s_single_WR_valid    <= '1' when state = READ_100M_DOUT else '0';

--===== Write/Read Enable SIGNAL =====--
m_3014_VALID         <= s_single_WR_valid;
m_3014_REG_READ_EN   <= s_reg_read_en;
m_3014_REG_WRITE_EN  <= s_reg_write_en;


end Behavioral;