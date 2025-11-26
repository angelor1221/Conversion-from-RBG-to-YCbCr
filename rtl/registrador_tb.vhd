library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador_tb is
end registrador_tb;

architecture tb of registrador_tb is
    CONSTANT N_BITS : natural := 8;
    CONSTANT period : TIME := 20 ns;

    signal clk          : std_logic := '0';
    signal ld           : std_logic := '0';
    signal input_value  : std_logic_vector(N_BITS-1 DOWNTO 0) := (others => '0');
    signal output_value : std_logic_vector(N_BITS-1 DOWNTO 0);
    
    signal finished     : std_logic := '0';

begin

    DUV: entity work.registrador_generico 
        generic map (
            N => N_BITS
        )
        port map (
            clk => clk,
            ld  => ld,
            d   => input_value,
            q   => output_value
        );

    clk <= not clk after period/2 when finished /= '1' else '0';

    process
    begin
        ld <= '0';
        input_value <= (others => '0');
        wait for period;

        input_value <= std_logic_vector(to_unsigned(10, N_BITS));
        wait for period; 

        ld <= '1';
        wait for period;
        ld <= '0';

        input_value <= std_logic_vector(to_unsigned(12, N_BITS));
        ld <= '1';
        wait for period; 
        ld <= '0';

        wait for 40 ns;
        finished <= '1';
        wait;
    end process;

end tb;
