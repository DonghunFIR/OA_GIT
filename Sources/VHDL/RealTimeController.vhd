----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/01/18 14:01:20
-- Design Name: 
-- Module Name: RealTimeController - Behavioral
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

entity RealTimeController is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_40M			: in std_logic;
		-- ADDRESS BUS --
		m_Address_Bus			: in std_logic_vector(15 downto 0);
		m_Data_Bus_WR			: in std_logic_vector(15 downto 0);
		m_USB_WEN				: in std_logic;
		m_USB_REN				: in std_logic;
		-- POWER --
		m_power_OFF				: in std_logic;
		-- State Signal --
		m_T_done                : in std_logic;
		m_S_done                : in std_logic;
		m_D_done                : in std_logic;
		m_R_done				: in std_logic;
		m_TR_done				: in std_logic;
		-- BATTERY --
		m_Battery_LEVEL			: in std_logic;
		m_BATT_STAT1			: in std_logic;
		-- SWITCH --
		m_MODE_SWITCH			: in std_logic;
		m_SELECT_SWITCH         : in std_logic;
		
		--===== OUTPUT =====--
		-- POWER --
		m_power_ON				: out std_logic;
		-- SW RESET --
		m_SW_RESET				: out std_logic;
		-- BUS --
		m_Data_Bus_RD			: out std_logic_vector(15 downto 0);
		-- State Signal --
		m_T_start               : out std_logic;
		m_S_start               : out std_logic;
		m_D_start				: out std_logic;
		m_R_start               : out std_logic;
		m_TR_start				: out std_logic;
		-- MODE --
		m_IDLE_MODE				: out std_logic;
		m_INIT_MODE				: out std_logic;
		m_REG_SET_MODE			: out std_logic;
		m_TRETMENT_MODE			: out std_logic;
		m_SCAN_MODE	  			: out std_logic;
		m_RECEIVE_MODE			: out std_logic;
		m_TRANSFER_MODE			: out std_logic;
		m_DONE_MODE				: out std_logic;
		m_FIN_MODE				: out std_logic;
		-- Pusler Voltage CONTROL --
		m_3V3ND_Ctrl			: out std_logic;
		m_Pulser_3V3_Ctrl		: out std_logic;
		-- HV CONTROL --
		m_HV_40VP_EN			: out std_logic;
		m_HV_80VP_EN            : out std_logic;
		m_HV_40VN_EN            : out std_logic;
		m_HV_80VN_EN            : out std_logic;
		m_HV_80_VIN_CTRL		: out std_logic;
		-- HV DROP CONTROL --
		m_HV_DROP_pos           : out std_logic;
		m_HV_DROP_neg           : out std_logic;
		-- Digital Potentiometer Control --
		--m_I2C_SCL               : out std_logic_vector(1 downto 0);
		--m_I2C_SDA               : out std_logic_vector(1 downto 0);
		-- Address valid signal --
		m_TxPG_valid            : out std_logic;
		m_RxBF_valid            : out std_logic;
		m_USB_valid				: out std_logic;

		--Single test--
		m_reg0f0f_data			: out std_logic_vector(15 downto 0);
		m_IP_data				: out std_logic_vector(15 downto 0);

		m_RTC   				: out std_logic;
		m_TxPG_T				: out std_logic;
		m_TxPG_D				: out std_logic;
		m_RxBF  				: out std_logic;
		m_USB   				: out std_logic			
			
	);
end RealTimeController;

architecture Behavioral of RealTimeController is
type states is (IDLE, INIT, REG_SET, TREATMENT, SCAN, RECEIVE, TRANSFER, DONE, FIN);
signal c_state, p_state			: states := IDLE;

-- ===== RTC Register ===== --
signal Reg0000                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- SYSTEM
signal Reg0001                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- MODE
signal Reg0002                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- Voltage control
signal Reg0003                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- START SIGNAL
signal Reg0004                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- DONE SIGNAL
signal Reg0005                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- HW Switch
signal Reg0006                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- pos D.P
signal Reg0007                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- neg D.P
signal Reg0f0f                  : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";        -- single write test

