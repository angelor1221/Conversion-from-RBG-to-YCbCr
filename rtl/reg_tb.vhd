library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity registrador_tb is
end registrador_tb;

architecture tb of registrador_tb is
  CONSTANT N_BITS : natural := 8;
  signal clk : std_logic := '0';
  signal input_value: std_logic_vector(N_BITS-1 DOWNTO 0);
  signal output_value: std_logic_vector(N_BITS-1 DOWNTO 0);
  signal finished: std_logic := '0';
 
  CONSTANT period : TIME := 20 ns;
begin
 
DUV: entity work.registrador
  generic map(N => N_BITS)
  port map(clk=>clk, D => input_value, Q => output_value);

  clk <= not clk after period/2 when finished /= '1' else '0';
  
  process
  begin
    output_value <= std_logic_vector(to_unsigned(10, input_value'length));
    wait for 40 ns;
    output_value <= std_logic_vector(to_unsigned(12, input_value'length));
    wait for 40 ns;
    finished <= '1';
    wait;
 end process;
 
end tb;
