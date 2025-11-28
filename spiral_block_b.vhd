library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spiral_block_b is
    generic (
      N: positive := 10
    );
    Port (
        X  : in  signed(N-1 downto 0);
        Y1 : out std_logic_vector(N-1 downto 0);
        Y2 : out std_logic_vector(N-1 downto 0);
        Y3 : out std_logic_vector(N-1 downto 0);
        Y4 : out std_logic_vector(N-1 downto 0);
        Y5 : out std_logic_vector(N-1 downto 0);
        Y6 : out std_logic_vector(N-1 downto 0)
    );
end spiral_block_b;

architecture behavior of spiral_block_b is

    -- Sinais internos de 42 bits
    signal w1, w16, w15, w8, w23   : signed(N+9 downto 0);
    signal w9, w32, w41, w64, w73  : signed(N+9 downto 0);
    signal w512, w46, w60          : signed(N+9 downto 0);
    
    -- Sinais negativos
    signal w46_neg, w41_neg        : signed(N+9 downto 0);

begin

    -- 1. Redimensionar entrada
    w1 <= resize(X, N+10);

    -- 2. Lógica de Shift-and-Add
    
    w16 <= shift_left(w1, 4);         -- X * 16
    w15 <= w16 - w1;                  -- 16X - X = 15X
    
    w8  <= shift_left(w1, 3);         -- X * 8
    w23 <= w15 + w8;                  -- 15X + 8X = 23X
    
    w9  <= w1 + w8;                   -- X + 8X = 9X
    
    w32 <= shift_left(w1, 5);         -- X * 32
    w41 <= w9 + w32;                  -- 9X + 32X = 41X
    
    w64 <= shift_left(w1, 6);         -- X * 64
    w73 <= w9 + w64;                  -- 9X + 64X = 73X
    
    w512 <= shift_left(w1, 9);        -- X * 512
    
    w46 <= shift_left(w23, 1);        -- 23X * 2 = 46X
    w46_neg <= -w46;                  -- Multiplica por -1
    
    w60 <= shift_left(w15, 2);        -- 15X * 4 = 60X
    
    w41_neg <= -w41;                  -- Multiplica por -1

    -- 3. Atribuição das saídas (Bit Slicing / Divisão por 1024)
    Y1 <= std_logic_vector(w73(N+9 downto 10));
    Y2 <= std_logic_vector(w512(N+9 downto 10));
    Y3 <= std_logic_vector(w46_neg(N+9 downto 10));
    Y4 <= std_logic_vector(w60(N+9 downto 10));
    Y5 <= std_logic_vector(w512(N+9 downto 10));
    Y6 <= std_logic_vector(w41_neg(N+9 downto 10));

end behavior;
