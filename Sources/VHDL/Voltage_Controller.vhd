----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/29 22:16:38
-- Design Name: 
-- Module Name: Voltage_Controller - Behavioral
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

entity Voltage_Controller is
	Port ( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M			: in std_logic;
	-- State --
	m_T_start				: in std_logic;
	m_D_start				: in std_logic;
	m_T_done				: in std_logic;
	m_D_done				: in std_logic;
	
	--===== OUTPUT =====--
	-- Pulser Voltage CONTROL --
	m_3V3ND_Ctrl			: out std_logic;
	m_Pulser_3V3_Ctrl		: out std_logic;
	-- HV CONTROL --
	m_HV_40VP_EN			: out std_logic;
	m_HV_80VP_EN            : out std_logic;
	m_HV_40VN_EN            : out std_logic;
	m_HV_80VN_EN            : out std_logic;
	m_HV_80_VIN_CTRL		: out std_logic;
	-- HV Drop CONTROL --
	m_HV_DROP_pos           : out std_logic;
	m_HV_DROP_neg           : out std_logic
	);
end Voltage_Controller;

architecture Behavioral of Voltage_Controller is


--===== SIGNALS =====--
-- CNT signal --
signal s_POS_HV_Drop_cnt	: std_logic_vector(31 downto 0);
signal s_NEG_HV_Drop_cnt	: std_logic_vector(31 downto 0);
-- CONTROL --
signal s_HV_DROP_pos        : std_logic;
signal s_HV_DROP_neg        : std_logic;

--
---
begin
---
--

--========== 3V3P_EN CONTROL ==========--
CTRL_3V3P : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_T_start = '1' or m_D_start = '1' then 
			m_Pulser_3V3_Ctrl 	<= '1';
		--elsif m_T_done = '1' or m_D_done = '1' then
		--	m_Pulser_3V3_Ctrl 	<= '0';
		end if;
	end if;
end process;
--========== 3V3N_EN CONTROL ==========--
CTRL_3V3N : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_T_start = '1' or m_D_start = '1' then 
			m_3V3ND_Ctrl 		<= '1';
		--elsif m_T_done = '1' or m_D_done = '1' then
		--	m_3V3ND_Ctrl 		<= '0';
		end if;
	end if;
end process;

--========== 40VP_EN CONTROL ==========--
CTRL_HV_40VP : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_T_start = '1' then 
			m_HV_40VP_EN 		<= '1';
		elsif m_T_done = '1' then
			m_HV_40VP_EN 		<= '0';
		end if;
	end if;
end process;
--========== 40VN_EN CONTROL ==========--
CTRL_HV_40VN : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_T_start = '1' then
			m_HV_40VN_EN 		<= '1';
		elsif m_T_done = '1' then
			m_HV_40VN_EN 		<= '0';
		end if;
	end if;
end process;

--========== 80VP_EN CONTROL ==========--
CTRL_HV_80VP : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_D_start = '1' then 
			m_HV_80VP_EN 		<= '1';
		elsif m_D_done = '1' then 
			m_HV_80VP_EN 		<= '0';
		end if;
	end if;
end process;
--========== 80VN_EN CONTROL ==========--
CTRL_HV_80VN : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_D_start = '1' then -- 일부러 +40이랑 같이 안나오도록
			m_HV_80VN_EN 		<= '1';
			m_HV_80_VIN_CTRL	<= '1';
		elsif m_D_done = '1' then 
			m_HV_80VN_EN 		<= '0';
			m_HV_80_VIN_CTRL	<= '0';
		end if;
	end if;
end process;



--========== POS HV Drop CONTROL ==========--
POS_HV_Drop : process(m_sys_clk_40M)
begin
	if m_T_done = '1' or m_D_done = '1' then 
		s_HV_DROP_pos 	<= '1';
	elsif s_POS_HV_Drop_cnt = x"0000000F" then
		s_HV_DROP_pos 	<= '0';
	end if;
end process;
POS_HV_Drop_counter : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if s_HV_DROP_pos = '1' then
			s_POS_HV_Drop_cnt <= s_POS_HV_Drop_cnt + 1;
		else 
			s_POS_HV_Drop_cnt <= (others =>'0');
		end if;
	end if;
end process;

--========== NEG HV Drop CONTROL ==========--
NEG_HV_Drop : process(m_sys_clk_40M)
begin
	if m_T_done = '1' or m_D_done = '1' then 
		s_HV_DROP_neg 	<= '1';
	elsif s_NEG_HV_Drop_cnt = x"0000000F" then
		s_HV_DROP_neg 	<= '0';
	end if;
end process;
NEG_HV_Drop_counter : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if s_HV_DROP_neg = '1' then
			s_NEG_HV_Drop_cnt <= s_NEG_HV_Drop_cnt + 1;
		else 
			s_NEG_HV_Drop_cnt <= (others =>'0');
		end if;
	end if;
end process;

m_HV_DROP_pos		<= s_HV_DROP_pos;	
m_HV_DROP_neg		<= s_HV_DROP_neg;	

end Behavioral;
