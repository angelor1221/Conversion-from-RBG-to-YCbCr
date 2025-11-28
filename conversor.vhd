library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conversor_pkg.all;

entity conversor is
    generic (
        N: positive := 8
    );
    port (
        R, G, B: in std_logic_vector(N-1 downto 0);
        sel, clk, reset, lido, start: in std_logic;
        Y, Cb, Cr: out std_logic_vector(N-1 downto 0);
        ready: out std_logic
    );
end entity conversor;

architecture rtl of conversor is
  signal i_comandos: comandos_t;
 begin 

  BO: entity work.conversor_BO
    generic map (N => N)
    port map (R => R, G => G, B => B, sel => sel, clk => clk,
              i_comandos => i_comandos, Y => Y, Cb => Cb, Cr => Cr);

  BC: entity work.conversorBC
    port map (clk => clk, reset => reset, start => start, lido => lido,
              ready => ready, i_comandos => i_comandos);

end architecture rtl;
