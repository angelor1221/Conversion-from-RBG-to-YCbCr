library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador_generico is
    generic (
        N : positive := 8
    );
    port (
        x : in  std_logic_vector(N-1 downto 0);
        y : in  std_logic_vector(N-1 downto 0);
        r : out std_logic_vector(N-1 downto 0)
    );
end somador_generico;

architecture rtl of somador_generico is
begin
    r <= std_logic_vector(signed(x) + signed(y));
end rtl;