library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spiral_block_g is
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
end spiral_block_g;

architecture behavior of spiral_block_g is

    signal w1, w16, w15, w8, w23   : signed(N+9 downto 0);
    signal w480, w465, w184, w183  : signed(N+9 downto 0);
    signal w60, w59, w256, w197    : signed(N+9 downto 0);
    signal w236, w235, w118, w347  : signed(N+9 downto 0);
    signal w732, w394, w694, w368, w470 : signed(N+9 downto 0);
    signal w394_neg, w465_neg, w368_neg, w470_neg : signed(N+9 downto 0);

begin

    -- 1. Redimensionar entrada (Sign Extension)
    w1 <= resize(X, N+10);

    -- 2. Lógica de Shift-and-Add (Multiplicação por constantes)
    
    w16  <= shift_left(w1, 4);         -- X * 16
    w15  <= w16 - w1;                  -- X * 15
    w8   <= shift_left(w1, 3);         -- X * 8
    w23  <= w15 + w8;                  -- X * 23
    
    w480 <= shift_left(w15, 5);        -- 15X * 32 = 480X
    w465 <= w480 - w15;                -- 480X - 15X = 465X
    
    w184 <= shift_left(w23, 3);        -- 23X * 8 = 184X
    w183 <= w184 - w1;                 -- 184X - X = 183X
    
    w60  <= shift_left(w15, 2);        -- 15X * 4 = 60X
    w59  <= w60 - w1;                  -- 60X - X = 59X
    
    w256 <= shift_left(w1, 8);         -- X * 256
    w197 <= w256 - w59;                -- 256X - 59X = 197X
    
    w236 <= shift_left(w59, 2);        -- 59X * 4 = 236X
    w235 <= w236 - w1;                 -- 236X - X = 235X
    
    w118 <= shift_left(w59, 1);        -- 59X * 2 = 118X
    w347 <= w465 - w118;               -- 465X - 118X = 347X
    
    w732 <= shift_left(w183, 2);       -- 183X * 4 = 732X
    
    w394 <= shift_left(w197, 1);       -- 197X * 2 = 394X
    w394_neg <= -w394;                 -- Multiplica por -1
    
    w465_neg <= -w465;                 -- Multiplica por -1
    
    w694 <= shift_left(w347, 1);       -- 347X * 2 = 694X
    
    w368 <= shift_left(w23, 4);        -- 23X * 16 = 368X
    w368_neg <= -w368;                 -- Multiplica por -1
    
    w470 <= shift_left(w235, 1);       -- 235X * 2 = 470X
    w470_neg <= -w470;                 -- Multiplica por -1

    -- 3. Atribuição das saídas (Bit Slicing / Divisão por 1024)
    Y1 <= std_logic_vector(w732(N+9 downto 10));
    Y2 <= std_logic_vector(w394_neg(N+9 downto 10));
    Y3 <= std_logic_vector(w465_neg(N+9 downto 10));
    Y4 <= std_logic_vector(w694(N+9 downto 10));
    Y5 <= std_logic_vector(w368_neg(N+9 downto 10));
    Y6 <= std_logic_vector(w470_neg(N+9 downto 10));

end behavior;
