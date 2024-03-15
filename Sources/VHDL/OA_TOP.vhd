----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/02 16:27:30
-- Design Name: 
-- Module Name: OA_TOP - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.pkg_util.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OA_TOP is
	Port ( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_160M_p		: in std_logic;
	m_sys_clk_160M_n		: in std_logic;
	-- POWER --
	m_power_OFF				: in std_logic;
	-- CYUSB3014 --
	m_3014_PCLK				: in std_logic;
	m_3014_RAM_REN			: in std_logic;
	m_3014_WEN				: in std_logic;
	m_3014_REN 				: in std_logic;
	-- AFE --
	m_AFE_FCLKP				: in std_logic_vector(3 downto 0);
	m_AFE_FCLKM             : in std_logic_vector(3 downto 0);
	m_AFE_DCLKP             : in std_logic_vector(3 downto 0);
	m_AFE_DCLKM             : in std_logic_vector(3 downto 0);
	m_AFE_SDOUT	           	: in std_logic_vector(3 downto 0);
	m_ADC_OUT_P_1           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_N_1           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_P_2           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_N_2           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_P_3           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_N_3           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_P_4           : in std_logic_vector(15 downto 0);
	m_ADC_OUT_N_4           : in std_logic_vector(15 downto 0);
	-- BATTERY --
	m_Battery_LEVEL			: in std_logic;
	m_BATT_STAT1			: in std_logic;
	-- SWITCH --
	m_MODE_SWITCH			: in std_logic;
	m_SELECT_SWITCH         : in std_logic;
	
	--===== OUTPUT =====--
	-- CLOCK --
	m_FPGA_CLK_160M			: out std_logic;
	m_FPGA_CLK_40M_p		: out std_logic;
	m_FPGA_CLK_40M_n		: out std_logic;
	-- POWER --
	m_power_ON				: out std_logic;
	-- CYUSB3014 --
	m_3014_VALID			: out std_logic;
	m_3014_POLLING_FLAG		: out std_logic;	
	-- AFE --
	m_AFE_RESET	         	: out std_logic_vector(3 downto 0);
	m_AFE_TX_TRIG		    : out std_logic_vector(3 downto 0);
	m_AFE_PDN_FAST			: out std_logic_vector(3 downto 0);
	m_AFE_PDN_GBL	        : out std_logic_vector(3 downto 0);
	m_AFE_SDIN	          	: out std_logic_vector(3 downto 0);
	m_AFE_SEN	            : out std_logic_vector(3 downto 0);
	m_AFE_SCLK_10M         	: out std_logic_vector(3 downto 0);	
	-- HV CONTROL OUTPUT --
	m_3V3ND_Ctrl			: out std_logic;
	m_Pulser_3V3_Ctrl		: out std_logic;
	m_HV_40VP_EN			: out std_logic;
	m_HV_80VP_EN            : out std_logic;
	m_HV_40VN_EN            : out std_logic;
	m_HV_80VN_EN            : out std_logic;
	m_HV_80_VIN_CTRL		: out std_logic;
	m_HV_DROP_pos           : out std_logic;
	m_HV_DROP_neg           : out std_logic;
	-- Digital Potentiometer CONTROL --
	m_I2C_SCL               : out std_logic_vector(1 downto 0);
	m_I2C_SDA               : out std_logic_vector(1 downto 0);	
	-- Debug OUTPUT --	
	m_DEBUG_1V8_1			: out std_logic;
	m_DEBUG_1V8_2			: out std_logic;
	m_DEBUG_1V8_3			: out std_logic;	
	m_DEBUG_3V3_1			: out std_logic;
	m_DEBUG_3V3_2			: out std_logic;
	m_DEBUG_3V3_3			: out std_logic;
	m_DEBUG_LED				: out std_logic;
	-- Pulser --
	m_THSD					: out std_logic;
	m_CW					: out std_logic;
	m_IN1_P					: out std_logic_vector(7 downto 0);
	m_IN1_N					: out std_logic_vector(7 downto 0);
	m_IN2_P					: out std_logic_vector(7 downto 0);
	m_IN2_N					: out std_logic_vector(7 downto 0);
	m_IN3_P					: out std_logic_vector(7 downto 0);
	m_IN3_N					: out std_logic_vector(7 downto 0);
	m_IN4_P					: out std_logic_vector(7 downto 0);
	m_IN4_N					: out std_logic_vector(7 downto 0);
	m_IN5_P					: out std_logic_vector(7 downto 0);
	m_IN5_N					: out std_logic_vector(7 downto 0);
	m_IN6_P					: out std_logic_vector(7 downto 0);
	m_IN6_N					: out std_logic_vector(7 downto 0);
	m_IN7_P					: out std_logic_vector(7 downto 0);
	m_IN7_N					: out std_logic_vector(7 downto 0);
	m_IN8_P					: out std_logic_vector(7 downto 0);
	m_IN8_N					: out std_logic_vector(7 downto 0);
	
	--===== INOUT =====--
	m_3014_DQ				: inout std_logic_vector(31 downto 0)

	);
