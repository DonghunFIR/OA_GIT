----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/22 10:24:31
-- Design Name: 
-- Module Name: TxBF_BUS_controller - Behavioral
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

entity TxBF_BUS_controller is
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
end TxBF_BUS_controller;

architecture Behavioral of TxBF_BUS_controller is
-- ===== Signal ===== --
signal s_Tx_start				: std_logic;
--signal s_Data_Bus_wr			: std_logic_vector(15 downto 0) := (others=>'Z');
--signal s_Data_Bus_rd			: std_logic_vector(15 downto 0) := (others=>'Z');

-- ===== Treatment Register ===== --
signal REG_Pch_period        	: std_logic_vector(15 downto 0);        -- pch_period
signal REG_Nch_period           : std_logic_vector(15 downto 0);        -- nch_period
signal REG_Burst_cycle          : std_logic_vector(31 downto 0);        -- Burst cycle
signal REG_Pch_duty_pre         : std_logic_vector(15 downto 0);        -- pch_duty_pre
signal REG_Pch_duty_act         : std_logic_vector(15 downto 0);        -- pch_duty_active
signal REG_Pch_duty_post        : std_logic_vector(15 downto 0);        -- pch_duty_post
signal REG_Nch_duty_pre         : std_logic_vector(15 downto 0);        -- nch_duty_pre
signal REG_Nch_duty_act         : std_logic_vector(15 downto 0);        -- nch_duty_active
signal REG_Nch_duty_post        : std_logic_vector(15 downto 0);        -- nch_duty_post
signal REG_PRI                	: std_logic_vector(31 downto 0);        -- PRI
signal REG_repeat               : std_logic_vector(31 downto 0);        -- Repeat
signal REG_Tx_info	            : std_logic_vector(15 downto 0);        -- THSD, CW, polarity
signal REG_apo					: std_logic_vector(63 downto 0);        -- Apo(1~16)
signal REG_delay				: std_16bit_array(63 downto 0);			-- Delay

