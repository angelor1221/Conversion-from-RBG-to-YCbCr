library ieee;
use ieee.std_logic_1164.all;

entity mux8para1 is
    generic (
        N: positive := 8
    );
    port (
        sel: in  std_logic_vector(2 downto 0);
        e0, e1, e2, e3, e4, e5, e6, e7: in  std_logic_vector(N-1 downto 0);
        y: out std_logic_vector(N-1 downto 0)
    );
end entity mux8para1;

architecture rtl of mux8para1 is
begin

    with sel select
        y <= e0 when "000",
             e1 when "001",
             e2 when "010",
             e3 when "011",
             e4 when "100",
             e5 when "101",
             e6 when "110",
             e7 when others;
             
end architecture rtl;