--===== SIGNALS =====--
-- POWER --
signal s_SW_RESET          	: std_logic;
signal s_power_ON			: std_logic := '1';

signal s_Data_Bus_RD		: std_logic_vector(15 downto 0);
-- STATE --
signal s_IDLE_MODE			: std_logic := '0';
signal s_INIT_MODE			: std_logic := '0';
signal s_REG_SET_MODE		: std_logic := '0';
signal s_TRETMENT_MODE		: std_logic := '0';
signal s_SCAN_MODE	  		: std_logic := '0';
signal s_RECEIVE_MODE		: std_logic := '0';
signal s_TRANSFER_MODE		: std_logic := '0';
signal s_DONE_MODE			: std_logic := '0';
signal s_FIN_MODE			: std_logic := '0';

signal s_FPGA_power_cnt		: std_logic_vector(31 downto 0);
signal s_set_done			: std_logic;
signal s_set_start			: std_logic;
-- Address decoder --
signal s_RTC                : std_logic := '0';
signal s_TxPG_T             : std_logic := '0';
signal s_TxPG_D             : std_logic := '0';
signal s_RxBF               : std_logic := '0';
signal s_USB                : std_logic := '0';
-- Start signal --
signal s_T_start            : std_logic := '0';
signal s_S_start            : std_logic := '0';
signal s_D_start            : std_logic := '0';
signal s_R_start            : std_logic := '0';
signal s_TR_start           : std_logic := '0';
signal s_system_done		: std_logic := '0';
signal s_IP_data 			: std_logic_vector(15 downto 0);

component Address_Decoder is
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
end component;

component  Voltage_Controller is
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
end component;

--
---
begin
---
--

Addr : Address_Decoder
Port map( 
	--===== INPUT =====--
	m_Address_Bus_RTC		=> m_Address_Bus(15 downto 12),
	
	--===== OUTPUT =====--
	m_RTC                   => s_RTC,
	m_TxPG_T                => s_TxPG_T,
	m_TxPG_D                => s_TxPG_D,
	m_RxBF                  => s_RxBF,
	m_USB                   => s_USB
);

V_Ctrl : Voltage_Controller
Port map( 
	--===== INPUT =====--
	-- CLOCK --
	-- CLOCK --
	m_sys_clk_40M			=> m_sys_clk_40M,	
	-- State --
	m_T_start		        => s_T_start,
	m_D_start		        => s_D_start,
	m_T_done		        => m_T_done,
	m_D_done	            => m_D_done,
	
	--===== OUTPUT =====--
	-- Pulser Voltage CONTROL 
	m_3V3ND_Ctrl			=> m_3V3ND_Ctrl,
	m_Pulser_3V3_Ctrl		=> m_Pulser_3V3_Ctrl,
	-- HV CONTROL --
	m_HV_40VP_EN			=> m_HV_40VP_EN,
	m_HV_80VP_EN            => m_HV_80VP_EN,
	m_HV_40VN_EN            => m_HV_40VN_EN,
	m_HV_80VN_EN            => m_HV_80VN_EN,
	m_HV_80_VIN_CTRL		=> m_HV_80_VIN_CTRL,
	-- HV Drop CONTROL --
	m_HV_DROP_pos           => m_HV_DROP_pos, 
	m_HV_DROP_neg           => m_HV_DROP_neg        
);


--========== STATE MACHINE ==========--
s_IDLE_MODE			  	<= '1' when c_state = IDLE 			else '0';
s_INIT_MODE			  	<= '1' when c_state = INIT 			else '0';
s_REG_SET_MODE		  	<= '1' when c_state = REG_SET		else '0';
s_TRETMENT_MODE		  	<= '1' when c_state = TREATMENT 	else '0';
s_SCAN_MODE	  			<= '1' when c_state = SCAN 			else '0';
s_RECEIVE_MODE		  	<= '1' when c_state = RECEIVE  		else '0';
s_TRANSFER_MODE	  		<= '1' when c_state = TRANSFER 		else '0';
s_DONE_MODE		      	<= '1' when c_state = DONE 			else '0';
s_FIN_MODE		      	<= '1' when c_state = FIN 			else '0';