-- ===== Diagnosis Register ===== --
--signal Reg2100                  : std_logic_vector(15 downto 0);        -- pch_period
--signal Reg2101                  : std_logic_vector(15 downto 0);        -- nch_period
--signal Reg2102                  : std_logic_vector(15 downto 0);        -- Burst cycle(1)
--signal Reg2103                  : std_logic_vector(15 downto 0);        -- Burst cycle(2)
--signal Reg2104                  : std_logic_vector(15 downto 0);        -- pch_duty_pre
--signal Reg2105                  : std_logic_vector(15 downto 0);        -- pch_duty_active
--signal Reg2106                  : std_logic_vector(15 downto 0);        -- pch_duty_post
--signal Reg2107                  : std_logic_vector(15 downto 0);        -- nch_duty_pre
--signal Reg2108                  : std_logic_vector(15 downto 0);        -- nch_duty_active
--signal Reg2109                  : std_logic_vector(15 downto 0);        -- nch_duty_post
--signal Reg210A                  : std_logic_vector(15 downto 0);        -- PRI(1)
--signal Reg210B                  : std_logic_vector(15 downto 0);        -- PRI(2)
--signal Reg210C                  : std_logic_vector(15 downto 0);        -- Repeat(1)
--signal Reg210D                  : std_logic_vector(15 downto 0);        -- Repeat(2)
--
--signal Reg2200					: std_logic_vector(63 downto 0);        -- Apo(1~16)
--signal Reg2201					: std_logic_vector(63 downto 0);        -- Apo(17~32)
--signal Reg2202					: std_logic_vector(63 downto 0);        -- Apo(33~48)
--signal Reg2203					: std_logic_vector(63 downto 0);        -- Apo(49~64)
--
--signal Reg230X					: std_16bit_array(63 downto 0);			-- Delay(1)
--signal Reg234X					: std_16bit_array(63 downto 0);			-- Delay(2)
--signal Reg238X					: std_16bit_array(63 downto 0);			-- Delay(3)
--signal Reg23CX					: std_16bit_array(63 downto 0);			-- Delay(4)
--signal Reg240X					: std_16bit_array(63 downto 0);			-- Delay(5)
--signal Reg244X					: std_16bit_array(63 downto 0);			-- Delay(6)
--signal Reg248X					: std_16bit_array(63 downto 0);			-- Delay(7)
--signal Reg24CX					: std_16bit_array(63 downto 0);			-- Delay(8)
--signal Reg250X					: std_16bit_array(63 downto 0);			-- Delay(9)
--signal Reg254X					: std_16bit_array(63 downto 0);			-- Delay(10)
--signal Reg258X					: std_16bit_array(63 downto 0);			-- Delay(11)
--signal Reg25CX					: std_16bit_array(63 downto 0);			-- Delay(12)
--signal Reg260X					: std_16bit_array(63 downto 0);			-- Delay(13)
--signal Reg264X					: std_16bit_array(63 downto 0);			-- Delay(14)
--signal Reg268X					: std_16bit_array(63 downto 0);			-- Delay(15)
--signal Reg26CX					: std_16bit_array(63 downto 0);			-- Delay(16)
--signal Reg270X					: std_16bit_array(63 downto 0);			-- Delay(17)
--signal Reg274X					: std_16bit_array(63 downto 0);			-- Delay(18)
--signal Reg278X					: std_16bit_array(63 downto 0);			-- Delay(19)
--signal Reg27CX					: std_16bit_array(63 downto 0);			-- Delay(20)
--signal Reg280X					: std_16bit_array(63 downto 0);			-- Delay(21)
--signal Reg284X					: std_16bit_array(63 downto 0);			-- Delay(22)
--signal Reg288X					: std_16bit_array(63 downto 0);			-- Delay(23)
--signal Reg28CX					: std_16bit_array(63 downto 0);			-- Delay(24)
--signal Reg290X					: std_16bit_array(63 downto 0);			-- Delay(25)
--signal Reg294X					: std_16bit_array(63 downto 0);			-- Delay(26)
--signal Reg298X					: std_16bit_array(63 downto 0);			-- Delay(27)
--signal Reg29CX					: std_16bit_array(63 downto 0);			-- Delay(28)
--signal Reg2A0X					: std_16bit_array(63 downto 0);			-- Delay(29)
--signal Reg2A4X					: std_16bit_array(63 downto 0);			-- Delay(30)
--signal Reg2A8X					: std_16bit_array(63 downto 0);			-- Delay(31)
--signal Reg2ACX					: std_16bit_array(63 downto 0);			-- Delay(32)
--signal Reg2B0X					: std_16bit_array(63 downto 0);			-- Delay(33)
--signal Reg2B4X					: std_16bit_array(63 downto 0);			-- Delay(34)
--signal Reg2B8X					: std_16bit_array(63 downto 0);			-- Delay(35)
--signal Reg2BCX					: std_16bit_array(63 downto 0);			-- Delay(36)
--signal Reg2C0X					: std_16bit_array(63 downto 0);			-- Delay(37)
--signal Reg2C4X					: std_16bit_array(63 downto 0);			-- Delay(38)
--signal Reg2C8X					: std_16bit_array(63 downto 0);			-- Delay(39)
--signal Reg2CCX					: std_16bit_array(63 downto 0);			-- Delay(40)
--signal Reg2D0X					: std_16bit_array(63 downto 0);			-- Delay(41)
--signal Reg2D4X					: std_16bit_array(63 downto 0);			-- Delay(42)
--signal Reg2D8X					: std_16bit_array(63 downto 0);			-- Delay(43)
--signal Reg2DCX					: std_16bit_array(63 downto 0);			-- Delay(44)
--signal Reg2E0X					: std_16bit_array(63 downto 0);			-- Delay(45)
--signal Reg2E4X					: std_16bit_array(63 downto 0);			-- Delay(46)
--signal Reg2E8X					: std_16bit_array(63 downto 0);			-- Delay(47)
--signal Reg2ECX					: std_16bit_array(63 downto 0);			-- Delay(48)

