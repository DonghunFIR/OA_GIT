----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/15 09:22:38
-- Design Name: 
-- Module Name: RTC - Behavioral
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

entity RealTimeController is
Port ( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_160M			: in std_logic;
	-- POWER --
	m_power_OFF				: in std_logic;
	-- Debug INPUT --
	m_RST_b					: in std_logic;
	m_HV_signal				: in std_logic_vector(1 downto 0);
	
	--===== OUTPUT =====--
	-- CLOCK --
	m_FPGA_CLK_160M			: out std_logic;
	m_FPGA_CLK_40M_p		: out std_logic;
	m_FPGA_CLK_40M_n		: out std_logic;
	-- POWER --
	m_power_ON				: out std_logic;
	-- CONTROL OUTPUT --
	m_3V3ND_Ctrl			: out std_logic;
	m_Pulser_3V3_Ctrl		: out std_logic;
	m_HV_40VP_EN			: out std_logic;
	m_HV_80VP_EN            : out std_logic;
	m_HV_40VN_EN            : out std_logic;
	m_HV_80VN_EN            : out std_logic;
	m_HV_80_VIN_CTRL		: out std_logic;
	m_HV_DROP_pos           : out std_logic;
	m_HV_DROP_neg           : out std_logic;
	);
end RTC;

architecture Behavioral of RTC is

signal s_FPGA_power_cnt		: std_logic_vector(31 downto 0);
signal s_POS_HV_Drop_cnt	: std_logic_vector(31 downto 0);
signal s_NEG_HV_Drop_cnt	: std_logic_vector(31 downto 0);
-- POWER --
signal s_power_OFF          : std_logic;
signal s_power_down			: std_logic;
-- CONTROL --
signal s_HV_signal			: std_logic_vector(1 downto 0);
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


--========== Software RESET ==========--
SW_reset : process(m_sys_clk_160M)
begin
	--if s_FPGA_power_cnt = x"1312d000" then
	if s_FPGA_power_cnt = x"0000000F" then
		s_power_down		<= '1';
	end if;
end process;

--========== POWER ON/OFF SWITCH ==========--
Power_down_counter : process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if s_power_OFF = '1' then
			s_FPGA_power_cnt <= s_FPGA_power_cnt + 1;
		else 
			s_FPGA_power_cnt <= (others =>'0');
		end if;
	end if;
end process;

--========== 3V3PD CONTROL ==========--
CTRL_3V3PD : process(m_sys_clk_160M)
begin
	if m_RST_b = '0' then 
		m_Pulser_3V3_Ctrl 	<= '0';
	elsif rising_edge(m_sys_clk_160M) then
		m_Pulser_3V3_Ctrl 	<= '1';
	end if;
end process;

--========== 3V3ND CONTROL ==========--
CTRL_3V3ND : process(m_sys_clk_160M)
begin
	if m_RST_b = '0' then 
		m_3V3ND_Ctrl 		<= '0';
	elsif rising_edge(m_sys_clk_160M) then
		m_3V3ND_Ctrl 		<= '1';
	end if;
end process;

--========== 40VP_EN CONTROL ==========--
CTRL_HV_40VP : process(m_sys_clk_160M)
begin
	if m_HV_signal = "00" then 
		s_HV_40VP_EN 		<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_40VP_EN 		<= '0';
	end if;
end process;

--========== 80VP_EN CONTROL ==========--
CTRL_HV_80VP : process(m_sys_clk_160M)
begin
	if m_HV_signal = "01" then 
		s_HV_80VP_EN 		<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_80VP_EN 		<= '0';
	end if;
end process;

--========== 40VN_EN CONTROL ==========--
CTRL_HV_40VN : process(m_sys_clk_160M)
begin
	if m_HV_signal = "10" and s_HV_40VP_EN = '0' then -- 일부러 +40이랑 같이 안나오도록
		s_HV_40VN_EN 		<= '1';
	elsif rising_edge(m_sys_clk_160M) then
		s_HV_40VN_EN 		<= '0';
	end if;
end process;

--========== 80VN_EN CONTROL ==========--
CTRL_HV_80VN : process(m_sys_clk_160M)
begin
	if m_HV_signal = "11" and s_HV_40VP_EN = '0' then -- 일부러 +40이랑 같이 안나오도록
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

m_power_ON			<= '1';

m_HV_40VP_EN        <= s_HV_40VP_EN;
m_HV_80VP_EN        <= s_HV_80VP_EN;
m_HV_40VN_EN        <= s_HV_40VN_EN;
m_HV_80VN_EN        <= s_HV_80VN_EN;
m_HV_80_VIN_CTRL	<= s_HV_80_VIN_CTRL;
m_HV_DROP_pos		<= s_HV_DROP_pos;	-- 아직 1clk만 뜸 
m_HV_DROP_neg		<= s_HV_DROP_neg;	-- 아직 1clk만 뜸 + OR 로직 전에 초기화 하는 부분 추가 

end Behavioral;