ptoc_state : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		p_state 				<= c_state;
	end if;
end process;

state_machine : process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		case c_state is
			when IDLE =>
				if s_power_ON = '1' then		-- FPGA BIT올라와있으면 INIT으로 넘어가게해라
					c_state	<= INIT;
				end if;
			when INIT =>
				c_state	<= REG_SET;
			when REG_SET =>
				if s_T_start = '1' then
					c_state	<= TREATMENT;
				elsif s_D_start = '1' then
					c_state	<= SCAN;		
				elsif s_system_done = '1' then
					c_state	<= FIN;					
				end if;
			when TREATMENT =>
				if m_T_done = '1' then
					c_state	<= DONE;
				end if;
			when SCAN =>
				if m_S_done = '1' then
					c_state	<= RECEIVE;
				end if;
			when RECEIVE =>
				if m_R_done = '1' then
					c_state	<= TRANSFER;
				end if;
			when TRANSFER =>
				if m_TR_done = '1' then
					c_state	<= SCAN;
				elsif m_D_done = '1' then
					c_state	<= DONE;
				end if;
			when DONE =>
				c_state	<= REG_SET;
			when FIN =>
				
			when others =>
				c_state	<= IDLE;
		end case;
	end if;
end process;

--========== Software RESET ==========--
SW_reset : process(m_sys_clk_40M)
begin
	if c_state = INIT then
		s_SW_RESET		<= '1';
	else
		s_SW_RESET		<= '0';
	end if;
end process;

--========== POWER ON/OFF SWITCH ==========--
Power_Switch : process(m_sys_clk_40M)
begin 
	if rising_edge(m_sys_clk_40M) then
		if s_FPGA_power_cnt = x"04C4B400" then
			s_power_ON		<= '0';
		end if;
	end if;
end process;

power_off_cnt : process(m_sys_clk_40M)
begin 
	if rising_edge(m_sys_clk_40M) then
		if m_power_OFF = '1' then
			s_FPGA_power_cnt <= s_FPGA_power_cnt + '1';
		else 
			s_FPGA_power_cnt <= (others =>'0');
		end if;
	end if;
end process;

--===== INPUT to REG =====--
process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if s_RTC = '1' and m_USB_WEN = '1' then
			if 		m_Address_Bus = x"0000" then Reg0000		<= m_Data_Bus_WR;
			elsif 	m_Address_Bus = x"0002" then Reg0002   		<= m_Data_Bus_WR;
			elsif 	m_Address_Bus = x"0003" then Reg0003   		<= m_Data_Bus_WR;
			--elsif 	m_Address_Bus = x"0004" then Reg0004   		<= m_Data_Bus_WR;
			elsif 	m_Address_Bus = x"0006" then Reg0006   		<= m_Data_Bus_WR;
			elsif 	m_Address_Bus = x"0007" then Reg0007   		<= m_Data_Bus_WR;
			--single write test--
			elsif 	m_Address_Bus = x"0f0f" then Reg0f0f 		<= m_Data_Bus_WR;
			end if;
			
			if 	c_state = IDLE			then Reg0001(0)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = INIT			then Reg0001(1)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = REG_SET		then Reg0001(2)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = TREATMENT		then Reg0001(3)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = SCAN			then Reg0001(4)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = RECEIVE		then Reg0001(5)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = TRANSFER		then Reg0001(6)		<= '1'; 	else Reg0001(0)	<= '0'; end if;
			if 	c_state = DONE			then Reg0001(7)		<= '1'; 	else Reg0001(0)	<= '0'; end if;						
		end if;	

	end if;	
		 
		Reg0005(0)		<= m_MODE_SWITCH;
		Reg0005(1)		<= m_SELECT_SWITCH;

end process;