--
---
begin
---
--

---- Write --
--s_Data_Bus_wr   <= m_Data_Bus_WR;
---- Read --
--m_Data_Bus_RD	<= s_Data_Bus_rd when m_USB_REN = '1' else (others=>'Z');


----========== Write REG ==========--
process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_TxPG_valid = '1' and m_USB_WEN = '1' then
			--========== apo ==========--
			if 		m_Address_Bus = x"200" then REG_apo(15 downto 0) 			<= m_Data_Bus_WR; 
			elsif 	m_Address_Bus = x"201" then REG_apo(31 downto 16) 			<= m_Data_Bus_WR; 
			elsif 	m_Address_Bus = x"202" then REG_apo(47 downto 32) 			<= m_Data_Bus_WR; 
			elsif 	m_Address_Bus = x"203" then REG_apo(63 downto 48) 			<= m_Data_Bus_WR; 
			
			--========== Pulser control ==========--
			elsif m_Address_Bus = x"10E" then REG_Tx_info			 			<= m_Data_Bus_WR; 
			
			--========== Pulse Form ==========--
			elsif m_Address_Bus = x"100" then REG_Pch_period			    	<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"101" then REG_Nch_period			    	<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"102" then REG_Burst_cycle(31 downto 16)   	<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"103" then REG_Burst_cycle(15 downto 0) 		<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"104" then REG_Pch_duty_pre 					<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"105" then REG_Pch_duty_act     				<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"106" then REG_Pch_duty_post					<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"107" then REG_Nch_duty_pre 					<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"108" then REG_Nch_duty_act 					<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"109" then REG_Nch_duty_post   				<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"10A" then REG_PRI(31 downto 16)  			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"10B" then REG_PRI(15 downto 0)  			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"10C" then REG_repeat(31 downto 16)  		<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"10D" then REG_repeat(15 downto 0)  			<= m_Data_Bus_WR; 
			
			--========== Fire Delay ==========--
			elsif m_Address_Bus = x"300" then REG_delay(0)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"301" then REG_delay(1)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"302" then REG_delay(2)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"303" then REG_delay(3)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"304" then REG_delay(4)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"305" then REG_delay(5)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"306" then REG_delay(6)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"307" then REG_delay(7)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"308" then REG_delay(8)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"309" then REG_delay(9)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"30A" then REG_delay(10)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"30B" then REG_delay(11)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"30C" then REG_delay(12)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"30D" then REG_delay(13)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"30E" then REG_delay(14)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"30F" then REG_delay(15)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"310" then REG_delay(16)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"311" then REG_delay(17)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"312" then REG_delay(18)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"313" then REG_delay(19)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"314" then REG_delay(20)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"315" then REG_delay(21)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"316" then REG_delay(22)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"317" then REG_delay(23)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"318" then REG_delay(24)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"319" then REG_delay(25)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"31A" then REG_delay(26)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"31B" then REG_delay(27)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"31C" then REG_delay(28)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"31D" then REG_delay(29)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"31E" then REG_delay(30)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"31F" then REG_delay(31)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"320" then REG_delay(32)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"321" then REG_delay(33)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"322" then REG_delay(34)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"323" then REG_delay(35)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"324" then REG_delay(36)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"325" then REG_delay(37)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"326" then REG_delay(38)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"327" then REG_delay(39)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"328" then REG_delay(40)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"329" then REG_delay(41)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"32A" then REG_delay(42)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"32B" then REG_delay(43)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"32C" then REG_delay(44)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"32D" then REG_delay(45)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"32E" then REG_delay(46)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"32F" then REG_delay(47)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"330" then REG_delay(48)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"331" then REG_delay(49)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"332" then REG_delay(50)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"333" then REG_delay(51)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"334" then REG_delay(52)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"335" then REG_delay(53)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"336" then REG_delay(54)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"337" then REG_delay(55)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"338" then REG_delay(56)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"339" then REG_delay(57)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"33A" then REG_delay(58)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"33B" then REG_delay(59)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"33C" then REG_delay(60)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"33D" then REG_delay(61)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"33E" then REG_delay(62)			 			<= m_Data_Bus_WR; 
			elsif m_Address_Bus = x"33F" then REG_delay(63)			 			<= m_Data_Bus_WR; 
			end if;
		end if;
	end if;
