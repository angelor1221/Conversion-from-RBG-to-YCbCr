library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.conversor_pkg.all;

entity conversor_tb is
end entity tb_conversor_top;

architecture behavior of conversor_tb is

    -- 1. Definição de Constantes e Sinais
    constant N_BITS   : integer := 8;
    constant CLK_PERIOD : time := 10 ns; -- Define a velocidade do clock

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal start   : std_logic := '0';
    signal lido    : std_logic := '0';
    signal sel     : std_logic := '0'; -- 0 = BT.709, 1 = BT.2020
    signal ready   : std_logic;

    signal R_in    : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    signal G_in    : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    signal B_in    : std_logic_vector(N_BITS-1 downto 0) := (others => '0');

    signal Y_out   : std_logic_vector(N_BITS-1 downto 0);
    signal Cb_out  : std_logic_vector(N_BITS-1 downto 0);
    signal Cr_out  : std_logic_vector(N_BITS-1 downto 0);

begin

    DUT: entity work.conversor_top
        generic map (
            N => N_BITS
        )
        port map (
            clk     => clk,
            reset   => reset,
            start   => start,
            lido    => lido,
            sel     => sel,
            ready   => ready,
            R       => R_in,
            G       => G_in,
            B       => B_in,
            Y       => Y_out,
            Cb      => Cb_out,
            Cr      => Cr_out
        );

    -- Processo de Geração de Clock 
    process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 4. Processo de Estímulos e Verificação
    process
        
        -- Procedimento auxiliar para aplicar inputs e verificar outputs
        -- Isso torna o teste mais limpo e organizado.
        procedure verificar_caso (
            desc_teste : string;
            val_sel : std_logic;
            val_r, val_g, val_b : integer;
            exp_y, exp_cb, exp_cr : integer;
            margem_erro : integer := 1 -- Tolerância de +/- 1 bit devido a arredondamentos
        ) is
        begin
            -- Aplica Entradas
            sel <= val_sel;
            R_in <= std_logic_vector(to_unsigned(val_r, N_BITS));
            G_in <= std_logic_vector(to_unsigned(val_g, N_BITS));
            B_in <= std_logic_vector(to_unsigned(val_b, N_BITS));
            
            -- Inicia processamento
            wait for CLK_PERIOD;
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';
            
            -- Espera o hardware sinalizar que terminou (ready = '1')
            wait until ready = '1';
            wait for CLK_PERIOD;

            -- Verificação Automática (Self-Check)
            -- Verifica Y
            assert abs(to_integer(unsigned(Y_out)) - exp_y) <= margem_erro
                report "FALHA no teste " & desc_teste & ": Y incorreto. " &
                       "Esperado: " & integer'image(exp_y) & 
                       " Obtido: " & integer'image(to_integer(unsigned(Y_out)))
                severity error; -- [cite: 1475]

            -- Verifica Cb
            assert abs(to_integer(unsigned(Cb_out)) - exp_cb) <= margem_erro
                report "FALHA no teste " & desc_teste & ": Cb incorreto. " &
                       "Esperado: " & integer'image(exp_cb) & 
                       " Obtido: " & integer'image(to_integer(unsigned(Cb_out)))
                severity error;

            -- Verifica Cr
            assert abs(to_integer(unsigned(Cr_out)) - exp_cr) <= margem_erro
                report "FALHA no teste " & desc_teste & ": Cr incorreto. " &
                       "Esperado: " & integer'image(exp_cr) & 
                       " Obtido: " & integer'image(to_integer(unsigned(Cr_out)))
                severity error;
            
            -- Handshake de leitura (se seu controle esperar isso)
            lido <= '1';
            wait for CLK_PERIOD;
            lido <= '0';
            wait for CLK_PERIOD*2; -- Tempo entre testes

        end procedure;

    begin
        -- Reset Inicial
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "--- INICIANDO SIMULACAO AUTOMATICA ---" severity note;

        -- CASO 1: Preto (BT.709)
        -- Entrada: 0, 0, 0 -> Saída Esperada: Y=0, Cb=128, Cr=128
        verificar_caso("Preto Absoluto", '0', 0, 0, 0, 0, 128, 128);

        -- CASO 2: Branco (BT.709)
        -- Entrada: 255, 255, 255 -> Saída Esperada: Y=255, Cb=128, Cr=128
        -- (Nota: Dependendo dos coeficientes exatos, pode variar +/- 1)
        verificar_caso("Branco Absoluto", '0', 255, 255, 255, 255, 128, 128);

        -- CASO 3: Verde Puro (BT.709)
        -- Coeficientes BT.709 aprox: Y=0.7152*G, Cb=-0.385*G + 128, Cr=-0.454*G + 128
        -- Entrada: 0, 255, 0 
        -- Y  = 182
        -- Cb = -98 + 128 = 30
        -- Cr = -116 + 128 = 12
        verificar_caso("Verde Puro (BT.709)", '0', 0, 255, 0, 182, 30, 12);

        -- CASO 4: Azul Puro (BT.709)
        -- Entrada: 0, 0, 255
        -- Y  = 0.0722 * 255 = 18
        -- Cb = 0.5 * 255 + 128 = 127 + 128 = 255
        -- Cr = -0.046 * 255 + 128 = -12 + 128 = 116
        verificar_caso("Azul Puro (BT.709)", '0', 0, 0, 255, 18, 255, 116);
        
        -- Finalização do Teste
        report "--- FIM DA SIMULACAO: Se nenhuma falha apareceu acima, SUCESSO! ---" severity note; [cite: 1788]
        wait; -- Para a simulação indefinidamente

    end process;

end architecture behavior;
