----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/18 14:31:16
-- Design Name: 
-- Module Name: Tx_HV_controller - Behavioral
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

entity Tx_HV_controller is
	Port ( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_160M			: in std_logic;
	-- State --
	m_TX_mode				: in std_logic;
	m_TX_ing				: in std_logic_vector(63 downto 0);
	m_T_start				: in std_logic;
	m_D_start				: in std_logic;
	
	--===== OUTPUT =====--
	-- Voltage CONTROL OUTPUT --
	m_HV_40VP_EN			: out std_logic;
	m_HV_80VP_EN            : out std_logic;
	m_HV_40VN_EN            : out std_logic;
	m_HV_80VN_EN            : out std_logic;
	m_HV_80_VIN_CTRL		: out std_logic;
	m_HV_DROP_pos           : out std_logic;
	m_HV_DROP_neg           : out std_logic
	);
end Tx_HV_controller;

architecture Behavioral of Tx_HV_controller is

--===== SIGNALS =====--
-- CNT signal --
signal s_FPGA_power_cnt		: std_logic_vector(31 downto 0);
signal s_POS_HV_Drop_cnt	: std_logic_vector(31 downto 0);
signal s_NEG_HV_Drop_cnt	: std_logic_vector(31 downto 0);
-- CONTROL --
signal s_HV_40VP_EN         : std_logic;
signal s_HV_80VP_EN         : std_logic;
signal s_HV_40VN_EN         : std_logic;
signal s_HV_80VN_EN         : std_logic;
signal s_HV_80_VIN_CTRL     : std_logic;
signal s_HV_DROP_pos        : std_logic;
signal s_HV_DROP_neg        : std_logic;

--
---
begin
---
--
--========== 40VP_EN CONTROL ==========--
CTRL_HV_40VP : process(m_sys_clk_160M)
begin
	if m_T_start = '1' then 
		s_HV_40VP_EN 		<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_40VP_EN 		<= '0';
	end if;
end process;

--========== 80VP_EN CONTROL ==========--
CTRL_HV_80VP : process(m_sys_clk_160M)
begin
	if m_D_start = '1' then 
		s_HV_80VP_EN 		<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_80VP_EN 		<= '0';
	end if;
end process;

--========== 40VN_EN CONTROL ==========--
CTRL_HV_40VN : process(m_sys_clk_160M)
begin
	if m_T_start = '1' and s_HV_40VP_EN = '0' then -- 일부러 +40이랑 같이 안나오도록
		s_HV_40VN_EN 		<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_40VN_EN 		<= '0';
	end if;
end process;

--========== 80VN_EN CONTROL ==========--
CTRL_HV_80VN : process(m_sys_clk_160M)
begin
	if m_D_start = '1' and s_HV_40VP_EN = '0' then -- 일부러 +40이랑 같이 안나오도록
		s_HV_80VN_EN 		<= '1';
		s_HV_80_VIN_CTRL	<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_80VN_EN 		<= '0';
		s_HV_80_VIN_CTRL	<= '0';
	end if;
end process;

--========== POS HV Drop CONTROL ==========--
POS_HV_Drop : process(m_sys_clk_160M)
begin
	if s_POS_HV_Drop_cnt = x"0000000F" then 
		s_HV_DROP_pos 	<= '1';
	else
		s_HV_DROP_pos 	<= '0';
	end if;
end process;
POS_HV_Drop_counter : process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if s_HV_80VP_EN = '1' then
			s_POS_HV_Drop_cnt <= s_POS_HV_Drop_cnt + 1;
		else 
			s_POS_HV_Drop_cnt <= (others =>'0');
		end if;
	end if;
end process;

--========== NEG HV Drop CONTROL ==========--
NEG_HV_Drop : process(m_sys_clk_160M)
begin
	if s_NEG_HV_Drop_cnt = x"0000000F" then 
		s_HV_DROP_neg 	<= '1';
	else
		s_HV_DROP_neg 	<= '0';
	end if;
end process;
NEG_HV_Drop_counter : process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if s_HV_40VN_EN = '1' OR s_HV_80VN_EN = '1' then
			s_NEG_HV_Drop_cnt <= s_NEG_HV_Drop_cnt + 1;
		else 
			s_NEG_HV_Drop_cnt <= (others =>'0');
		end if;
	end if;
end process;

--========== OUTPUT LOGIC ==========--
m_HV_40VP_EN        <= s_HV_40VP_EN;
m_HV_80VP_EN        <= s_HV_80VP_EN;
m_HV_40VN_EN        <= s_HV_40VN_EN;
m_HV_80VN_EN        <= s_HV_80VN_EN;
m_HV_80_VIN_CTRL	<= s_HV_80_VIN_CTRL;
m_HV_DROP_pos		<= s_HV_DROP_pos;	-- 아직 1clk만 뜸 
m_HV_DROP_neg		<= s_HV_DROP_neg;	-- 아직 1clk만 뜸 + OR 로직 전에 초기화 하는 부분 추가 


end Behavioral;