end process;

--REG_apo(15 downto 0) 			<= s_Data_Bus_wr			when m_Address_Bus = x"200" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_apo(31 downto 16) 			<= s_Data_Bus_wr			when m_Address_Bus = x"201" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_apo(47 downto 32) 			<= s_Data_Bus_wr			when m_Address_Bus = x"202" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_apo(63 downto 48) 			<= s_Data_Bus_wr			when m_Address_Bus = x"203" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Tx_info 					<= s_Data_Bus_wr			when m_Address_Bus = x"10E" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Pch_period			    	<= s_Data_Bus_wr			when m_Address_Bus = x"100" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Nch_period			    	<= s_Data_Bus_wr			when m_Address_Bus = x"101" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Burst_cycle(31 downto 16)   <= s_Data_Bus_wr			when m_Address_Bus = x"102" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Burst_cycle(15 downto 0) 	<= s_Data_Bus_wr			when m_Address_Bus = x"103" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Pch_duty_pre 				<= s_Data_Bus_wr			when m_Address_Bus = x"104" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Pch_duty_act     			<= s_Data_Bus_wr			when m_Address_Bus = x"105" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Pch_duty_post				<= s_Data_Bus_wr			when m_Address_Bus = x"106" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Nch_duty_pre 				<= s_Data_Bus_wr			when m_Address_Bus = x"107" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Nch_duty_act 				<= s_Data_Bus_wr			when m_Address_Bus = x"108" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_Nch_duty_post   			<= s_Data_Bus_wr			when m_Address_Bus = x"109" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_PRI(31 downto 16)  			<= s_Data_Bus_wr			when m_Address_Bus = x"10A" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_PRI(15 downto 0)  			<= s_Data_Bus_wr			when m_Address_Bus = x"10B" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_repeat(31 downto 16)  		<= s_Data_Bus_wr			when m_Address_Bus = x"10C" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_repeat(15 downto 0)  		<= s_Data_Bus_wr			when m_Address_Bus = x"10D" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(0)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"300" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(1)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"301" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(2)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"302" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(3)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"303" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(4)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"304" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(5)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"305" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(6)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"306" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(7)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"307" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(8)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"308" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(9)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"309" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(10)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"30A" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(11)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"30B" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(12)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"30C" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(13)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"30D" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(14)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"30E" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(15)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"30F" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(16)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"310" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(17)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"311" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(18)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"312" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(19)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"313" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(20)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"314" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(21)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"315" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(22)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"316" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(23)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"317" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(24)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"318" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(25)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"319" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(26)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"31A" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(27)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"31B" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(28)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"31C" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(29)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"31D" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(30)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"31E" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(31)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"31F" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(32)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"320" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(33)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"321" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(34)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"322" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(35)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"323" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(36)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"324" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(37)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"325" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(38)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"326" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(39)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"327" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(40)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"328" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(41)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"329" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(42)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"32A" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(43)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"32B" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(44)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"32C" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(45)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"32D" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(46)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"32E" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(47)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"32F" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(48)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"330" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(49)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"331" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(50)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"332" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(51)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"333" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(52)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"334" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(53)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"335" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(54)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"336" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(55)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"337" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(56)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"338" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(57)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"339" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(58)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"33A" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(59)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"33B" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(60)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"33C" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(61)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"33D" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(62)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"33E" and m_TxPG_valid = '1' and m_USB_WEN = '1';
--REG_delay(63)		    		<= s_Data_Bus_wr			when m_Address_Bus = x"33F" and m_TxPG_valid = '1' and m_USB_WEN = '1';


