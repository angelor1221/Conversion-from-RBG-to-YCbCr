library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador_tb is
end entity;

architecture testbench of somador_tb is
    constant N_BITS : positive := 8;
    constant PERIOD : time     := 10 ns;

    signal x, y : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    signal r    : std_logic_vector(N_BITS-1 downto 0);

begin

    DUT: entity work.somador
        generic map (
            N => N_BITS
        )
        port map (
            x => x,
            y => y,
            r => r
        );

    stimulus: process
    begin
        report "Iniciando simulacao do Somador Signed (8 bits)";


        -- teste 1
        x <= std_logic_vector(to_signed(10, N_BITS)); 
        y <= std_logic_vector(to_signed(5, N_BITS));
        
        wait for PERIOD;

        assert (signed(r) = 15)
            report "Erro Caso 1: 10 + 5 deveria ser 15" severity error;

        -- teste 2
        x <= std_logic_vector(to_signed(20, N_BITS));
        y <= std_logic_vector(to_signed(-30, N_BITS));

        wait for PERIOD;

        assert (signed(r) = -10)
            report "Erro Caso 2: 20 + (-30) deveria ser -10" severity error;

        -- teste 3
        x <= "11111011"; 
        y <= "11111011";

        wait for PERIOD;

        assert (r = "11110110") 
            report "Erro Caso 3: (-5) + (-5) binario falhou" severity error;

        -- teste 4
        x <= std_logic_vector(to_signed(127, N_BITS));
        y <= std_logic_vector(to_signed(1, N_BITS));

        wait for PERIOD;
        assert (signed(r) = -128)
            report "Erro Caso 4: Overflow de 127+1 nao resultou em -128" severity error;

        -- Finalização
        assert false report "Simulacao concluida com sucesso." severity note;
        wait;

    end process;

end architecture;
