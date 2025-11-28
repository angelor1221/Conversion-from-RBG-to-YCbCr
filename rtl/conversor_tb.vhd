library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.conversor_pkg.all;

entity conversor_tb is
end entity;

architecture testbench of conversor_tb is
    
    constant CLK_PERIOD : time := 10 ns;

    constant N8 : positive := 8;
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    
    signal s8_R, s8_G, s8_B    : std_logic_vector(N8-1 downto 0) := (others => '0');
    signal s8_sel, s8_lido, s8_start : std_logic := '0';
    signal s8_Y, s8_Cb, s8_Cr  : std_logic_vector(N8-1 downto 0);
    signal s8_ready            : std_logic;

    constant N10 : positive := 10;
    
    signal s10_R, s10_G, s10_B   : std_logic_vector(N10-1 downto 0) := (others => '0');
    signal s10_sel, s10_lido, s10_start : std_logic := '0';
    signal s10_Y, s10_Cb, s10_Cr : std_logic_vector(N10-1 downto 0);
    signal s10_ready             : std_logic;

    function calc_term(val : integer; coef : integer) return integer is
    begin
        return (val * coef) / 1024;
    end function;

    function saturate(val : integer; n_bits : integer) return integer is
        variable max_val : integer := (2**n_bits) - 1;
    begin
        if val < 0 then return 0;
        elsif val > max_val then return max_val;
        else return val;
        end if;
    end function;

