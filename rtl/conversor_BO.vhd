library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conversor_pkg.all;

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
    signal reg_r_conc, reg_g_conc, reg_b_conc: std_logic_vector(N downto 0);
    
    -- tamanho da constante zero que preenche as entradas não utilizadas
    signal zero: std_logic_vector(N_ext-1 downto 0) := (others => '0');

    -- saidas dos muxes 8:1
    signal sai_mux_r, sai_mux_g, sai_mux_b: std_logic_vector(N downto 0);
    
    -- controle do mux (sel + stage)
    signal seletor_mux : std_logic_vector(2 downto 0);

    -- fios das somas 
    signal soma_rg: std_logic_vector(N downto 0);
    signal soma_total: std_logic_vector(N downto 0);
    signal soma_final: std_logic_vector(N-1 downto 0);

    -- offset de 128 (pra Cb e Cr)
    signal val_128, val_0, off_escolhido: std_logic_vector(N-1 downto 0);
    signal off_ajustado: std_logic_vector(N_ext-1 downto 0);

    -- resultado final
    signal res_cortado: std_logic_vector(N-1 downto 0);

    signal y1_r, y2_r, y3_r, y4_r, y5_r, y6_r: (N_ext-1 downto 0);
    signal y1_g, y2_g, y3_g, y4_g, y5_g, y6_g: (N_ext-1 downto 0);
    signal y1_b, y2_b, y3_b, y4_b, y5_b, y6_b: (N_ext-1 downto 0);

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

    reg_r_conc <= '0' & reg_r;
        
    reg_g_conc <= '0' & reg_g;
        
    reg_b_conc <= '0' & reg_r;

    -- blocos spiral de R, G e B respectivamente

    spiral_r: entity work.spiral_block_r(rtl)
        generic map (N => N+1)
        port map (X  => reg_r_conc, Y1 => y1_r, Y2 => y2_r, Y3 => y3_r,
                 Y4 => y4_r, Y5 => y5_r, Y6 => y6_r);

    spiral_g: entity work.spiral_block_g(rtl)
        generic map (N => N+1)
        port map (X  => reg_g_conc, Y1 => y1_g, Y2 => y2_g, Y3 => y3_g,
                 Y4 => y4_g, Y5 => y5_g, Y6 => y6_g);

    spiral_b: entity work.spiral_block_b(rtl)
        generic map (N => N+1)
        port map (X  => reg_b_conc, Y1 => y1_b, Y2 => y2_b, Y3 => y3_b,
                 Y4 => y4_b, Y5 => y5_b, Y6 => y6_b);
    
    -- concatenação do seletor: bit sel (MSB) + stage (2 bits LSB)
    seletor_mux <= sel & i_comandos.stage;

    -- muxes para escolher valor correto da multiplicação
    
    mux_canal_r: entity work.mux8para1(rtl)  
        generic map (N => N+1)
        port map (sel => seletor_mux, y => sai_mux_r,
                  e0 => y1_r, e1 => y2_r, e2 => y3_r, e3 => zero,
                  e4 => y4_r, e5 => y5_r, e6 => y6_r, e7 => zero);

    mux_canal_g: entity work.mux8para1(rtl)  
        generic map (N => N+1)
        port map (sel => seletor_mux, y => sai_mux_g,
                  e0 => y1_g, e1 => y2_g, e2 => y3_g, e3 => zero,
                  e4 => y4_g, e5 => y5_g, e6 => y6_g, e7 => zero);

    mux_canal_b: entity work.mux8para1(rtl)  
        generic map (N => N+1)
        port map (sel => seletor_mux, y => sai_mux_b,
                  e0 => y1_b, e1 => y2_b, e2 => y3_b, e3 => zero,
                  e4 => y4_b, e5 => y5_b, e6 => y6_b, e7 => zero);


    -- soma em cascata
    somador_estagio_1: entity work.somador(rtl) 
        generic map (N => N+1)
        port map (x => sai_mux_r, y => sai_mux_g, r => soma_rg);

    somador_total: entity work.somador(rtl)  
        generic map (N => N+1)
        port map (x => soma_rg, y => sai_mux_b, r => soma_total);


    -- lógica do offset (para a gnt ajustar a escala dos números).
    val_0 <= (others => '0');
    val_128 <= (N-1 => '1', others => '0'); 

    mux_offset: entity work.mux2para1(rtl)  
        generic map (N => N)
        port map (sel => i_comandos.SY, e0 => val_128, e1 => val_0, y => off_escolhido);

    off_ajustado <= off_escolhido(N-1 downto 0); 

    somador_final_offset: entity work.somador(rtl)  
        generic map (N => N_ext)
        port map (x => soma_total, y => off_ajustado, r => soma_final);


    -- saturação 
    process(soma_final)
        variable v_soma_signed : signed(N-1 downto 0);
        variable v_inteiro : integer;
    begin
        v_soma_signed := signed(soma_final);
        
        -- descarta parte fracionária
        -- acho que não precisa mais disso v_inteiro := to_integer(v_soma_signed(N_ext-1 downto 8));

        if v_soma_signed < 0 then
            res_cortado <= (others => '0');
        elsif v_soma_signed > 255 then
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