end OA_TOP;  

architecture Behavioral of OA_TOP is

-- CLOCK --
signal s_sys_clk_160M		: std_logic;
signal s_sys_clk_40M_p		: std_logic;
signal s_sys_clk_40M_n		: std_logic;
signal s_sys_clk_40M		: std_logic;
signal s_sys_clk_10M		: std_logic;
-- RESET --
signal s_SW_RESET          	: std_logic := '0';
-- Bus -- 
signal s_Address_Bus		: std_logic_vector(15 downto 0);
signal s_Data_Bus			: std_logic_vector(15 downto 0);
signal s_Data_Bus_WR		: std_logic_vector(15 downto 0);
signal s_Data_Bus_RD		: std_logic_vector(15 downto 0);
signal s_Address_Bus_temp   : std_logic_vector(15 downto 0);
signal s_Data_Bus_WR_temp   : std_logic_vector(15 downto 0);
signal s_Data_Bus_RD_temp   : std_logic_vector(15 downto 0);

-- Pulser --
signal s_in0				: std_logic_vector(63 downto 0);
signal s_in1				: std_logic_vector(63 downto 0);
-- RTC --
signal s_TxPG_valid         : std_logic := '0';
signal s_RxBF_valid         : std_logic := '0';
signal s_USB_valid	        : std_logic := '0';

signal s_T_done             : std_logic := '0';
signal s_S_done             : std_logic := '0';
signal s_D_done             : std_logic := '0';
signal s_R_done             : std_logic := '0';
signal s_TR_done            : std_logic := '0';

signal s_T_start            : std_logic := '0';
signal s_S_start            : std_logic := '0';
signal s_D_start            : std_logic := '0';
signal s_R_start            : std_logic := '0';
signal s_TR_start           : std_logic := '0';

signal s_IDLE_MODE		    : std_logic := '0';
signal s_INIT_MODE		    : std_logic := '0';
signal s_REG_SET_MODE	    : std_logic := '0';
signal s_TRETMENT_MODE	    : std_logic := '0';
signal s_SCAN_MODE	  		: std_logic := '0';
signal s_RECEIVE_MODE       : std_logic := '0';
signal s_TRANSFER_MODE	    : std_logic := '0';
signal s_DONE_MODE          : std_logic := '0';
signal s_FIN_MODE           : std_logic := '0';

-- USB --
signal s_3014_VALID			: std_logic;
signal s_3014_POLLING_FLAG	: std_logic;

signal s_3014_REG_READ_EN	: std_logic;
signal s_3014_REG_WRITE_EN	: std_logic;

--single write test--
signal s_reg0f0f_data		: std_logic_vector(15 downto 0);
signal s_IP_data			: std_logic_vector(15 downto 0);
signal s_RTC   				: std_logic;
signal s_TxPG_T				: std_logic;
signal s_TxPG_D				: std_logic;
signal s_RxBF  				: std_logic;
signal s_USB   				: std_logic;

signal s_IP_TxBF			: std_logic_vector(15 downto 0);
signal s_IP_RTC				: std_logic_vector(15 downto 0); 
signal s_IP_AFE				: std_logic_vector(15 downto 0); 

