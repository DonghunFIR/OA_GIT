----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/31 11:21:26
-- Design Name: 
-- Module Name: Address_Decoder - Behavioral
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

entity Address_Decoder is
	Port (
	--===== INPUT =====--
	m_Address_Bus_RTC		: in std_logic_vector(3 downto 0);
	
	--===== OUTPUT =====--
	m_RTC                   : out std_logic;
	m_TxPG_T                : out std_logic;
	m_TxPG_D                : out std_logic;
	m_RxBF                  : out std_logic;
	m_USB                   : out std_logic
	);
end Address_Decoder;

architecture Behavioral of Address_Decoder is
--
---
begin
---
--
m_RTC     <= '1' when m_Address_Bus_RTC = x"0" else '0';
m_TxPG_T  <= '1' when m_Address_Bus_RTC = x"1" else '0';
m_TxPG_D  <= '1' when m_Address_Bus_RTC = x"2" else '0';
m_RxBF    <= '1' when m_Address_Bus_RTC = x"6" else '0';
m_USB     <= '1' when m_Address_Bus_RTC = x"A" else '0';

end Behavioral;
