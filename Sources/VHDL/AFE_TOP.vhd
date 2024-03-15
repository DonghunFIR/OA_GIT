----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/03/04 10:21:54
-- Design Name: 
-- Module Name: AFE_TOP - Behavioral
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

entity AFE_TOP is
Port(
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M     		: in std_logic;
	m_SPI_clk_10M     		: in std_logic;
	-- EN signal --
	m_RxBF_valid       		: in std_logic;
	m_wen         			: in std_logic;
	m_ren       			: in std_logic;
	-- Addr & Data --
	m_ADDR         			: in std_logic_vector(11 downto 0);
	m_DATA         			: in std_logic_vector(15 downto 0);
	-- SPI --
	m_sdout_SPI    			: in std_logic_vector(3 downto 0);
	
	--===== OUTPUT =====--
	-- SPI --
	m_sclk_SPI      		: out std_logic_vector(3 downto 0);
	m_sen_SPI       		: out std_logic_vector(3 downto 0);
	m_sdin_SPI      		: out std_logic_vector(3 downto 0);
	-- Control signal --
	m_reset_SPI_out 		: out std_logic_vector(3 downto 0);
	m_done_SPI      		: out std_logic_vector(3 downto 0);
	-- SPI DATA --
	m_RDATA         		: out std_logic_vector(15 downto 0)
);
end AFE_TOP;

architecture Behavioral of AFE_TOP is

signal s_RDATA		: std_16bit_array(3 downto 0);


component AFE_SPI is 
Port ( 
	--===== INPUT =====--
	-- CLOCK --
	m_sys_clk_40M			: in std_logic;
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
end component;

--
---
begin
---
--
AFE_Channel : for i in 0 to 3 generate
AFE : AFE_SPI
port map( 
	--===== INPUT =====--
    -- CLOCK --
    m_sys_clk_40M			=> m_sys_clk_40M,
    m_SPI_clk_10M			=> m_SPI_clk_10M,
    -- EN signal --
    m_RxBF_valid			=> m_RxBF_valid,
    m_wen					=> m_wen,
    m_ren       			=> m_ren,
    -- Addr & Data --
    m_ADDR					=> m_ADDR,
    m_DATA					=> m_DATA,
    -- SPI --
    m_sdout_SPI				=> m_sdout_SPI(i),
    
    --===== OUTPUT =====--
    -- SPI --
    m_sclk_SPI				=> m_sclk_SPI(i),
    m_sen_SPI				=> m_sen_SPI(i),
    m_sdin_SPI				=> m_sdin_SPI(i),
    -- Control signal --
    m_reset_SPI_out			=> m_reset_SPI_out(i),
    m_done_SPI				=> m_done_SPI(i),
    -- SPI DATA --
    m_RDATA         		=> s_RDATA(i)
);
end generate;


m_RDATA		<= s_RDATA(0);

end Behavioral;