--========== Component ==========--
component clk_wiz_0 is
	port(
		--===== INPUT =====--
		clk_in1_p               : in std_logic;
		clk_in1_n               : in std_logic;
		reset                   : in std_logic;
	
		--===== OUTPUT =====--
		clk_Pulser              : out std_logic;
		clk_AFE_p               : out std_logic;
		clk_AFE_n				: out std_logic;
		clk_sys_40M				: out std_logic;
		clk_sys_10M				: out std_logic
	);
end component;

component RealTimeController is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_40M			: in std_logic;
		-- ADDRESS BUS --
		m_Address_Bus			: in std_logic_vector(15 downto 0);
		m_Data_Bus_WR			: in std_logic_vector(15 downto 0);
		m_USB_WEN				: in std_logic;
		m_USB_REN				: in std_logic;
		-- POWER --
		m_power_OFF				: in std_logic;
		-- State Signal --
		m_T_done                : in std_logic;
		m_S_done                : in std_logic;
		m_D_done                : in std_logic;
		m_R_done				: in std_logic;
		m_TR_done				: in std_logic;
		-- BATTERY --
		m_Battery_LEVEL			: in std_logic;
		m_BATT_STAT1			: in std_logic;
		-- SWITCH --
		m_MODE_SWITCH			: in std_logic;
		m_SELECT_SWITCH         : in std_logic;
		
		--===== OUTPUT =====--
		-- POWER --
		m_power_ON				: out std_logic;
		-- SW RESET --
		m_SW_RESET				: out std_logic;
		-- BUS --
		m_Data_Bus_RD			: out std_logic_vector(15 downto 0);
		-- State Signal --
		m_T_start               : out std_logic;
		m_S_start               : out std_logic;
		m_D_start				: out std_logic;
		m_R_start               : out std_logic;
		m_TR_start				: out std_logic;
		-- MODE --
		m_IDLE_MODE				: out std_logic;
		m_INIT_MODE				: out std_logic;
		m_REG_SET_MODE			: out std_logic;
		m_TRETMENT_MODE			: out std_logic;
		m_SCAN_MODE	  			: out std_logic;
		m_RECEIVE_MODE			: out std_logic;
		m_TRANSFER_MODE			: out std_logic;
		m_DONE_MODE				: out std_logic;
		m_FIN_MODE				: out std_logic;
		-- Pusler Voltage CONTROL --
		m_3V3ND_Ctrl			: out std_logic;
		m_Pulser_3V3_Ctrl		: out std_logic;
		-- HV CONTROL --
		m_HV_40VP_EN			: out std_logic;
		m_HV_80VP_EN            : out std_logic;
		m_HV_40VN_EN            : out std_logic;
		m_HV_80VN_EN            : out std_logic;
		m_HV_80_VIN_CTRL		: out std_logic;
		-- HV DROP CONTROL --
		m_HV_DROP_pos           : out std_logic;
		m_HV_DROP_neg           : out std_logic;
		-- Digital Potentiometer Control --
		--m_I2C_SCL               : out std_logic_vector(1 downto 0);
		--m_I2C_SDA               : out std_logic_vector(1 downto 0);
		-- Address valid signal --
		m_TxPG_valid            : out std_logic;
		m_RxBF_valid            : out std_logic;
		m_USB_valid				: out std_logic;
		--single write test --
		m_reg0f0f_data			: out std_logic_vector(15 downto 0);

		m_RTC   				: out std_logic;
		m_TxPG_T				: out std_logic;
		m_TxPG_D				: out std_logic;
		m_RxBF  				: out std_logic;
		m_USB   				: out std_logic	

	);
end component;

component USB_interface is
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
end component;

