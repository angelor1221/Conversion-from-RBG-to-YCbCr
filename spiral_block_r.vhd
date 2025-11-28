library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spiral_block_r is
    generic (
      N: positive := 8
    );
    Port (
        X  : in  signed(N+9 downto 0);
        Y1 : out signed(N+9 downto 0);
        Y2 : out signed(N+9 downto 0);
        Y3 : out signed(N+9 downto 0);
        Y4 : out signed(N+9 downto 0);
        Y5 : out signed(N+9 downto 0);
        Y6 : out signed(N+9 downto 0)
    );
end spiral_block_r;

architecture behavior of spiral_block_r is

    signal w1, w16, w15, w128, w143  : signed(N+19 downto 0);
    signal w30, w29, w116, w117      : signed(N+19 downto 0);
    signal w232, w217, w240, w269    : signed(N+19 downto 0);
    signal w117_neg, w512, w143_neg  : signed(N+19 downto 0); 

begin

    -- Passo 1: Redimensionar a entrada para 42 bits (Sign Extension)
    -- O Verilog fazia isso implícito. No VHDL, usamos resize.
    w1 <= resize(X, N+19);

    -- Passo 2: Operações de Shift e Add (Deslocar e Somar)
    
    -- Cálculos baseados em w1
    w16  <= shift_left(w1, 4);        -- X * 16
    w15  <= w16 - w1;                 -- X * 15
    w128 <= shift_left(w1, 7);        -- X * 128
    w143 <= w15 + w128;               -- X * 143 (15 + 128)
    
    -- Cálculos derivados
    w30  <= shift_left(w15, 1);       -- 15X * 2 = 30X
    w29  <= w30 - w1;                 -- 30X - X = 29X
    w116 <= shift_left(w29, 2);       -- 29X * 4 = 116X
    w117 <= w1 + w116;                -- X + 116X = 117X
    
    w232 <= shift_left(w29, 3);       -- 29X * 8 = 232X
    w217 <= w232 - w15;               -- 232X - 15X = 217X
    
    w240 <= shift_left(w15, 4);       -- 15X * 16 = 240X
    w269 <= w29 + w240;               -- 29X + 240X = 269X
    
    w512 <= shift_left(w1, 9);        -- X * 512
    
    -- Negações (Inversores de sinal)
    w117_neg <= -w117;                -- Multiplica por -1
    w143_neg <= -w143;                -- Multiplica por -1

    -- Passo 3: Atribuição das saídas (Bit Slicing / Divisão por 1024)
    -- Pegamos os bits 41 até 10, o que descarta os 10 bits inferiores.
        17 DOWNTO 0
        27 DOWNTO 10
    Y1 <= w217(N+19 downto N+2);
    Y2 <= w117_neg(N+19 downto N+2);
    Y3 <= w512(N+19 downto N+2);
    Y4 <= w269(N+19 downto N+2);
    Y5 <= w143_neg(N+19 downto N+2);
    Y6 <= w512(N+19 downto N+2);

end behavior;
