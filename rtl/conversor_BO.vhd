library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conversor_pkg.all;

-- não consegui testar absolutamente nada enquanto fazia pq meu quartus tá bugado, 
-- ou seja, duvido n ter cagadas e n precisar de ajustes.  
-- além disso, falta a parte dos spirals. 
-- deixar esse código bom cabe aos amantes de vhdl - não faço parte dessa turma estranha.
-- depois apaguem esses comentários, tmj.

entity conversor_BO is
    generic (
        N: positive := 8
    );
    port (
        R, G, B: in std_logic_vector(N-1 downto 0);
        sel, clk: in std_logic;
        i_comandos: in comandos_t; 
        Y, Cb, Cr: out std_logic_vector(N-1 downto 0)
    );
end entity conversor_BO;

architecture rtl of conversor_BO is
    constant N_ext: integer := N + 9; 

    -- saidas dos registradores de entrada
    signal reg_r, reg_g, reg_b: std_logic_vector(N-1 downto 0);

    -- valores concatenados com 9 '0's a esquerda
    signal reg_r_conc, reg_g_conc, reg_b_conc: std_logic_vector(N+8 downto 0);
    
    -- tamanho da constante zero que preenche as entradas não utilizadas
    signal zero: std_logic_vector(N_ext-1 downto 0);

    -- saidas dos muxes 8:1
    signal sai_mux_r, sai_mux_g, sai_mux_b: std_logic_vector(N_ext-1 downto 0);
    
    -- controle do mux (sel + stage)
    signal seletor_mux : std_logic_vector(2 downto 0);

    -- fios das somas 
    signal soma_rg: std_logic_vector(N_ext-1 downto 0);
    signal soma_total: std_logic_vector(N_ext-1 downto 0);
    signal soma_final: std_logic_vector(N_ext-1 downto 0);

    -- offset de 128 (pra Cb e Cr)
    signal val_128, val_0, off_escolhido: std_logic_vector(N-1 downto 0);
    signal off_ajustado: std_logic_vector(N_ext-1 downto 0);

    -- resultado final
    signal res_cortado: std_logic_vector(N-1 downto 0);

begin
    
    zero <= (others => '0');

    -- registradores de entrada
    reg_entrada_r: entity work.registrador(rtl)  
        generic map (N => N)
        port map (clk => clk, ld => i_comandos.cRGB, d => R, q => reg_r);

    reg_entrada_g: entity work.registrador(rtl)  
        generic map (N => N)
        port map (clk => clk, ld => i_comandos.cRGB, d => G, q => reg_g);

    reg_entrada_b: entity work.registrador(rtl)  
        generic map (N => N)
        port map (clk => clk, ld => i_comandos.cRGB, d => B, q => reg_b);

    reg_r_conc <= "000000000" & reg_r;
        
    reg_g_conc <= "000000000" & reg_g;
        
    reg_b_conc <= "000000000" & reg_r;

    
    -- concatenação do seletor: bit sel (MSB) + stage (2 bits LSB)
    seletor_mux <= sel & i_comandos.stage;

    -- obs: não fiz a parte dos spirals, então deixei tudo em zero
    mux_canal_r: entity work.mux8para1(rtl)  
        generic map (N => N_ext)
        port map (sel => seletor_mux, y => sai_mux_r,
                  e0 => zero, e1 => zero, e2 => zero, e3 => zero,
                  e4 => zero, e5 => zero, e6 => zero, e7 => zero);

    mux_canal_g: entity work.mux8para1(rtl)  
        generic map (N => N_ext)
        port map (sel => seletor_mux, y => sai_mux_g,
                  e0 => zero, e1 => zero, e2 => zero, e3 => zero,
                  e4 => zero, e5 => zero, e6 => zero, e7 => zero);

    mux_canal_b: entity work.mux8para1(rtl)  
        generic map (N => N_ext)
        port map (sel => seletor_mux, y => sai_mux_b,
                  e0 => zero, e1 => zero, e2 => zero, e3 => zero,
                  e4 => zero, e5 => zero, e6 => zero, e7 => zero);


    -- soma em cascata
    somador_estagio_1: entity work.somador(rtl) 
        generic map (N => N_ext)
        port map (x => sai_mux_r, y => sai_mux_g, r => soma_rg);

    somador_total: entity work.somador(rtl)  
        generic map (N => N_ext)
        port map (x => soma_rg, y => sai_mux_b, r => soma_total);


    -- lógica do offset (para a gnt ajustar a escala dos números).
    val_0 <= (others => '0');
    val_128 <= (N-1 => '1', others => '0'); 

    mux_offset: entity work.mux2para1(rtl)  
        generic map (N => N)
        port map (sel => i_comandos.SY, e0 => val_128, e1 => val_0, y => off_escolhido);

    off_ajustado <= "0" & off_escolhido & "00000000"; 

    somador_final_offset: entity work.somador(rtl)  
        generic map (N => N_ext)
        port map (x => soma_total, y => off_ajustado, r => soma_final);


    -- saturação 
    process(soma_final)
        variable v_soma_signed : signed(N_ext-1 downto 0);
        variable v_inteiro : integer;
    begin
        v_soma_signed := signed(soma_final);
        
        -- descarta parte fracionária
        v_inteiro := to_integer(v_soma_signed(N_ext-1 downto 8));

        if v_inteiro < 0 then
            res_cortado <= (others => '0');
        elsif v_inteiro > 255 then
            res_cortado <= (others => '1');
        else
            res_cortado <= std_logic_vector(to_unsigned(v_inteiro, N));
        end if;
    end process;


    -- registradores de saída
    reg_out_y: entity work.registrador(rtl)  
        generic map (N => N)
        port map (clk => clk, ld => i_comandos.SY, d => res_cortado, q => Y);

    reg_out_cb: entity work.registrador(rtl)  
        generic map (N => N)
        port map (clk => clk, ld => i_comandos.SCb, d => res_cortado, q => Cb);

    reg_out_cr: entity work.registrador(rtl)  
        generic map (N => N)
        port map (clk => clk, ld => i_comandos.SCr, d => res_cortado, q => Cr);

end architecture rtl;
