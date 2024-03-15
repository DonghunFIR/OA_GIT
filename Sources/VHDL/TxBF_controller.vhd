----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/12 10:52:31
-- Design Name: 
-- Module Name: TxBF_controller - Behavioral
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
 
entity TxBF_controller is
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
end TxBF_controller;

architecture Behavioral of TxBF_controller is

signal s_done				: std_logic_vector(63 downto 0);
signal s_T_in0              : std_logic_vector(63 downto 0);
signal s_T_in1              : std_logic_vector(63 downto 0);


component Firing_Treatment is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_160M			: in std_logic;							-- 1clk = 6.25ns
		-- CONTROL --
		m_Tx_start				: in std_logic;
		m_apo					: in std_logic;
		m_CW					: in std_logic;
		m_THSD					: in std_logic;
		m_polarity				: in std_logic;
		-- Pulse Form --
		m_fire_delay			: in std_logic_vector(15 downto 0);
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
		m_in0					: out std_logic;
		m_in1					: out std_logic;
		-- Firing State --
		m_Tx_done				: out std_logic
	);
end component;


--
---
begin
---
--


T_Channel : for i in 0 to 63 generate
Treatment : Firing_Treatment
port map
(
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_160M				=> m_sys_clk_160M,	
	-- CONTROL --    
	m_Tx_start					=> m_Tx_start,
	m_apo						=> m_apo(i),
	m_CW						=> m_CW,
	m_THSD						=> m_THSD,
	m_polarity					=> m_polarity,
	-- Pulse Form --	
	m_fire_delay				=> m_fire_delay(i),
	m_pch_duty_pre				=> m_pch_duty_pre,
	m_pch_duty_active			=> m_pch_duty_active,
	m_pch_duty_post				=> m_pch_duty_post,
	m_nch_duty_pre				=> m_nch_duty_pre,
	m_nch_duty_active			=> m_nch_duty_active,
	m_nch_duty_post				=> m_nch_duty_post,
	m_burst						=> m_burst,
	m_repeat					=> m_repeat,
	m_PRI						=> m_PRI,

	--===== OUTPUT =====--		
	-- Pulser control --	
	m_in0						=> s_T_in0(i),
	m_in1						=> s_T_in1(i),
	-- Firing State --      	
	m_Tx_done					=> s_done(i)
);
end generate;

--========== OUTPUT LOGIC ==========--
m_T_done			<= '1' when m_CW = '1' and s_done(0) = '1' else '0';
m_S_done            <= '1' when m_CW = '0' and s_done(0) = '1' else '0';
m_in0               <= s_T_in0;
m_in1               <= s_T_in1;

end Behavioral;
