
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sevsegdis is
PORT(
    clk : in std_logic;
    num : in integer;
    seg : out std_logic_vector(6 downto 0);
    an  : out std_logic_vector(3 downto 0)
);
end sevsegdis;

architecture Behavioral of sevsegdis is

    signal num1: integer := 0;
    signal num2: integer := 0;
    signal num3: integer := 0;
    signal num4: integer := 0;

    signal counter : integer := 0;
    signal anode   : integer := 0; 

begin

    process(num)
    begin
        num1 <= (abs(num) / 1000) mod 10; 
        num2 <= (abs(num) / 100) mod 10;  
        num3 <= (abs(num) / 10) mod 10;   
        num4 <= abs(num) mod 10;          
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if counter >= 100000 then
                counter <= 0;
                if anode = 3 then
                    anode <= 0;
                else
                    anode <= anode + 1;
                end if;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process(anode, num1, num2, num3, num4)
        variable current_val: integer;
    begin
        
        case anode is
            when 0 => 
                an <= "0111"; 
                current_val := num1;
            when 1 => 
                an <= "1011"; 
                current_val := num2;
            when 2 => 
                an <= "1101"; 
                current_val := num3;
            when 3 => 
                an <= "1110"; 
                current_val := num4;
            when others => 
                an <= "1111"; 
                current_val := 0;
        end case;

        case current_val is
            when 0 => seg <= "1000000";
            when 1 => seg <= "1111001";
            when 2 => seg <= "0100100";
            when 3 => seg <= "0110000";
            when 4 => seg <= "0011001";
            when 5 => seg <= "0010010";
            when 6 => seg <= "0000010";
            when 7 => seg <= "1111000";
            when 8 => seg <= "0000000";
            when 9 => seg <= "0010000";
            when others => seg <= "1111111";
        end case;

    end process;

end Behavioral;