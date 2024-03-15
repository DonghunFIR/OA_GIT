----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/12 10:40:46
-- Design Name: 
-- Module Name: TxBF_TOP - Behavioral
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
use WORK.pkg_util.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TxBF_TOP is
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
end TxBF_TOP;

architecture Behavioral of TxBF_TOP is

signal s_Data_Bus_wr			: std_logic_vector(15 downto 0) := (others=>'Z');
signal s_Data_Bus_rd			: std_logic_vector(15 downto 0) := (others=>'Z');

signal s_apo	                : std_logic_vector(63 downto 0);
signal s_polarity	            : std_logic;
signal s_CW	                    : std_logic;
signal s_THSD	                : std_logic;
signal s_Tx_start	            : std_logic;
signal s_Pch_period	            : std_logic_vector(15 downto 0);
signal s_Nch_period	            : std_logic_vector(15 downto 0);
signal s_delay	                : std_16bit_array(63 downto 0);
signal s_Pch_duty_pre	        : std_logic_vector(15 downto 0);
signal s_Pch_duty_act	        : std_logic_vector(15 downto 0);
signal s_Pch_duty_post	        : std_logic_vector(15 downto 0);
signal s_Nch_duty_pre	        : std_logic_vector(15 downto 0);
signal s_Nch_duty_act	        : std_logic_vector(15 downto 0);
signal s_Nch_duty_post	        : std_logic_vector(15 downto 0);
signal s_Burst_cycle	        : std_logic_vector(31 downto 0);
signal s_repeat	                : std_logic_vector(31 downto 0);
signal s_PRI	                : std_logic_vector(31 downto 0);


component TxBF_BUS_controller is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_40M			: in std_logic;
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
		-- CONTROL --
		m_apo					: out std_logic_vector(63 downto 0);
		m_polarity				: out std_logic;
		m_CW					: out std_logic;
		m_THSD					: out std_logic;
		m_Tx_start              : out std_logic;
		-- Pulse Form --
		m_freq0_pch				: out std_logic_vector(15 downto 0);
		m_freq0_nch				: out std_logic_vector(15 downto 0);
		m_fire_delay			: out std_16bit_array(63 downto 0);
		m_pch_duty_pre			: out std_logic_vector(15 downto 0);
		m_pch_duty_active		: out std_logic_vector(15 downto 0);
		m_pch_duty_post			: out std_logic_vector(15 downto 0);
		m_nch_duty_pre			: out std_logic_vector(15 downto 0);
		m_nch_duty_active		: out std_logic_vector(15 downto 0);
		m_nch_duty_post			: out std_logic_vector(15 downto 0);
		m_burst					: out std_logic_vector(31 downto 0);
		m_repeat				: out std_logic_vector(31 downto 0);
		m_PRI					: out std_logic_vector(31 downto 0)		
	);
end component;

component TxBF_controller is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_160M			: in std_logic;
		-- CONTROL --
		m_Tx_start				: in std_logic;
		m_apo					: in std_logic_vector(63 downto 0);
		m_CW					: in std_logic;
		m_THSD					: in std_logic;
		m_polarity				: in std_logic;
		-- Pulse Form --
		m_freq0_pch				: in std_logic_vector(15 downto 0);	
		m_freq0_nch				: in std_logic_vector(15 downto 0);	
		m_fire_delay			: in std_16bit_array(63 downto 0);
		m_pch_duty_pre			: in std_logic_vector(15 downto 0);
		m_pch_duty_active		: in std_logic_vector(15 downto 0);
		m_pch_duty_post			: in std_logic_vector(15 downto 0);
		m_nch_duty_pre			: in std_logic_vector(15 downto 0);
		m_nch_duty_active		: in std_logic_vector(15 downto 0);
		m_nch_duty_post			: in std_logic_vector(15 downto 0);
		m_burst					: in std_logic_vector(31 downto 0);		
		m_repeat				: in std_logic_vector(31 downto 0);		
		m_PRI					: in std_logic_vector(31 downto 0);
		
		--===== OUTPUT =====--		
		-- Pulser control --
		m_in0					: out std_logic_vector(63 downto 0);
		m_in1					: out std_logic_vector(63 downto 0);
		-- Firing State --
		m_T_done				: out std_logic;
		m_S_done				: out std_logic
	);
end component;

--
---
begin
---
--

TX_BUS : TxBF_BUS_controller
Port map( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M				=> m_sys_clk_40M,
	-- BUS --
	m_Address_Bus				=> m_Address_Bus,
	m_Data_Bus_WR				=> m_Data_Bus_WR,
	m_TxPG_valid				=> m_TxPG_valid,
	m_USB_WEN					=> m_USB_WEN,
	m_USB_REN					=> m_USB_REN,
	-- State Signal --
	m_T_start               	=> m_T_start,
	m_S_start					=> m_S_start,
		
	--===== OUTPUT =====--
	-- BUS --
	m_Data_Bus_RD				=> m_Data_Bus_RD,
	-- CONTROL --
	m_apo						=> s_apo,
	m_polarity					=> s_polarity,
	m_CW	                	=> s_CW,
	m_THSD	                	=> s_THSD,
	m_Tx_start					=> s_Tx_start,
	-- Pulse Form --
	m_freq0_pch					=> s_Pch_period,
	m_freq0_nch					=> s_Nch_period,
	m_fire_delay				=> s_delay,
	m_pch_duty_pre				=> s_Pch_duty_pre,
	m_pch_duty_active			=> s_Pch_duty_act,
	m_pch_duty_post				=> s_Pch_duty_post,
	m_nch_duty_pre				=> s_Nch_duty_pre,
	m_nch_duty_active			=> s_Nch_duty_act,
	m_nch_duty_post				=> s_Nch_duty_post,
	m_burst						=> s_Burst_cycle,
	m_repeat					=> s_repeat,
	m_PRI						=> s_PRI
);

TX_CONTROL : TxBF_controller
port map( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_160M				=> m_sys_clk_160M,					
	-- CONTROL --
	m_Tx_start					=> s_Tx_start,
	m_apo						=> s_apo,
	m_CW						=> s_CW,
	m_THSD						=> s_THSD,
	m_polarity					=> s_polarity,
	-- Pulse Form --
	m_freq0_pch					=> s_Pch_period,
	m_freq0_nch					=> s_Nch_period,	
	m_fire_delay				=> s_delay,
	m_pch_duty_pre				=> s_Pch_duty_pre,
	m_pch_duty_active			=> s_Pch_duty_act,
	m_pch_duty_post				=> s_Pch_duty_post,
	m_nch_duty_pre				=> s_Nch_duty_pre,
	m_nch_duty_active			=> s_Nch_duty_act,
	m_nch_duty_post				=> s_Nch_duty_post,
	m_burst						=> s_Burst_cycle,
	m_repeat					=> s_repeat,
	m_PRI						=> s_PRI,
	
	--===== OUTPUT =====--		
	-- Pulser control --
	m_in0						=> m_in0,
	m_in1						=> m_in1,
	-- Firing State --
	m_T_done					=> m_T_done,
	m_S_done					=> m_S_done
);
	
--===== OUTPUT LOGIC =====--
m_CW					<= s_CW;
m_THSD	                <= s_THSD;

end Behavioral;