----========== READ REG ==========--
--process(m_sys_clk_40M)
--begin
--	if rising_edge(m_sys_clk_40M) then
--		if m_TxPG_valid = '1' and m_USB_REN = '1' then
--			--========== apo ==========--
--			if 		m_Address_Bus = x"200" then m_Data_Bus_rd	<= REG_apo(15 downto 0);
--			elsif	m_Address_Bus = x"201" then m_Data_Bus_rd	<= REG_apo(31 downto 16);
--			elsif	m_Address_Bus = x"202" then m_Data_Bus_rd	<= REG_apo(47 downto 32);
--			elsif	m_Address_Bus = x"203" then m_Data_Bus_rd	<= REG_apo(63 downto 48);
--			
--			--========== Pulser control ==========--
--			elsif	m_Address_Bus = x"10E" then m_Data_Bus_rd	<= REG_Tx_info;
--			
--			--========== Pulse Form ==========--
--			elsif	m_Address_Bus = x"100" then m_Data_Bus_rd	<= REG_Pch_period;
--			elsif	m_Address_Bus = x"101" then m_Data_Bus_rd	<= REG_Nch_period;
--			elsif	m_Address_Bus = x"102" then m_Data_Bus_rd	<= REG_Burst_cycle(31 downto 16);
--			elsif	m_Address_Bus = x"103" then m_Data_Bus_rd	<= REG_Burst_cycle(15 downto 0);
--			elsif	m_Address_Bus = x"104" then m_Data_Bus_rd	<= REG_Pch_duty_pre;
--			elsif	m_Address_Bus = x"105" then m_Data_Bus_rd	<= REG_Pch_duty_act;
--			elsif	m_Address_Bus = x"106" then m_Data_Bus_rd	<= REG_Pch_duty_post;
--			elsif	m_Address_Bus = x"107" then m_Data_Bus_rd	<= REG_Nch_duty_pre;
--			elsif	m_Address_Bus = x"108" then m_Data_Bus_rd	<= REG_Nch_duty_act;
--			elsif	m_Address_Bus = x"109" then m_Data_Bus_rd	<= REG_Nch_duty_post;
--			elsif	m_Address_Bus = x"10A" then m_Data_Bus_rd	<= REG_PRI(31 downto 16);
--			elsif	m_Address_Bus = x"10B" then m_Data_Bus_rd	<= REG_PRI(15 downto 0);
--			elsif	m_Address_Bus = x"10C" then m_Data_Bus_rd	<= REG_repeat(31 downto 16);
--			elsif	m_Address_Bus = x"10D" then m_Data_Bus_rd	<= REG_repeat(15 downto 0);
--			
--			--========== Fire Delay ==========--
--			elsif	m_Address_Bus = x"300" then m_Data_Bus_rd	<= REG_delay(0);
--			elsif	m_Address_Bus = x"301" then m_Data_Bus_rd	<= REG_delay(1);
--			elsif	m_Address_Bus = x"302" then m_Data_Bus_rd	<= REG_delay(2);
--			elsif	m_Address_Bus = x"303" then m_Data_Bus_rd	<= REG_delay(3);
--			elsif	m_Address_Bus = x"304" then m_Data_Bus_rd	<= REG_delay(4);
--			elsif	m_Address_Bus = x"305" then m_Data_Bus_rd	<= REG_delay(5);
--			elsif	m_Address_Bus = x"306" then m_Data_Bus_rd	<= REG_delay(6);
--			elsif	m_Address_Bus = x"307" then m_Data_Bus_rd	<= REG_delay(7);
--			elsif	m_Address_Bus = x"308" then m_Data_Bus_rd	<= REG_delay(8);
--			elsif	m_Address_Bus = x"309" then m_Data_Bus_rd	<= REG_delay(9);
--			elsif	m_Address_Bus = x"30A" then m_Data_Bus_rd	<= REG_delay(10);
--			elsif	m_Address_Bus = x"30B" then m_Data_Bus_rd	<= REG_delay(11);
--			elsif	m_Address_Bus = x"30C" then m_Data_Bus_rd	<= REG_delay(12);
--			elsif	m_Address_Bus = x"30D" then m_Data_Bus_rd	<= REG_delay(13);
--			elsif	m_Address_Bus = x"30E" then m_Data_Bus_rd	<= REG_delay(14);
--			elsif	m_Address_Bus = x"30F" then m_Data_Bus_rd	<= REG_delay(15);
--			elsif	m_Address_Bus = x"310" then m_Data_Bus_rd	<= REG_delay(16);
--			elsif	m_Address_Bus = x"311" then m_Data_Bus_rd	<= REG_delay(17);
--			elsif	m_Address_Bus = x"312" then m_Data_Bus_rd	<= REG_delay(18);
--			elsif	m_Address_Bus = x"313" then m_Data_Bus_rd	<= REG_delay(19);
--			elsif	m_Address_Bus = x"314" then m_Data_Bus_rd	<= REG_delay(20);
--			elsif	m_Address_Bus = x"315" then m_Data_Bus_rd	<= REG_delay(21);
--			elsif	m_Address_Bus = x"316" then m_Data_Bus_rd	<= REG_delay(22);
--			elsif	m_Address_Bus = x"317" then m_Data_Bus_rd	<= REG_delay(23);
--			elsif	m_Address_Bus = x"318" then m_Data_Bus_rd	<= REG_delay(24);
--			elsif	m_Address_Bus = x"319" then m_Data_Bus_rd	<= REG_delay(25);
--			elsif	m_Address_Bus = x"31A" then m_Data_Bus_rd	<= REG_delay(26);
--			elsif	m_Address_Bus = x"31B" then m_Data_Bus_rd	<= REG_delay(27);
--			elsif	m_Address_Bus = x"31C" then m_Data_Bus_rd	<= REG_delay(28);
--			elsif	m_Address_Bus = x"31D" then m_Data_Bus_rd	<= REG_delay(29);
--			elsif	m_Address_Bus = x"31E" then m_Data_Bus_rd	<= REG_delay(30);
--			elsif	m_Address_Bus = x"31F" then m_Data_Bus_rd	<= REG_delay(31);
--			elsif	m_Address_Bus = x"320" then m_Data_Bus_rd	<= REG_delay(32);
--			elsif	m_Address_Bus = x"321" then m_Data_Bus_rd	<= REG_delay(33);
--			elsif	m_Address_Bus = x"322" then m_Data_Bus_rd	<= REG_delay(34);
--			elsif	m_Address_Bus = x"323" then m_Data_Bus_rd	<= REG_delay(35);
--			elsif	m_Address_Bus = x"324" then m_Data_Bus_rd	<= REG_delay(36);
--			elsif	m_Address_Bus = x"325" then m_Data_Bus_rd	<= REG_delay(37);
--			elsif	m_Address_Bus = x"326" then m_Data_Bus_rd	<= REG_delay(38);
--			elsif	m_Address_Bus = x"327" then m_Data_Bus_rd	<= REG_delay(39);
--			elsif	m_Address_Bus = x"328" then m_Data_Bus_rd	<= REG_delay(40);
--			elsif	m_Address_Bus = x"329" then m_Data_Bus_rd	<= REG_delay(41);
--			elsif	m_Address_Bus = x"32A" then m_Data_Bus_rd	<= REG_delay(42);
--			elsif	m_Address_Bus = x"32B" then m_Data_Bus_rd	<= REG_delay(43);
--			elsif	m_Address_Bus = x"32C" then m_Data_Bus_rd	<= REG_delay(44);
--			elsif	m_Address_Bus = x"32D" then m_Data_Bus_rd	<= REG_delay(45);
--			elsif	m_Address_Bus = x"32E" then m_Data_Bus_rd	<= REG_delay(46);
--			elsif	m_Address_Bus = x"32F" then m_Data_Bus_rd	<= REG_delay(47);
--			elsif	m_Address_Bus = x"330" then m_Data_Bus_rd	<= REG_delay(48);
--			elsif	m_Address_Bus = x"331" then m_Data_Bus_rd	<= REG_delay(49);
--			elsif	m_Address_Bus = x"332" then m_Data_Bus_rd	<= REG_delay(50);
--			elsif	m_Address_Bus = x"333" then m_Data_Bus_rd	<= REG_delay(51);
--			elsif	m_Address_Bus = x"334" then m_Data_Bus_rd	<= REG_delay(52);
--			elsif	m_Address_Bus = x"335" then m_Data_Bus_rd	<= REG_delay(53);
--			elsif	m_Address_Bus = x"336" then m_Data_Bus_rd	<= REG_delay(54);
--			elsif	m_Address_Bus = x"337" then m_Data_Bus_rd	<= REG_delay(55);
--			elsif	m_Address_Bus = x"338" then m_Data_Bus_rd	<= REG_delay(56);
--			elsif	m_Address_Bus = x"339" then m_Data_Bus_rd	<= REG_delay(57);
--			elsif	m_Address_Bus = x"33A" then m_Data_Bus_rd	<= REG_delay(58);
--			elsif	m_Address_Bus = x"33B" then m_Data_Bus_rd	<= REG_delay(59);
--			elsif	m_Address_Bus = x"33C" then m_Data_Bus_rd	<= REG_delay(60);
--			elsif	m_Address_Bus = x"33D" then m_Data_Bus_rd	<= REG_delay(61);
--			elsif	m_Address_Bus = x"33E" then m_Data_Bus_rd	<= REG_delay(62);
--			elsif	m_Address_Bus = x"33F" then m_Data_Bus_rd	<= REG_delay(63);
--			end if;
--		end if;
--	end if;
--end process;