component TxBF_TOP is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_40M			: in std_logic;
		m_sys_clk_160M			: in std_logic;
		-- BUS --
		m_Address_Bus			: in std_logic_vector(11 downto 0);
		m_Data_Bus_WR			: in std_logic_vector(15 downto 0);
		m_TxPG_valid            : in std_logic;
		m_USB_WEN				: in std_logic;
		m_USB_REN				: in std_logic;
		-- State Signal --
		m_T_start               : in std_logic;
		m_S_start				: in std_logic;
		
		--===== OUTPUT =====--		
		-- BUS --
		m_Data_Bus_RD			: out std_logic_vector(15 downto 0);
		-- Pulser control --
		m_in0					: out std_logic_vector(63 downto 0);
		m_in1					: out std_logic_vector(63 downto 0);
		m_CW					: out std_logic;
		m_THSD					: out std_logic;
		-- Firing State --
		m_T_done				: out std_logic;
		m_S_done				: out std_logic
	);
end component;

component AFE_TOP is
Port(
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M     		: in std_logic;
	m_SPI_clk_10M     		: in std_logic;
	-- EN signal --
	m_RxBF_valid       		: in std_logic;
	m_wen         			: in std_logic;
	m_ren       			: in std_logic;
	-- Addr & Data --
	m_ADDR         			: in std_logic_vector(11 downto 0);
	m_DATA         			: in std_logic_vector(15 downto 0);
	-- SPI --
	m_sdout_SPI    			: in std_logic_vector(3 downto 0);
	
	--===== OUTPUT =====--
	-- SPI --
	m_sclk_SPI      		: out std_logic_vector(3 downto 0);
	m_sen_SPI       		: out std_logic_vector(3 downto 0);
	m_sdin_SPI      		: out std_logic_vector(3 downto 0);
	-- Control signal --
	m_reset_SPI_out 		: out std_logic_vector(3 downto 0);
	m_done_SPI      		: out std_logic_vector(3 downto 0);
	-- SPI DATA --
	m_RDATA         		: out std_logic_vector(15 downto 0)
);
end component;

--
---
begin
---
--

--========== Port mapping ==========--
RTC : RealTimeController
port map (
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M			=> s_sys_clk_40M,
	-- ADDRESS BUS --
	m_Address_Bus			=> s_Address_Bus,
	m_Data_Bus_WR			=> s_Data_Bus_WR,
	m_USB_WEN				=> s_3014_REG_WRITE_EN,
	m_USB_REN				=> s_3014_REG_READ_EN,
	-- POWER --
	m_power_OFF				=> m_power_OFF,
	-- State Signal --
	m_T_done                => s_T_done,
	m_S_done                => s_S_done,
	m_D_done                => s_D_done,
	m_R_done				=> s_R_done,
	m_TR_done				=> s_TR_done,
	-- BATTERY --
	m_Battery_LEVEL			=> m_Battery_LEVEL,
	m_BATT_STAT1			=> m_BATT_STAT1,
	-- SWITCH --
	m_MODE_SWITCH			=> m_MODE_SWITCH,
	m_SELECT_SWITCH         => m_SELECT_SWITCH,
	
	--===== OUTPUT =====--
	-- POWER --
	m_power_ON				=> m_power_ON,
	-- SW RESET --
	m_SW_RESET				=> s_SW_RESET,
	-- BUS --
	m_Data_Bus_RD			=> s_IP_RTC,
	-- State Signal --
	m_T_start               => s_T_start,
	m_S_start               => s_S_start,
	m_D_start				=> s_D_start,
	m_R_start               => s_R_start,
	m_TR_start				=> s_TR_start,
	-- MODE --
	m_IDLE_MODE				=> s_IDLE_MODE,		
	m_INIT_MODE				=> s_INIT_MODE,		
	m_REG_SET_MODE			=> s_REG_SET_MODE,	
	m_TRETMENT_MODE			=> s_TRETMENT_MODE,	
	m_SCAN_MODE	  			=> s_SCAN_MODE,	  	
	m_RECEIVE_MODE			=> s_RECEIVE_MODE,	
	m_TRANSFER_MODE			=> s_TRANSFER_MODE,	
	m_DONE_MODE				=> s_DONE_MODE,		
	m_FIN_MODE				=> s_FIN_MODE,		
	-- Pusler Voltage CONTROL --
	m_3V3ND_Ctrl			=> m_3V3ND_Ctrl,
	m_Pulser_3V3_Ctrl		=> m_Pulser_3V3_Ctrl,
	-- HV CONTROL --
	m_HV_40VP_EN			=> m_HV_40VP_EN,    
	m_HV_80VP_EN            => m_HV_80VP_EN,    
	m_HV_40VN_EN            => m_HV_40VN_EN,    
	m_HV_80VN_EN            => m_HV_80VN_EN,    
	m_HV_80_VIN_CTRL		=> m_HV_80_VIN_CTRL,
	-- HV DROP CONTROL -- 
	m_HV_DROP_pos           => m_HV_DROP_pos,
	m_HV_DROP_neg           => m_HV_DROP_neg,
	-- Digital Potentiometer Control --
	--m_I2C_SCL               : out std_logic_vector(1 downto 0);
	--m_I2C_SDA               : out std_logic_vector(1 downto 0);
	-- Address valid signal --
	m_TxPG_valid            => s_TxPG_valid,
	m_RxBF_valid            => s_RxBF_valid,
	m_USB_valid				=> s_USB_valid,
	--single write test --
	m_reg0f0f_data			=> s_reg0f0f_data,
	m_RTC   				=> s_RTC   ,
	m_TxPG_T				=> s_TxPG_T,
	m_TxPG_D				=> s_TxPG_D,
	m_RxBF  				=> s_RxBF  ,
	m_USB   				=> s_USB   


);

