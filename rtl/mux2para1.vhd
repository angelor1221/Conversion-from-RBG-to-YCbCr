library ieee;
use ieee.std_logic_1164.all;

entity mux2para1 is
    generic (
        N: positive := 8
    );
    port (
        sel: in  std_logic;
        e0,e1: in  std_logic_vector(N-1 downto 0);
        y: out std_logic_vector(N-1 downto 0)
    );
end entity mux2para1;

architecture rtl of mux2para1 is
begin

    y <= e0 when sel = '0' else e1;

end architecture rtl;
