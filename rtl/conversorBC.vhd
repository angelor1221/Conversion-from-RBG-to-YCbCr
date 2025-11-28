library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conversor_pkg.all;

-- Bloco de Controle (BC)
-- Controla registradores e estágios do datapath
entity conversorBC is
    port(
        clk      : in  std_logic;  -- clock (sinal de relógio)
        reset    : in  std_logic;  -- reset assíncrono ativo em nível alto
        start   : in  std_logic;  -- sinal de início de processamento
        lido    : in  std_logic; -- 
        ready     : out std_logic;  -- sinal de término de processamento

        i_comandos: out comandos_t --SY, SCb, SCr, stage, cRGB
    );
end entity conversorBC;

architecture behavior of conversorBC is
    type estados_t is (Init, Load, Y, Cb, Cr, Res);
    signal current_state, next_state: estados_t;

begin

    -- carga e reset do registrador de estado;
    
    reg_state: process(clk, rst_a)
    begin
        if(reset = '1') then
            current_state <= Init;
        elsif(rising_edge(clk)) then
            current_state <= next_state;
        end if;
    end process reg_state;
  
    -- Processo de Transição de Estados (LPE)
    LPE : process(current_state)
      begin
        case current_state is
            when Init =>
                if (start = '1') then
                    next_state <= Load;
                else
                    next_state <= Init;
                end if;
            when Load =>
                next_state <= Y;
            when Y =>
                next_state <= Cb;
            when Cb =>
                next_state <= Cr;
            when Cr =>
                next_state <= Res;
            when Res =>
                if (lido = '1') then
                    next_state <= Init;
                else
                    next_state <= Res;
          end case;
    end process LPE;

    -- Processo de Saídas (LS)
    LS: process(current_state)
    begin
      case current_state is
        when Init =>
          ready <= '0';
          i_comandos.SY <= '0';
          i_comandos.SCb <= '0';
          i_comandos.SCr <= '0';
          i_comandos.stage <= "11";
          i_comandos.cRGB <= '0';
        when Load =>
          ready <= '0';
          i_comandos.SY <= '0';
          i_comandos.SCb <= '0';
          i_comandos.SCr <= '0';
          i_comandos.stage <= "11";
          i_comandos.cRGB <= '1';
        when Y =>
          ready <= '0';
          i_comandos.SY <= '1';
          i_comandos.SCb <= '0';
          i_comandos.SCr <= '0';
          i_comandos.stage <= "00";
          i_comandos.cRGB <= '0';
        when Cb =>
          ready <= '0';
          i_comandos.SY <= '0';
          i_comandos.SCb <= '1';
          i_comandos.SCr <= '0';
          i_comandos.stage <= "01";
          i_comandos.cRGB <= '0';
        when Cr =>
          ready <= '0';
          i_comandos.SY <= '0';
          i_comandos.SCb <= '0';
          i_comandos.SCr <= '1';
          i_comandos.stage <= "10";
          i_comandos.cRGB <= '0';
        when Res =>
          ready <= '1';
          i_comandos.SY <= '0';
          i_comandos.SCb <= '0';
          i_comandos.SCr <= '0';
          i_comandos.stage <= "11";
          i_comandos.cRGB <= '0';
        end case;
    end process LS;

end architecture behavior;
