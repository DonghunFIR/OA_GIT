----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/02/01 17:51:38
-- Design Name: 
-- Module Name: SPI_register - Behavioral
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

entity SPI_register is
Port (
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M			: in std_logic; 					--40MHz single
	-- EN signal --
	m_RxBF_valid			: in std_logic;
	m_wen					: in std_logic;
	m_ren					: in std_logic;
	-- Addr & Data --
	m_ADDR					: in std_logic_vector(11 downto 0);
	m_DATA					: in std_logic_vector(15 downto 0);
--	m_data_READ 			: in std_logic_vector(15 downto 0);
	
	--===== OUTPUT =====--WWW
	-- Data --
	m_data_SPI				: out std_logic_vector(23 downto 0);
	-- Control signal --
	m_start_SPI				: out std_logic;
	m_reset_SPI				: out std_logic
--	m_RDATA     			: out std_logic_vector(15 downto 0)
);
end SPI_register;

architecture Behavioral of SPI_register is

signal Flexible_Reg 		: std_logic_vector(23 downto 0):= (others => '0'); -- RESET
signal RESET_Reg			: std_logic_vector(23 downto 0):= (others => '0');
signal START_Reg			: std_logic_vector(23 downto 0):= (others => '0');
signal s_start				: std_logic := '0';
signal s_start_delay		: std_logic := '0';
signal s_start_delay1		: std_logic := '0';
signal s_start_delay2		: std_logic := '0';
signal s_start_delay3		: std_logic := '0';

signal s_reset				: std_logic := '0';
signal s_reset_delay		: std_logic := '0';
signal s_reset_delay1		: std_logic := '0';
signal s_reset_delay2		: std_logic := '0';
signal s_reset_delay3		: std_logic := '0';

--
---
begin
---
--

-- Register Set -- 
process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_RxBF_valid = '1' and m_wen = '1' then
			if m_ADDR(11 downto 8) = "0000" then
				Flexible_Reg(23 downto 16) <= m_ADDR(7 downto 0);
				Flexible_Reg(15 downto 0)  <= m_Data(15 downto 0);
			
			elsif m_ADDR(11 downto 8) = "0001" then
				RESET_Reg(23 downto 16) <= m_ADDR(7 downto 0);
				RESET_Reg(15 downto 0)  <= m_Data(15 downto 0);
	
			elsif m_ADDR(11 downto 8) = "0010" then
				START_Reg(23 downto 16) <= m_ADDR(7 downto 0);
				START_Reg(15 downto 0)  <= m_Data(15 downto 0);
			else
				null;
			end if;
		end if;
	end if;
end process;

-- SPI Set --
process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if START_Reg(0) = '1' then
			s_start	<= '1';
		else
			s_start <= '0';
		end if;
		if RESET_Reg(0) = '1' then
			s_reset <= '1';
		else
			s_reset <= '0';
		end if;
	end if;
end process;

--== start signal generation ==--
process(m_sys_clk_40M)
begin	
	if rising_edge(m_sys_clk_40M) then
		s_start_delay1 <= s_start;
		s_reset_delay1 <= s_reset;
	end if;
end process;

process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		s_start_delay2 <= s_start_delay1;
		s_reset_delay2 <= s_reset_delay1;
	end if;
end process;

process(m_sys_clk_40M)
begin	
	if rising_edge(m_sys_clk_40M) then
		s_start_delay3 <= s_start_delay2;
		s_reset_delay3 <= s_reset_delay2;
	end if;
end process;

process(m_sys_clk_40M)
begin	
	if rising_edge(m_sys_clk_40M) then
		s_start_delay <= not(s_start_delay3);
		s_reset_delay <= not(s_reset_delay3);
	end if;
end process;

--========== OUTPUT LOGIC ==========--
--m_RDATA			<= m_data_READ when m_ren = '1' else (others => 'Z');
m_data_SPI		<= Flexible_Reg;
m_start_SPI <= s_start_delay and s_start;
m_reset_SPI <= s_reset_delay and s_reset;
--m_RDATA		<= m_data_READ;

end Behavioral;
