----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/02/01 23:15:49
-- Design Name: 
-- Module Name: AFE_SPI - Behavioral
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

entity AFE_SPI is
Port ( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M			: in std_logic; --40MHz single
	m_SPI_clk_10M			: in std_logic;
	-- EN signal --
	m_RxBF_valid			: in std_logic;
	m_wen					: in std_logic;
	m_ren       			: in std_logic;
	-- Addr & Data --
	m_ADDR					: in std_logic_vector(11 downto 0);
	m_DATA					: in std_logic_vector(15 downto 0);
	-- SPI --
	m_sdout_SPI				: in std_logic;
	
	--===== OUTPUT =====--
	-- SPI --
	m_sclk_SPI				: out std_logic;
	m_sen_SPI				: out std_logic;
	m_sdin_SPI				: out std_logic;
	-- Control signal --
	m_reset_SPI_out			: out std_logic;
	m_done_SPI				: out std_logic;
	-- SPI DATA --
	m_RDATA         		: out std_logic_vector(15 downto 0)
);
end AFE_SPI;

architecture Behavioral of AFE_SPI is


signal s_data_SPI	:  std_logic_vector(23 downto 0);
signal s_start_SPI  :  std_logic;
signal s_reset_SPI  :  std_logic;
signal s_data_read_SPI : std_logic_vector(15 downto 0);
signal s_RDATA		: std_logic_vector(15 downto 0);


component SPI_register is
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
end component;

component SPI_interface is 
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
end component;
  
--
---
begin
---
--
 
REG : SPI_register 
port map(
	--===== INPUT =====--
    -- CLOCK --
    m_sys_clk_40M			=> m_sys_clk_40M,
    -- EN signal --
    m_RxBF_valid			=> m_RxBF_valid,
    m_wen					=> m_wen,
    m_ren					=> m_ren,
    -- Addr & Data --
    m_ADDR					=> m_ADDR,
    m_DATA					=> m_DATA,
    --m_data_READ 			=> s_data_read_SPI,	

    --===== OUTPUT =====--
    -- Data --
    m_data_SPI				=> s_data_SPI,
    -- Control signal --
    m_start_SPI				=> s_start_SPI,
    m_reset_SPI				=> s_reset_SPI
    --m_RDATA     			=> m_RDATA
);

SPI : SPI_interface 
port map( 
	--===== INPUT =====--
    -- CLOCK --
    m_SPI_clk_10M			=> m_SPI_clk_10M,
    -- SPI --
    m_sdout_SPI				=> m_sdout_SPI,
    -- Control signal --	
    m_start_SPI 			=> s_start_SPI,
    m_reset_SPI				=> s_reset_SPI,
    -- SPI DATA --
    m_data_SPI				=> s_data_SPI,
    
    --===== OUTPUT =====--
    -- SPI --
    m_sclk_SPI				=> m_sclk_SPI,
    m_sen_SPI				=> m_sen_SPI,
    m_sdin_SPI				=> m_sdin_SPI,
    -- Control signal --
    m_reset_SPI_out			=> m_reset_SPI_out,
    m_done_SPI				=> m_done_SPI,
    -- SPI DATA --
    m_data_read_SPI			=> s_RDATA
);



m_RDATA <= s_RDATA when m_ren = '1' and m_RxBF_valid = '1' else (others => 'Z');


--process(m_sys_clk_40M)
--begin
--	if rising_edge(m_sys_clk_40M) then
--		if m_ren = '1' and m_RxBF_valid = '1' then
--			m_RDATA <= s_RDATA;
--		end if;
--	end if;
--end process;

end Behavioral;
 