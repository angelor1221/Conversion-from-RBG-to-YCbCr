library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador_tb is
end somador_tb;

architecture tb of somador_tb is

    constant N_BITS : positive := 8;
    constant passo  : time := 20 ns;

    signal s_x : std_logic_vector(N_BITS-1 downto 0);
    signal s_y : std_logic_vector(N_BITS-1 downto 0);
    signal s_r : std_logic_vector(N_BITS-1 downto 0);

begin

    duv: entity work.somador
        generic map (
            N => N_BITS
        )
        port map (
            x => s_x,
            y => s_y,
            r => s_r
        );

    p_test: process
    begin
        s_x <= "00000000"; 
        s_y <= "00000000";
        wait for passo;
        assert (s_r = "00000000")
            report "Falha no teste 0 (0+0)" severity error;

        s_x <= "00000001";
        s_y <= "00000010";
        wait for passo;
        assert (s_r = "00000011")
            report "Falha no teste 1 (1+2)" severity error;

        s_x <= "00001000";
        s_y <= "00000100";
        wait for passo;
        assert (s_r = "00001100")
            report "Falha no teste 2 (8+4)" severity error;

        s_x <= "11111111"; 
        s_y <= "00000001";
        wait for passo;
        assert (s_r = "00000000") 
            report "Falha no teste 3 (-1+1)" severity error;

        wait for passo;
        assert false report "Testes concluidos." severity note;
        wait;
    end process;

end tb;