--s_Data_Bus_rd						<= REG_apo(15 downto 0)  			when m_Address_Bus = x"200" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_apo(31 downto 16) 			when m_Address_Bus = x"201" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_apo(47 downto 32) 			when m_Address_Bus = x"202" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_apo(63 downto 48) 			when m_Address_Bus = x"203" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Tx_info	when m_Address_Bus = x"10E" and m_TxPG_valid = '1' and m_USB_REN = '1';
--s_Data_Bus_rd						<= REG_Pch_period					when m_Address_Bus = x"100" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Nch_period					when m_Address_Bus = x"101" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Burst_cycle(31 downto 16)    when m_Address_Bus = x"102" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Burst_cycle(15 downto 0) 	when m_Address_Bus = x"103" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Pch_duty_pre 				when m_Address_Bus = x"104" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Pch_duty_act     			when m_Address_Bus = x"105" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Pch_duty_post				when m_Address_Bus = x"106" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Nch_duty_pre 				when m_Address_Bus = x"107" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Nch_duty_act 				when m_Address_Bus = x"108" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_Nch_duty_post   			 	when m_Address_Bus = x"109" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_PRI(31 downto 16)  			when m_Address_Bus = x"10A" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_PRI(15 downto 0)  			when m_Address_Bus = x"10B" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_repeat(31 downto 16)  		when m_Address_Bus = x"10C" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_repeat(15 downto 0)  		when m_Address_Bus = x"10D" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(0)						when m_Address_Bus = x"300" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(1)						when m_Address_Bus = x"301" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(2)						when m_Address_Bus = x"302" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(3)						when m_Address_Bus = x"303" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(4)						when m_Address_Bus = x"304" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(5)						when m_Address_Bus = x"305" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(6)						when m_Address_Bus = x"306" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(7)						when m_Address_Bus = x"307" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(8)						when m_Address_Bus = x"308" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(9)						when m_Address_Bus = x"309" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(10) 					when m_Address_Bus = x"30A" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(11) 					when m_Address_Bus = x"30B" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(12) 					when m_Address_Bus = x"30C" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(13) 					when m_Address_Bus = x"30D" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(14) 					when m_Address_Bus = x"30E" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(15) 					when m_Address_Bus = x"30F" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(16) 					when m_Address_Bus = x"310" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(17) 					when m_Address_Bus = x"311" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(18) 					when m_Address_Bus = x"312" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(19) 					when m_Address_Bus = x"313" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(20) 					when m_Address_Bus = x"314" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(21) 					when m_Address_Bus = x"315" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(22) 					when m_Address_Bus = x"316" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(23) 					when m_Address_Bus = x"317" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(24) 					when m_Address_Bus = x"318" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(25) 					when m_Address_Bus = x"319" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(26) 					when m_Address_Bus = x"31A" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(27) 					when m_Address_Bus = x"31B" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(28) 					when m_Address_Bus = x"31C" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(29) 					when m_Address_Bus = x"31D" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(30) 					when m_Address_Bus = x"31E" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(31) 					when m_Address_Bus = x"31F" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(32) 					when m_Address_Bus = x"320" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(33) 					when m_Address_Bus = x"321" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(34) 					when m_Address_Bus = x"322" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(35) 					when m_Address_Bus = x"323" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(36) 					when m_Address_Bus = x"324" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(37) 					when m_Address_Bus = x"325" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(38) 					when m_Address_Bus = x"326" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(39) 					when m_Address_Bus = x"327" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(40) 					when m_Address_Bus = x"328" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(41) 					when m_Address_Bus = x"329" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(42) 					when m_Address_Bus = x"32A" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(43) 					when m_Address_Bus = x"32B" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(44) 					when m_Address_Bus = x"32C" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(45) 					when m_Address_Bus = x"32D" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(46) 					when m_Address_Bus = x"32E" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(47) 					when m_Address_Bus = x"32F" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(48) 					when m_Address_Bus = x"330" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(49) 					when m_Address_Bus = x"331" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(50) 					when m_Address_Bus = x"332" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(51) 					when m_Address_Bus = x"333" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(52) 					when m_Address_Bus = x"334" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(53) 					when m_Address_Bus = x"335" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(54) 					when m_Address_Bus = x"336" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(55) 					when m_Address_Bus = x"337" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(56) 					when m_Address_Bus = x"338" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(57) 					when m_Address_Bus = x"339" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(58) 					when m_Address_Bus = x"33A" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(59) 					when m_Address_Bus = x"33B" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(60) 					when m_Address_Bus = x"33C" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(61) 					when m_Address_Bus = x"33D" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(62) 					when m_Address_Bus = x"33E" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";
--s_Data_Bus_rd						<= REG_delay(63) 					when m_Address_Bus = x"33F" and m_TxPG_valid = '1' and m_USB_REN = '1' else "ZZZZZZZZZZZZZZZZ";


----========== OUTPUT LOGIC ==========--
s_Tx_start				<= '1' when m_T_start = '1' or m_S_start = '1' else '0';
-- CONTROL --
m_apo					<= REG_apo;
m_CW					<= REG_Tx_info(0);
m_polarity				<= REG_Tx_info(1);
m_THSD					<= REG_Tx_info(2);
m_Tx_start				<= s_Tx_start;
-- Pulse Form --
m_freq0_pch				<= REG_Pch_period;
m_freq0_nch				<= REG_Nch_period;
m_fire_delay			<= REG_delay;
m_pch_duty_pre			<= REG_Pch_duty_pre;
m_pch_duty_active		<= REG_Pch_duty_act;
m_pch_duty_post			<= REG_Pch_duty_post;
m_nch_duty_pre			<= REG_Nch_duty_pre;
m_nch_duty_active		<= REG_Nch_duty_act;
m_nch_duty_post			<= REG_Nch_duty_post;
m_burst					<= REG_Burst_cycle;
m_repeat				<= REG_repeat;
m_PRI					<= REG_PRI;

end Behavioral;
