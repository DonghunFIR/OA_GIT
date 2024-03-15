----------------------------------------------------------------------------------
-- Company: FIR LAB
-- Engineer: MINSU KANG
-- 
-- Create Date: 2023/12/28 22:53:51
-- Design Name: 
-- Module Name: Firing_Treatment - Behavioral
-- Project Name: OA Project
-- Target Devices: XC7A200T-1FBG676C
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

entity Firing_Treatment is
	Port ( 
		--===== INPUT =====--
		-- CLOCK --
		m_sys_clk_160M			: in std_logic;							-- 1clk = 6.25ns
		-- CONTROL --		
		m_Tx_start				: in std_logic;
		m_apo					: in std_logic;
		m_CW					: in std_logic;							-- 1 : Treatment / 0 : Scan
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
end Firing_Treatment;

architecture Behavioral of Firing_Treatment is
type states is (IDLE, FIRE_DELAY, PCH_PRE, PCH_ACTIVE, PCH_POST, NCH_PRE, NCH_ACTIVE, NCH_POST, DONE);
signal c_state, p_state			: states := IDLE;

signal s_fire_delay_cnt			: std_logic_vector(15 downto 0);
signal s_pch_pre_cnt			: std_logic_vector(15 downto 0);
signal s_pch_active_cnt         : std_logic_vector(15 downto 0);
signal s_pch_post_cnt           : std_logic_vector(15 downto 0);
signal s_nch_pre_cnt	        : std_logic_vector(15 downto 0);
signal s_nch_active_cnt         : std_logic_vector(15 downto 0);
signal s_nch_post_cnt           : std_logic_vector(15 downto 0);
signal s_burst_cnt				: std_logic_vector(31 downto 0);
signal s_repeat_cnt				: std_logic_vector(31 downto 0);
signal s_PRI_cnt				: std_logic_vector(31 downto 0);

signal s_pulser_out				: std_logic_vector(1 downto 0);
signal s_Tx_ing					: std_logic;
signal s_PRI_done				: std_logic;
signal s_Tx_done				: std_logic;
signal s_process_done			: std_logic;

--
---
begin
---
--

--========== STATE MACHINE ==========--
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		p_state 				<= c_state;
	end if;
end process;

process(m_sys_clk_160M)
begin
	if s_process_done = '1' then
					c_state 			<= IDLE;
	elsif rising_edge(m_sys_clk_160M) then
		case c_state is
			when IDLE =>
				if m_Tx_start = '1' and m_THSD = '1' then					 --m_fire_delay /= 0 이 조건이 꼭 필요한가?
					c_state			<= FIRE_DELAY;
				end if;
			when FIRE_DELAY =>
				if s_fire_delay_cnt = m_fire_delay then
					if m_pch_duty_pre = x"00" then
						c_state			<= PCH_ACTIVE;
					else
						c_state			<= PCH_PRE;
					end if;
				end if;
			when PCH_PRE =>
				if s_pch_pre_cnt = m_pch_duty_pre then
					c_state			<= PCH_ACTIVE;
				end if;
			when PCH_ACTIVE =>
				if s_pch_active_cnt = m_pch_duty_active then
					if s_burst_cnt = m_burst then
						c_state			<= DONE;
					elsif m_nch_duty_pre = x"0000" then
						c_state			<= NCH_ACTIVE;
					else
						c_state			<= PCH_POST;
					end if;
				end if;
			when PCH_POST =>
				if s_pch_post_cnt = m_pch_duty_post then
					c_state			<= NCH_PRE;
				elsif s_burst_cnt = m_burst then
					c_state			<= DONE;
				end if;
			when NCH_PRE =>
				if s_nch_pre_cnt = m_nch_duty_pre then
					c_state			<= NCH_ACTIVE;
				end if;
			when NCH_ACTIVE =>
				if s_nch_active_cnt = m_nch_duty_active then
					if s_burst_cnt = m_burst then
						c_state			<= DONE;
					elsif m_pch_duty_pre = x"0000" then
						c_state			<= PCH_ACTIVE;
					else
						c_state			<= NCH_POST;
					end if;
				end if;
			when NCH_POST =>
				if s_nch_post_cnt = m_nch_duty_post then
					c_state			<= PCH_PRE;
				elsif s_burst_cnt = m_burst then
					c_state			<= DONE;
				end if;
			when DONE =>
				if s_repeat_cnt /= m_repeat and s_PRI_done = '1' then
					c_state			<= FIRE_DELAY;
				elsif s_repeat_cnt = m_repeat and s_PRI_done = '1' then
					c_state			<= IDLE;					
				end if;
			when others =>
				c_state	<= IDLE;
		end case;
	end if;
end process;

--========== Counter ==========--
----- fire_delay_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = FIRE_DELAY then
			s_fire_delay_cnt <= s_fire_delay_cnt + 1;
		else
			s_fire_delay_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- pch_pre_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = PCH_PRE then
			s_pch_pre_cnt <= s_pch_pre_cnt + 1;
		else
			s_pch_pre_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- pch_active_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = PCH_ACTIVE then
			s_pch_active_cnt <= s_pch_active_cnt + 1;
		else
			s_pch_active_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- pch_post_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = PCH_POST then
			s_pch_post_cnt <= s_pch_post_cnt + 1;
		else
			s_pch_post_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- nch_pre_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = NCH_PRE then
			s_nch_pre_cnt <= s_nch_pre_cnt + 1;
		else
			s_nch_pre_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- nch_active_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = NCH_ACTIVE then
			s_nch_active_cnt <= s_nch_active_cnt + 1;
		else
			s_nch_active_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- nch_post_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = NCH_POST then
			s_nch_post_cnt <= s_nch_post_cnt + 1;
		else
			s_nch_post_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- burst_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if (p_state = PCH_POST and c_state = NCH_PRE) then
			s_burst_cnt <= s_burst_cnt + 1;	
		elsif (p_state = NCH_POST and c_state = PCH_PRE) then
			s_burst_cnt <= s_burst_cnt + 1;
		elsif (p_state = PCH_ACTIVE and c_state = NCH_ACTIVE) then
			s_burst_cnt <= s_burst_cnt + 1;
		elsif (p_state = NCH_ACTIVE and c_state = PCH_ACTIVE) then
			s_burst_cnt <= s_burst_cnt + 1;
		elsif c_state = FIRE_DELAY then
			s_burst_cnt <= (others => '0');
		end if;
	end if;
end process;

----- repeat_cnt -----
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if (p_state /= DONE and c_state = DONE) then
			s_repeat_cnt <= s_repeat_cnt + 1;
		elsif c_state = IDLE then
			s_repeat_cnt <= (others =>'0');
		end if;
	end if;
end process;

----- PRI_cnt -----
s_Tx_ing	<= '1' when c_state /= IDLE else '0';
process(m_sys_clk_160M)
begin
	if s_PRI_cnt = m_PRI then
		s_PRI_done	<= '1';
		s_PRI_cnt 	<= (others=>'0');
	elsif rising_edge(m_sys_clk_160M) then
		if s_Tx_ing = '1' then
			s_PRI_cnt 	<= s_PRI_cnt + 1;
			s_PRI_done 	<= '0';
		else
			s_PRI_cnt 	<= (others=>'0');
			s_PRI_done 	<= '0';
		end if;
	end if;
end process;



--========== OUTPUT ==========--
--========== IN0 IN1 OUTPUT ==========--
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if m_apo = '0' then					
			s_pulser_out 	<= "00";
		elsif m_CW = '0' then								-- 80V / Scan
			if c_state = DONE then			-- Receive
				s_pulser_out 	<= "11";
			elsif (p_state = PCH_ACTIVE) then
				if (m_polarity = '0') then
					s_pulser_out 	<= "10";
				else
					s_pulser_out 	<= "01";
				end if;
			elsif (p_state = NCH_ACTIVE) then
				if (m_polarity = '0') then
					s_pulser_out 	<= "01";
				else
					s_pulser_out 	<= "10";
				end if;
			else											-- clamp
				s_pulser_out 	<= "00";
			end if;
		elsif m_CW = '1' then								-- 40V / Treatment
			if (p_state = PCH_ACTIVE) then
				if (m_polarity = '0') then
					s_pulser_out 	<= "10";
				else
					s_pulser_out 	<= "01";
				end if;
			elsif (p_state = NCH_ACTIVE) then
				if (m_polarity = '0') then
					s_pulser_out 	<= "01";
				else
					s_pulser_out 	<= "10";
				end if;
			else										
				s_pulser_out 	<= "00";
			end if;
		else				
			s_pulser_out 	<= "00";
		end if;
	end if;
end process;

--===== Tx_done signal =====--
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if m_CW = '0' then								-- 80V / Scan
			if c_state = DONE and p_state /= DONE then
				s_Tx_done <= '1';
			elsif c_state = DONE and p_state = DONE then
				s_Tx_done <= '0';
			end if;
		elsif m_CW = '1' then									-- 40V / Treatment
			if c_state = DONE and s_repeat_cnt = m_repeat and s_PRI_done = '1' then
				s_Tx_done <= '1';
			--elsif c_state = IDLE then             -- done 신호가 너무 짧아서 일단 1로 올림
			--	s_Tx_done <= '0';                   
			end if;
		end if;
	end if;
end process;

--===== s_process_done =====--
process(m_sys_clk_160M)
begin
	if rising_edge(m_sys_clk_160M) then
		if c_state = DONE and s_repeat_cnt = m_repeat and s_PRI_done = '1' then --  (이 조건 추가되면 파형의 PRI 안기다리고 바로 끝)
			s_process_done <= '1';
		elsif c_state = IDLE then
			s_process_done <= '0';
		end if;
	end if;
end process;

m_in1 			<= s_pulser_out(0);
m_in0 			<= s_pulser_out(1);
m_Tx_done		<= s_Tx_done;

end Behavioral;