USB : USB_interface
port map(

	--===== INPUT =====--
	-- CLOCK --
	m_3014_PCLK           	=> m_3014_PCLK,
	m_FPGA_CLK_40M        	=> s_sys_clk_40M,
	-- Enable CONTROL --
	m_3014_RAM_REN        	=> m_3014_RAM_REN,
	m_3014_WEN            	=> m_3014_WEN,
	m_3014_REN            	=> m_3014_REN,
	-- Data by IP -- 
	m_IP_TxBF				=> s_IP_TxBF,
	m_IP_RTC 				=> s_IP_RTC, 
	m_IP_AFE 				=> s_IP_AFE, 
    m_RTC                   => s_RTC   ,
    m_TxPG_T                => s_TxPG_T,
    m_TxPG_D                => s_TxPG_D,
    m_RxBF                  => s_RxBF  ,
    m_USB                   => s_USB   ,
	--===== OUTPUT =====--
	-- CYUSB3014 -- 
	m_3014_VALID          	=> m_3014_VALID,
	m_3014_POLLING_FLAG   	=> m_3014_POLLING_FLAG,

	m_3014_REG_READ_EN    	=> s_3014_REG_READ_EN,
	m_3014_REG_WRITE_EN   	=> s_3014_REG_WRITE_EN,
	-- BUS --
	m_Address_Bus         	=> s_Address_Bus,
	m_Data_Bus            	=> s_Data_Bus_WR,
	--===== INOUT =====--
	m_3014_DQ             	=> m_3014_DQ		
);

TxBF : TxBF_TOP
port map ( 
	--===== INPUT =====--
    -- CLOCK --
    m_sys_clk_40M			=> s_sys_clk_40M,
    m_sys_clk_160M			=> s_sys_clk_160M,
    -- BUS --
    m_Address_Bus			=> s_Address_Bus(11 downto 0),
    m_Data_Bus_WR			=> s_Data_Bus_WR,
    m_TxPG_valid            => s_TxPG_valid,
    m_USB_WEN				=> s_3014_REG_WRITE_EN,
    m_USB_REN				=> s_3014_REG_READ_EN,
    -- State Signal --
    m_T_start               => s_T_start,
    m_S_start				=> s_S_start,
    
    --===== OUTPUT =====--	
    -- BUS --
    m_Data_Bus_RD			=> s_IP_TxBF,
    -- Pulser control --
    m_in0					=> s_in0,
    m_in1					=> s_in1,
    m_CW					=> m_CW,
    m_THSD					=> m_THSD,
    -- Firing State --
    m_T_done				=> s_T_done,
    m_S_done				=> s_S_done
);

