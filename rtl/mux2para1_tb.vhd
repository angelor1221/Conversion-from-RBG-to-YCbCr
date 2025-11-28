library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2para1_tb is
end entity;

architecture testbench of mux2para1_tb is
    constant N_BITS : positive := 8; 
    constant PERIOD : time     := 10 ns;

    signal sel      : std_logic := '0';
    signal e0, e1   : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    signal y        : std_logic_vector(N_BITS-1 downto 0);

begin

    DUT: entity work.mux2para1
        generic map (
            N => N_BITS
        )
        port map (
            sel => sel,
            e0  => e0,
            e1  => e1,
            y   => y
        );

    stimulus: process
    begin
      
        report "Iniciando Caso 1: sel = '0'";
        
        sel <= '0';
        e0  <= "00001010";
        e1  <= "00000101";
        wait for PERIOD;

        assert (y = "00001010") 
            report "Erro no Caso 1: Com sel='0', saida deveria ser 1010 mas foi " & to_string(y)
            severity error;

        report "Iniciando Caso 2: sel = '1'";

        sel <= '1';
        
        wait for PERIOD;

        assert (y = "00000101") 
            report "Erro no Caso 2: Com sel='1', saida deveria ser 0101 mas foi " & to_string(y)
            severity error;

        report "Iniciando Caso 3: Mudança de dados com sel='1'";

        e1 <= "11111111";
        
        wait for PERIOD;

        assert (y = "11111111") 
            report "Erro no Caso 3: Saída não acompanhou mudança de e1"
            severity error;

        assert false report "Fim da simulação. Testes concluídos." severity note;
        wait;

    end process;

end architecture;
