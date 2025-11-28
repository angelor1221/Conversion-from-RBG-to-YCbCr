library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux8para1_tb is
end entity;

architecture testbench of mux8para1_tb is
    constant N_BITS : positive := 8;
    constant PERIOD : time     := 10 ns;

    signal sel : std_logic_vector(2 downto 0) := "000";

    signal e0, e1, e2, e3, e4, e5, e6, e7 : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    signal y                              : std_logic_vector(N_BITS-1 downto 0);

begin

    DUT: entity work.mux8para1
        generic map (
            N => N_BITS
        )
        port map (
            sel => sel,
            e0 => e0, e1 => e1, e2 => e2, e3 => e3,
            e4 => e4, e5 => e5, e6 => e6, e7 => e7,
            y  => y
        );

    stimulus: process
    begin
        report "Iniciando a simulacao do Mux 8:1";

        e0 <= "00000000";
        e1 <= "00000001";
        e2 <= "00000010";
        e3 <= "00000011";
        e4 <= "00000100";
        e5 <= "00000101";
        e6 <= "00000110";
        e7 <= "00000111";

        sel <= "000";
        wait for PERIOD;
        assert (y = "00000000") 
            report "Erro no sel 000: Saida deveria ser 0" severity error;

        sel <= "001";
        wait for PERIOD;
        assert (y = "00000001") 
            report "Erro no sel 001: Saida deveria ser 1" severity error;

        sel <= "010";
        wait for PERIOD;
        assert (y = "00000010") 
            report "Erro no sel 010: Saida deveria ser 2" severity error;

        sel <= "011";
        wait for PERIOD;
        assert (y = "00000011") 
            report "Erro no sel 011: Saida deveria ser 3" severity error;

        sel <= "100";
        wait for PERIOD;
        assert (y = "00000100") 
            report "Erro no sel 100: Saida deveria ser 4" severity error;

        sel <= "101";
        wait for PERIOD;
        assert (y = "00000101") 
            report "Erro no sel 101: Saida deveria ser 5" severity error;

        sel <= "110";
        wait for PERIOD;
        assert (y = "00000110") 
            report "Erro no sel 110: Saida deveria ser 6" severity error;

        sel <= "111";
        wait for PERIOD;
        assert (y = "00000111") 
            report "Erro no sel 111: Saida deveria ser 7" severity error;

        report "Teste Dinamico: Mudando e7 com sel='111'";
        e7 <= "11111111";
        wait for PERIOD;
        assert (y = "11111111") 
            report "Erro Dinamico: Saida nao acompanhou a mudanca de e7" severity error;

        -- Finalização
        assert false report "Simulacao concluida com sucesso!" severity note;
        wait;

    end process;

end architecture;
