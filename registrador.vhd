library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
    generic (
        N: positive := 8
    );
    port (
        clk: in  std_logic;
        ld: in  std_logic;                      
        d: in  std_logic_vector(N-1 downto 0); 
        q: out std_logic_vector(N-1 downto 0)  
    );
end registrador;

architecture rtl of registrador is
    signal q_reg : std_logic_vector(N-1 downto 0);
begin
    process(clk)
    begin
        if(rising_edge(clk) and ld = '1') then
				q_reg <= d;
        end if;
    end process;

    q <= q_reg;
end rtl;


