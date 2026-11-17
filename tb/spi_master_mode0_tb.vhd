----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2026 04:20:28 PM
-- Design Name: 
-- Module Name: spi_master_mode0_tb - Behavioral
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

entity spi_master_mode0_tb is
end spi_master_mode0_tb;

architecture Behavioral of spi_master_mode0_tb is
    constant c_CLK_PERIOD : time := 40 ns; --CLK = 25 MHz, 1 / 25 000 000 = 40 ns

    signal r_CLK : STD_LOGIC := '0';
    signal r_RST : STD_LOGIC := '0';
    signal r_enable : STD_LOGIC := '0';
    signal r_tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_MISO : STD_LOGIC := '0';
    signal w_MOSI : STD_LOGIC;
    signal w_nSS : STD_LOGIC;
    signal w_SCLK : STD_LOGIC;
    signal w_busy : STD_LOGIC;
    
    component spi_master_mode0 is
        Port (
            i_CLK : in STD_LOGIC;
            i_RST : in STD_LOGIC;
            i_enable : in STD_LOGIC;
            
            i_tx_data : in STD_LOGIC_VECTOR(7 downto 0);
            o_rx_data : out STD_LOGIC_VECTOR(7 downto 0);

            i_MISO : in STD_LOGIC;

            o_MOSI : out STD_LOGIC;
            o_nSS : out STD_LOGIC;
            o_SCLK : out STD_LOGIC;
            o_busy : out STD_LOGIC
        );
    end component spi_master_mode0;

begin
    UUT : spi_master_mode0
        port map (
            i_CLK => r_CLK,
            i_RST => r_RST,
            i_enable => r_enable,
            i_tx_data => r_tx_data,
            o_rx_data => r_rx_data,

            i_MISO => w_MISO,
            o_MOSI => w_MOSI,
            o_nSS => w_nSS,
            o_SCLK => w_SCLK,
            o_busy => w_busy

        );

        r_CLK <= not r_CLK after c_CLK_PERIOD / 2;
        
        process
            constant c_SLAVE_DATA : STD_LOGIC_VECTOR(7 downto 0) := "11001100";
        begin
            -- Reset the design
            r_RST <= '1';
            wait for 100 ns;
            r_RST <= '0';
            wait for 100 ns;

            -- Send data to the SPI master
            wait until rising_edge(r_CLK);
            r_tx_data <= "10101010";
            r_enable  <= '1';
            wait until rising_edge(r_CLK);
            r_enable  <= '0';

            -- Drive MSB immediately since w_nSS is already asserted low
            w_MISO <= c_SLAVE_DATA(7);

            -- Shift remaining 7 bits on falling edge of w_SCLK (Mode 0)
            for i in 6 downto 0 loop
                wait until falling_edge(w_SCLK);
                w_MISO <= c_SLAVE_DATA(i);
            end loop;
            
            -- Wait for the SPI master to finish receiving data
            wait until w_busy = '0';
            wait for 200 ns;
            
            -- Simulation finished
            assert false report "Simulation finished" severity failure;
            wait;
        end process;


end Behavioral;
