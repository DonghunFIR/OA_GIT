----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/28 17:26:10
-- Design Name: 
-- Module Name: SPI_interface - Behavioral
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

entity SPI_interface is
Port (
	--===== INPUT =====--
	-- CLOCK --
	m_SPI_clk_10M			: in std_logic;
	-- SPI --
	m_sdout_SPI				: in std_logic;
	-- Control signal --	
	m_start_SPI 			: in std_logic;
	m_reset_SPI				: in std_logic;
	-- SPI DATA --
	m_data_SPI				: in std_logic_vector(23 downto 0);
	
	--===== OUTPUT =====--
	-- SPI --
	m_sclk_SPI				: out std_logic;
	m_sen_SPI				: out std_logic;
	m_sdin_SPI				: out std_logic;
	-- Control signal --
	m_reset_SPI_out			: out std_logic;
	m_done_SPI				: out std_logic;
	-- SPI DATA --
	m_data_read_SPI			: out std_logic_vector(15 downto 0)
);
end SPI_interface;

architecture Behavioral of SPI_interface is

signal s_shiftregister  		: std_logic_vector(23 downto 0) := (others => 'Z');
signal s_counter        		: INTEGER := 0;
signal s_reset_SPI				: std_logic := '0';
signal s_reset_SPI_d1			: std_logic := '0';
--  signal s_reset_SPI_d2		: std_logic := '0';
signal s_sen_SPI				: std_logic := '1';
signal s_start_SPI				: std_logic := '0';
signal s_done_SPI				: std_logic := '0';
signal s_shiftregister_read 	: std_logic_vector(23 downto 0) := (others => 'Z');
signal s_counter_read			: INTEGER := 0;
signal s_read_done_SPI			: std_logic := '0';
signal s_sdin_SPI				: std_logic := '0';
signal s_data_read_SPI			: std_logic_vector(15 downto 0) := (others => 'Z');

--
---
begin
---
--

process(m_SPI_clk_10M)
begin
	if falling_edge(m_SPI_clk_10M) then
		s_reset_SPI <= m_reset_SPI;
		s_reset_SPI_d1 <= s_reset_SPI;
		if m_start_SPI = '1' then
			s_start_SPI <= '1';
			s_shiftregister <= m_data_SPI;		
		else
			if s_start_SPI = '1' then
				if s_counter < 24 then
					s_done_SPI				<= '0';
					s_sen_SPI				<= '0';
					m_sdin_SPI				<= s_shiftregister(23);
					s_shiftregister			<= s_shiftregister(22 downto 0) & '0';
					s_counter				<= s_counter + 1;
					s_shiftregister_read 	<= s_shiftregister_read (22 downto 0) & m_sdout_SPI ;
					s_counter_read			<= s_counter_read + 1;
					s_read_done_SPI			<= '0';					
				else
					s_sen_SPI				<= '1';
					s_counter				<= 0;
					s_done_SPI				<= '1';
					s_start_SPI				<= '0';
					s_read_done_SPI 		<= '1';
					s_counter_read			<= 0;
					m_data_read_SPI			<= s_shiftregister_read(15 downto 0);
				end if;
			end if;		
		end if;
	end if;	
end process;


--========== OUTPUT LOGIC ==========--
m_reset_SPI_out		<= s_reset_SPI_d1 or s_reset_SPI;
m_done_SPI			<= s_done_SPI;
m_sclk_SPI			<= m_SPI_clk_10M;
m_sen_SPI			<= s_sen_SPI;

end Behavioral;