AFE : AFE_TOP
port map(
	--===== INPUT =====--
    -- CLOCK --
    m_sys_clk_40M     		=> s_sys_clk_40M,
    m_SPI_clk_10M     		=> s_sys_clk_10M,
    -- EN signal --
    m_RxBF_valid       		=> s_RxBF_valid,
    m_wen         			=> m_3014_WEN,
    m_ren       			=> m_3014_REN,
    -- Addr & Data --
    m_ADDR         			=> s_Address_Bus(11 downto 0),
    m_DATA         			=> s_Data_Bus_WR,
    -- SPI --
    m_sdout_SPI    			=> m_AFE_SDOUT,
    
    --===== OUTPUT =====--
    -- SPI --
    m_sclk_SPI      		=> m_AFE_SCLK_10M,
    m_sen_SPI       		=> m_AFE_SEN,
    m_sdin_SPI      		=> m_AFE_SDIN,
    -- Control signal --
    m_reset_SPI_out 		=> m_AFE_RESET
    --m_done_SPI      		=> 
    -- SPI DATA --
    --m_RDATA         		=> s_Data_Bus_RD                              
);

--========== MAIN CLOCK ==========--
m_FPGA_CLK_160M				<= s_sys_clk_160M;
m_FPGA_CLK_40M_P			<= s_sys_clk_40M_p;
m_FPGA_CLK_40M_N			<= s_sys_clk_40M_n;
MAIN_CLK : clk_wiz_0
port map(
	--===== INPUT =====--
	clk_in1_p               => m_sys_clk_160M_p,
	clk_in1_n               => m_sys_clk_160M_n,
	reset                   => '0',

	--===== OUTPUT =====--
	clk_Pulser              => s_sys_clk_160M,
	clk_AFE_p               => s_sys_clk_40M_p,
	clk_AFE_n				=> s_sys_clk_40M_n,
	clk_sys_40M				=> s_sys_clk_40M,
	clk_sys_10M				=> s_sys_clk_10M
	);


--========== OUTPUT LOGIC ==========--
m_DEBUG_1V8_1           	<= s_T_start;			-- TP5
m_DEBUG_1V8_2           	<= s_in0(0);			-- TP6
m_DEBUG_1V8_3           	<= s_in1(0);			-- TP7
m_DEBUG_3V3_1           	<= s_REG_SET_MODE;		-- TP16
m_DEBUG_3V3_2           	<= s_Address_Bus(0);	-- TP17
m_DEBUG_3V3_3           	<= s_Data_Bus_WR(0);	-- TP18
m_DEBUG_LED					<= '1' when s_reg0f0f_data = x"0f0f";

---- AFE --
--m_AFE_RESET	           <= "0000";
--m_AFE_TX_TRIG		   <= "0000";
--m_AFE_PDN_FAST		   <= "0000";
--m_AFE_PDN_GBL	       <= "0000";
--m_AFE_SDIN	           <= "0000";
--m_AFE_SEN	           <= "0000";
--m_AFE_SCLK_10M         <= "0000";

-- Pulser --
m_IN1_P				   		<= s_in0(7 downto 0);
m_IN1_N				   		<= s_in1(7 downto 0);
m_IN2_P				   		<= s_in0(15 downto 8);
m_IN2_N				   		<= s_in1(15 downto 8);
m_IN3_P				   		<= s_in0(23 downto 16);
m_IN3_N				   		<= s_in1(23 downto 16);
m_IN4_P				   		<= s_in0(31 downto 24);
m_IN4_N				   		<= s_in1(31 downto 24);
m_IN5_P				   		<= s_in0(39 downto 32);
m_IN5_N				   		<= s_in1(39 downto 32);
m_IN6_P				   		<= s_in0(47 downto 40);
m_IN6_N				   		<= s_in1(47 downto 40);
m_IN7_P				   		<= s_in0(55 downto 48);
m_IN7_N				   		<= s_in1(55 downto 48);
m_IN8_P				   		<= s_in0(63 downto 56);
m_IN8_N				   		<= s_in1(63 downto 56);

m_I2C_SCL                   <= "ZZ";
m_I2C_SDA                   <= "ZZ";

end Behavioral;