--===== REG to Signal =====--
s_T_start          <= '1' 			when Reg0003(1) = '1' and m_USB_WEN = '1'	else '0';
--s_S_start          <= '1';		    when (Reg0003(2) = '1' and m_USB_WEN = '1') or m_R_done = '1' else '0';
s_D_start          <= '1' 			when Reg0003(3) = '1' and m_USB_WEN = '1'	else '0';
--s_R_start          <= '1';		    when (Reg0003(4) = '1' and m_USB_WEN = '1') or m_S_done = '1' else '0';
--s_TR_start         <= '1';		    when Reg0003(5) = '1' and m_USB_WEN = '1' else '0';
s_system_done      <= '1' 			when Reg0000(1) = '1' and m_USB_WEN = '1'	else '0';

--===== Signal to REG =====--
process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if 	s_set_done  = '1' then Reg0004(0)      <= '1'; else Reg0004(0)      <= '0'; end if;
		if  m_T_done  	= '1' then Reg0004(1)      <= '1'; else Reg0004(1)      <= '0'; end if;
		if 	m_S_done  	= '1' then Reg0004(2)      <= '1'; else Reg0004(2)      <= '0'; end if;
		if  m_D_done  	= '1' then Reg0004(3)      <= '1'; else Reg0004(3)      <= '0'; end if;
		if  m_R_done  	= '1' then Reg0004(4)      <= '1'; else Reg0004(4)      <= '0'; end if;
		if  m_TR_done 	= '1' then Reg0004(5)      <= '1'; else Reg0004(5)      <= '0'; end if;		
	end if;
end process;


----===== REG to OUTPUT =====-- READ할때 할것.
process(m_sys_clk_40M)
begin
	if rising_edge(m_sys_clk_40M) then
		if m_USB_REN = '1' and s_RTC = '1' then
			if m_Address_Bus = x"0000" then  m_Data_Bus_RD	<= REG0000;  
			elsif m_Address_Bus = x"0001" then  m_Data_Bus_RD	<= REG0001;  
			elsif m_Address_Bus = x"0002" then  m_Data_Bus_RD	<= REG0002;  
			elsif m_Address_Bus = x"0f0f" then  m_Data_Bus_RD	<= REG0f0f;  
			elsif m_Address_Bus = x"0004" then  m_Data_Bus_RD	<= REG0004;  
			elsif m_Address_Bus = x"0005" then  m_Data_Bus_RD	<= REG0005;  
			elsif m_Address_Bus = x"0006" then  m_Data_Bus_RD	<= REG0006;  
			elsif m_Address_Bus = x"0007" then  m_Data_Bus_RD	<= REG0007;	
			else m_Data_Bus_RD <= (others => 'Z');
			end if;
		end if;
	end if;
end process;

--========== OUTPUT LOGIC ==========--
m_SW_RESET 				<= s_SW_RESET;
m_power_ON				<= s_power_ON;


m_IDLE_MODE				<= s_IDLE_MODE;
m_INIT_MODE				<= s_INIT_MODE;
m_REG_SET_MODE			<= s_REG_SET_MODE;
m_TRETMENT_MODE			<= s_TRETMENT_MODE;
m_SCAN_MODE	  			<= s_SCAN_MODE;
m_RECEIVE_MODE			<= s_RECEIVE_MODE;
m_TRANSFER_MODE			<= s_TRANSFER_MODE;
m_DONE_MODE				<= s_DONE_MODE;
m_FIN_MODE				<= s_FIN_MODE;

m_T_start 				<= s_T_start;
m_S_start 				<= s_S_start;
m_D_start 				<= s_D_start;
m_R_start 				<= s_R_start;
m_TR_start				<= s_TR_start;

m_TxPG_valid			<= '1' when s_TxPG_T = '1' or s_TxPG_D = '1' 	else '0';
m_RxBF_valid  			<= '1' when s_RxBF = '1' 						else '0';
m_USB_valid   			<= '1' when s_USB = '1' 						else '0';


-- Digital Potentiometer Control --
--m_I2C_SCL               <= "ZZ";
--m_I2C_SDA               <= "ZZ";


--m_reg0f0f_data			<= Reg0f0f;
m_IP_data				<= s_IP_data;

m_RTC   				<= s_RTC   ;
m_TxPG_T				<= s_TxPG_T;
m_TxPG_D				<= s_TxPG_D;
m_RxBF  				<= s_RxBF  ;
m_USB   				<= s_USB   ;

end Behavioral;
