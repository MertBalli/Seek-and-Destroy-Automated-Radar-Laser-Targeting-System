library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity laser is
PORT(
clk: in std_logic;
xcor: in integer; 
ycor: in integer; 
zcor: in integer; 
dist: in integer;
servo3angle: out integer; 
servo4angle: out integer);

end laser;

architecture Behavioral of laser is

constant servomin : integer := 55000;
constant servomax : integer := 240000;

constant lasx:integer:= -200000;
constant lasy:integer:= 0;
constant lasz: integer:=0;


type intarray90 is array (0 to 89) of integer;
    
    constant ARCTAN_LUT : intarray90 := (
        0, 2, 3, 5, 7, 9, 11, 12, 14, 16,
        18, 19, 21, 23, 25, 27, 29, 31, 32, 34,
        36, 38, 40, 42, 45, 47, 49, 51, 53, 55,
        58, 60, 62, 65, 67, 70, 73, 75, 78, 81,
        84, 87, 90, 93, 97, 100, 104, 107, 111, 115,
        119, 123, 128, 133, 138, 143, 148, 154, 160, 166,
        173, 180, 188, 196, 205, 214, 225, 236, 248, 261,
        275, 290, 308, 327, 349, 373, 401, 433, 470, 514,
        567, 631, 712, 814, 951, 1143, 1430, 1908, 2864, 5729
    );

function getangle(yn:integer ; xn:integer) return integer is
    variable targetratio:integer;
    variable foundangle: integer:=90;
    variable abs_y: integer;
    variable abs_x: integer;
    
    begin
    
    abs_y := abs(yn);
    abs_x := abs(xn);
    
    if abs_x = 0 then
        return 90; -- X sıfırsa tam dik (90 derece)
    end if; 
       
    -- Tanjant oranı hesapla (x100 hassasiyetle)
    targetratio := (abs_y*100/abs_x);
     
    -- LUT'tan baz açıyı bul (0-90 arası)
    for i in 0 to 89 loop
       if ARCTAN_LUT(i) >= targetratio then
       foundangle := i;
       exit;
       end if;
     end loop; 
     
 
    
    if xn >= 0 then
       
        if yn >= 0 then
             return 90 + foundangle;
        else
             return 90 - foundangle;
        end if;
    else
        
        if yn >= 0 then
            return 180; 
        else
            return 0;   
        end if;
    end if;
        
end function;
    
   
begin

process(clk)

variable lx : integer; 
variable ly : integer; 
variable lz : integer; 

variable abs_lx : integer;
variable abs_ly : integer;
variable horizontal_dist : integer;
        
variable rotatedeg : integer;
variable tiltdeg : integer;
        
variable servo3return : integer;
variable servo4return : integer;



begin

if rising_edge(clk) then

lx:= xcor-lasx;
ly:= ycor-lasy;
lz:= zcor-lasz;

abs_lx := abs(lx);
abs_ly := abs(ly);

rotatedeg := getangle(ly, lx); 

            

if abs_lx > abs_ly then
    horizontal_dist := (96 * abs_lx + 40 * abs_ly) / 100;
else
    horizontal_dist := (96 * abs_ly + 40 * abs_lx) / 100;
end if;

 tiltdeg := getangle(lz, horizontal_dist);



servo3return := servomin + (rotatedeg * 1027);
servo4return := 55000 + ((tiltdeg - 90) * 1027);

if servo3return > 240000 then servo3return := 240000; end if;
if servo3return < 55000 then servo3return := 55000; end if;

if servo4return > 240000 then servo4return := 240000; end if;
if servo4return < 55000 then servo4return := 55000; end if;

servo3angle <= servo3return;

servo4angle <= servo4return;

end if;

end process;

end Behavioral;
