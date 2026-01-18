library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity servo is
PORT(
clk: in std_logic;
cycle: in integer;
move: out std_logic
);

end servo;

architecture Behavioral of servo is

constant maxperiod: integer:= 2000000;
signal count: integer:=0;

begin
process(clk)
begin

if rising_edge(clk) then
    if count = maxperiod-1 then
        count <= 0;
    else
        count <= count+1;
    end if; 
        
    if count < cycle then
        move <= '1';
    else
        move <= '0';
    end if;
    
 end if;
    
end process;


end Behavioral;
