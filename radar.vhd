library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity radar is
PORT(
clk: in std_logic;
trigger: out std_logic;
echo: in std_logic;
distance: out integer
);

end radar;

architecture Behavioral of radar is

constant triggertime: integer:=1000;
constant periodtime: integer:=6000000;
signal counttrig: integer:=0;
signal countecho: integer:=0;
signal echomem :std_logic;

begin
process(clk)
begin

if rising_edge(clk) then
    
    echomem <= echo;
    
    if counttrig= periodtime-1 then
        counttrig <= 0;
    else
        counttrig <= counttrig + 1;
    end if;
    
    if counttrig < triggertime then
        trigger <= '1';
    else
        trigger <= '0';
    end if; 
    
    if echo = '1' then
        countecho <= countecho + 1;
    end if;
    
    if echomem = '1' and echo = '0' then
        distance <= countecho/5830;
        countecho <= 0;
    end if; 
  end if;
    
   

    
        
      
end process;
end Behavioral;
