----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/12 10:43:56
-- Design Name: 
-- Module Name: Firing_Diagnosis - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Firing_Diagnosis is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_160M			: in std_logic;							-- 1clk = 6.25ns
		-- CONTROL --
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
		m_burst					: in std_logic_vector(31 downto 0);		-- Burst cycle
		m_repeat				: in std_logic_vector(31 downto 0);		-- PRI repeat
		m_PRI					: in std_logic_vector(31 downto 0);
		
		--===== OUTPUT =====--		
		-- Pulser control --
		m_in0					: out std_logic;
		m_in1					: out std_logic;
		-- Firing State --
		m_Tx_ing				: out std_logic;
		m_S_done				: out std_logic
	);
end Firing_Diagnosis;

architecture Behavioral of Firing_Diagnosis is
--
---
begin
---
--

end Behavioral;