begin

    clk <= not clk after CLK_PERIOD / 2;

    DUT_8: entity work.conversor
        generic map (N => N8)
        port map (
            clk => clk, reset => reset, start => s8_start, lido => s8_lido,
            sel => s8_sel, R => s8_R, G => s8_G, B => s8_B,
            Y => s8_Y, Cb => s8_Cb, Cr => s8_Cr, ready => s8_ready
        );

    DUT_10: entity work.conversor
        generic map (N => N10)
        port map (
            clk => clk, reset => reset, start => s10_start, lido => s10_lido,
            sel => s10_sel, R => s10_R, G => s10_G, B => s10_B,
            Y => s10_Y, Cb => s10_Cb, Cr => s10_Cr, ready => s10_ready
        );
    main_process: process
        
        variable seed1, seed2 : positive;
        variable rand_val     : real;
        variable r_int, g_int, b_int : integer;
        
        variable y_exp, cb_exp, cr_exp : integer;
        variable offset : integer;
        
        constant R_Y_709 : integer := 217;  constant R_Cb_709 : integer := -117; constant R_Cr_709 : integer := 512;
        constant G_Y_709 : integer := 732;  constant G_Cb_709 : integer := -394; constant G_Cr_709 : integer := -465;
        constant B_Y_709 : integer := 73;   constant B_Cb_709 : integer := 512;  constant B_Cr_709 : integer := -46;

        constant R_Y_2020 : integer := 269; constant R_Cb_2020 : integer := -143; constant R_Cr_2020 : integer := 512;
        constant G_Y_2020 : integer := 694; constant G_Cb_2020 : integer := -368; constant G_Cr_2020 : integer := -470;
        constant B_Y_2020 : integer := 60;  constant B_Cb_2020 : integer := 512;  constant B_Cr_2020 : integer := -41;

        procedure verify_8bits(r_in, g_in, b_in : integer; mode : std_logic) is
        begin
            s8_R <= std_logic_vector(to_unsigned(r_in, N8));
            s8_G <= std_logic_vector(to_unsigned(g_in, N8));
            s8_B <= std_logic_vector(to_unsigned(b_in, N8));
            s8_sel <= mode;
            
            s8_start <= '1';
            wait until rising_edge(clk);
            s8_start <= '0';
            
            wait until s8_ready = '1';
            wait for CLK_PERIOD/2;

            offset := 128;
            if mode = '0' then
                y_exp  := calc_term(r_in, R_Y_709)  + calc_term(g_in, G_Y_709)  + calc_term(b_in, B_Y_709);
                cb_exp := calc_term(r_in, R_Cb_709) + calc_term(g_in, G_Cb_709) + calc_term(b_in, B_Cb_709) + offset;
                cr_exp := calc_term(r_in, R_Cr_709) + calc_term(g_in, G_Cr_709) + calc_term(b_in, B_Cr_709) + offset;
            else
                y_exp  := calc_term(r_in, R_Y_2020)  + calc_term(g_in, G_Y_2020)  + calc_term(b_int, B_Y_2020);
                cb_exp := calc_term(r_in, R_Cb_2020) + calc_term(g_in, G_Cb_2020) + calc_term(b_in, B_Cb_2020) + offset;
                cr_exp := calc_term(r_in, R_Cr_2020) + calc_term(g_in, G_Cr_2020) + calc_term(b_in, B_Cr_2020) + offset;
            end if;

            assert unsigned(s8_Y) = saturate(y_exp, N8)
                report "ERRO 8-bits Y: Esp " & integer'image(saturate(y_exp, N8)) & " Rec " & integer'image(to_integer(unsigned(s8_Y))) severity error;
            
            assert unsigned(s8_Cb) = saturate(cb_exp, N8)
                report "ERRO 8-bits Cb: Esp " & integer'image(saturate(cb_exp, N8)) & " Rec " & integer'image(to_integer(unsigned(s8_Cb))) severity error;

            assert unsigned(s8_Cr) = saturate(cr_exp, N8)
                report "ERRO 8-bits Cr: Esp " & integer'image(saturate(cr_exp, N8)) & " Rec " & integer'image(to_integer(unsigned(s8_Cr))) severity error;

            s8_lido <= '1';
            wait until rising_edge(clk);
            s8_lido <= '0';
            wait for CLK_PERIOD * 2;
        end procedure;

        procedure verify_10bits(r_in, g_in, b_in : integer; mode : std_logic) is
        begin
            s10_R <= std_logic_vector(to_unsigned(r_in, N10));
            s10_G <= std_logic_vector(to_unsigned(g_in, N10));
            s10_B <= std_logic_vector(to_unsigned(b_in, N10));
            s10_sel <= mode;
            
            s10_start <= '1';
            wait until rising_edge(clk);
            s10_start <= '0';
            
            wait until s10_ready = '1';
            wait for CLK_PERIOD/2;

            offset := 512;
            if mode = '0' then
                y_exp  := calc_term(r_in, R_Y_709)  + calc_term(g_in, G_Y_709)  + calc_term(b_in, B_Y_709);
                cb_exp := calc_term(r_in, R_Cb_709) + calc_term(g_in, G_Cb_709) + calc_term(b_in, B_Cb_709) + offset;
                cr_exp := calc_term(r_in, R_Cr_709) + calc_term(g_in, G_Cr_709) + calc_term(b_in, B_Cr_709) + offset;
            else
                y_exp  := calc_term(r_in, R_Y_2020)  + calc_term(g_in, G_Y_2020)  + calc_term(b_int, B_Y_2020);
                cb_exp := calc_term(r_in, R_Cb_2020) + calc_term(g_in, G_Cb_2020) + calc_term(b_in, B_Cb_2020) + offset;
                cr_exp := calc_term(r_in, R_Cr_2020) + calc_term(g_in, G_Cr_2020) + calc_term(b_in, B_Cr_2020) + offset;
            end if;

            assert unsigned(s10_Y) = saturate(y_exp, N10)
                report "ERRO 10-bits Y: Esp " & integer'image(saturate(y_exp, N10)) & " Rec " & integer'image(to_integer(unsigned(s10_Y))) severity error;
            
            assert unsigned(s10_Cb) = saturate(cb_exp, N10)
                report "ERRO 10-bits Cb: Esp " & integer'image(saturate(cb_exp, N10)) & " Rec " & integer'image(to_integer(unsigned(s10_Cb))) severity error;

            assert unsigned(s10_Cr) = saturate(cr_exp, N10)
                report "ERRO 10-bits Cr: Esp " & integer'image(saturate(cr_exp, N10)) & " Rec " & integer'image(to_integer(unsigned(s10_Cr))) severity error;

            s10_lido <= '1';
            wait until rising_edge(clk);
            s10_lido <= '0';
            wait for CLK_PERIOD * 2;
        end procedure;

    begin
        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "========================================";
        report " INICIANDO TESTES N=8 BITS ";
        report "========================================";

        report "--> Testando BT.709 (Preto, Branco, Cinza)";
        verify_8bits(0, 0, 0, '0');
        verify_8bits(255, 255, 255, '0');
        verify_8bits(128, 128, 128, '0');

        report "--> Testando BT.2020 (Vermelho Puro, Verde Puro)";
        verify_8bits(255, 0, 0, '1');
        verify_8bits(0, 255, 0, '1');

        report "--> Testando 10 Casos Aleatórios (BT.709)";
        for i in 1 to 10 loop
            uniform(seed1, seed2, rand_val); r_int := integer(rand_val * 255.0);
            uniform(seed1, seed2, rand_val); g_int := integer(rand_val * 255.0);
            uniform(seed1, seed2, rand_val); b_int := integer(rand_val * 255.0);
            verify_8bits(r_int, g_int, b_int, '0');
        end loop;

        report "========================================";
        report " INICIANDO TESTES N=10 BITS ";
        report "========================================";

        report "--> Testando BT.709 (Limites)";
        verify_10bits(0, 0, 0, '0');
        verify_10bits(1023, 1023, 1023, '0');
        
        report "--> Testando BT.2020 (Cor Mista)";
        verify_10bits(500, 200, 800, '1');

        report "--> Testando 10 Casos Aleatórios (BT.2020)";
        for i in 1 to 10 loop
            uniform(seed1, seed2, rand_val); r_int := integer(rand_val * 1023.0);
            uniform(seed1, seed2, rand_val); g_int := integer(rand_val * 1023.0);
            uniform(seed1, seed2, rand_val); b_int := integer(rand_val * 1023.0);
            verify_10bits(r_int, g_int, b_int, '1');
        end loop;

        report "========================================";
        report " TODOS OS TESTES CONCLUIDOS COM SUCESSO ";
        report "========================================";
        
        wait;
    end process;

end architecture;
