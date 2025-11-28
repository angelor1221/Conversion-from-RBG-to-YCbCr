library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package conversor_pkg is

    -- Sinais de controle 
    type comandos_t is record
        SY: std_logic;                    
        SCb: std_logic;                    
        SCr: std_logic;                    
        stage: std_logic_vector(1 downto 0);                    
        cRGB: std_logic; 
    end record;

end package conversor_pkg;
