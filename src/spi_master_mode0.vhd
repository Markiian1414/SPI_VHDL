----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Markiian Leno
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: spi_master_mode0 - Behavioral
-- Project Name: SPI_VHDL
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
   
entity spi_master_mode0 is
   Port (
      i_CLK : in STD_LOGIC;
      i_RST : in STD_LOGIC;
      i_enable : in STD_LOGIC;
      
      i_tx_data : in STD_LOGIC_VECTOR(7 downto 0);
      o_rx_data : out STD_LOGIC_VECTOR(7 downto 0);

      --Current: MODE 0 - CPOL = 0, CPHA = 0
      --MODE 2:0
      i_MISO : in STD_LOGIC;
      
      o_MOSI : out STD_LOGIC;
      o_nSS : out STD_LOGIC;
      o_SCLK : out STD_LOGIC;    
      o_busy : out STD_LOGIC
   );
end spi_master_mode0;


architecture Behavioral of spi_master_mode0 is
      constant c_CNT_CLK_DIV : natural := 10;
      
      signal r_CNT_CLK_DIV : natural range 0 to c_CNT_CLK_DIV - 1 := 0;
      signal r_SCLK : STD_LOGIC := '0';
      signal r_busy : STD_LOGIC := '0';
      signal r_MOSI : STD_LOGIC := '0';

      signal r_shift_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
      signal r_miso_sample_bit : STD_LOGIC := '0';
      signal r_bit_cnt : INTEGER range 0 to 7 := 0;

      type t_FSM_state is (
         IDLE,
         SETUP,
         TRANSFER,
         STOP
      );

      signal r_current_state : t_FSM_state := IDLE;

begin

   process(i_CLK, i_RST)
   begin
      if i_RST = '1' then
         r_CNT_CLK_DIV <= 0;
         r_SCLK <= '0';
         r_busy <= '0';
         r_MOSI <= '0';
         r_shift_reg <= (others => '0');
         r_miso_sample_bit <= '0';
         r_bit_cnt <= 0;

         o_nSS <= '1';
         o_rx_data <= (others => '0');

         r_current_state <= IDLE;
      elsif rising_edge(i_CLK) then
         
         case r_current_state is
            when IDLE =>
            if i_enable = '1' then --умова переходу в стан SETUP
               
               r_bit_cnt <= 0;
               r_CNT_CLK_DIV <= 0;

               r_shift_reg <= i_tx_data;        
               r_MOSI <= i_tx_data(7);

               r_busy <= '1';
               o_nSS <= '0';

               r_current_state <= SETUP;
            end if;

            when SETUP =>
            
            if r_CNT_CLK_DIV = c_CNT_CLK_DIV - 1 then
               
               
               r_miso_sample_bit <= i_MISO;

               r_SCLK <= not r_SCLK;
               r_CNT_CLK_DIV <= 0;
               
               r_current_state <= TRANSFER;
            else
               r_CNT_CLK_DIV <= r_CNT_CLK_DIV + 1;
               
            end if;

            when TRANSFER =>

            if r_CNT_CLK_DIV = c_CNT_CLK_DIV - 1 then
               
               if r_SCLK = '1' then
                  r_shift_reg <= r_shift_reg(6 downto 0) & r_miso_sample_bit;
                  
                  if r_bit_cnt = 7 then
                     r_MOSI <= '0';
                     r_current_state <= STOP;
                  else
                     r_MOSI <= r_shift_reg(6);
                     r_bit_cnt <= r_bit_cnt + 1;
                  end if;
               else
                  r_miso_sample_bit <= i_MISO;
               end if;

               r_SCLK <= not r_SCLK;
               r_CNT_CLK_DIV <= 0;

            else
               r_CNT_CLK_DIV <= r_CNT_CLK_DIV + 1;

            end if;

            when STOP =>

            if r_CNT_CLK_DIV = c_CNT_CLK_DIV - 1 then
               r_SCLK <= '0';
               r_MOSI <= '0';
               o_rx_data <= r_shift_reg;
               r_busy <= '0';
               o_nSS <= '1';
               r_current_state <= IDLE;
            else
               r_CNT_CLK_DIV <= r_CNT_CLK_DIV + 1;
            end if;

         end case;
      end if;
   end process;
   o_SCLK <= r_SCLK;
   o_MOSI <= r_MOSI;
   o_busy <= r_busy;

end Behavioral;