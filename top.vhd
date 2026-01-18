library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
PORT(
    clk     : in std_logic;
    echo    : in std_logic;
    trigger : out std_logic;

    servo1  : out std_logic;
    servo2  : out std_logic;
    servo3  : out std_logic;
    servo4  : out std_logic;

    sw1     : in std_logic;
    sw2     : in std_logic;
    
    btnreset : in std_logic; 

    seg     : out std_logic_vector(6 downto 0);
    anode   : out std_logic_vector(3 downto 0);

    stop    : out std_logic;
    
    
    buzzer   : out std_logic; 
    laser_fire : out std_logic  
);
end top;

architecture Behavioral of top is

    component servo
    PORT(
        clk   : in std_logic;
        cycle : in integer;
        move  : out std_logic
    );
    end component;

    component radar
    PORT(
        clk      : in std_logic;
        trigger  : out std_logic;
        echo     : in std_logic;
        distance : out integer
    );
    end component;

    component sevsegdis
    PORT(
        clk : in std_logic;
        num : in integer;
        seg : out std_logic_vector(6 downto 0);
        an  : out std_logic_vector(3 downto 0)
    );
    end component;
    
    component laser 
    PORT(
        clk: in std_logic;
        xcor: in integer; 
        ycor: in integer; 
        zcor: in integer; 
        dist: in integer;
        servo3angle: out integer; 
        servo4angle: out integer);
       end component;


    signal detecttimer      : integer := 0;
    constant confirmationtime : integer := 300000000;
    
    signal showedvalue      : integer := 0;
    signal xcor             : integer := 0;
    signal ycor             : integer := 0;
    signal zcor             : integer := 0;
    signal distance         : integer := 0;
    
    signal servo1pos        : integer := 55000; 
    signal servo2pos        : integer := 55000;
    
    signal servo1index      : integer := 0;
    signal servo2index      : integer := 0;
    
    constant minangle       : integer := 55000;
    constant maxangle       : integer := 240000;
    constant stepsize       : integer := 10500;
    
    signal waittimer        : integer := 0;
    constant delaytime      : integer := 10000000;

    signal targetlocked     : std_logic := '0';
    
    signal laserpan  : integer := 55000;
    signal lasertilt : integer := 55000;
    
    
    signal lock_distance : integer := 0;
    signal lock_x        : integer := 0;
    signal lock_y        : integer := 0;
    signal lock_z        : integer := 0;
    
    signal attack_timer : integer := 0; 

    type int_array is array (0 to 18) of integer; 
    constant SIN_LUT : int_array := (
       0, 17, 34, 50, 64, 77, 87, 94, 98, 100, 
       98, 94, 87, 77, 64, 50, 34, 17, 0
    );
       
    constant COS_LUT : int_array := (
       100, 98, 94, 87, 77, 64, 50, 34, 17, 0, 
       -17, -34, -50, -64, -77, -87, -94, -98, -100
    );

begin

    distsensor: radar PORT MAP(
        clk      => clk,
        echo     => echo,
        trigger  => trigger,
        distance => distance
    );

    flatservo: servo PORT MAP(
        clk   => clk,
        cycle => servo1pos,
        move  => servo1
    );

    verticalservo: servo PORT MAP(
        clk   => clk,
        cycle => servo2pos,
        move  => servo2
    );

    display: sevsegdis PORT MAP(
        seg => seg,
        an  => anode,
        num => showedvalue,
        clk => clk
    );

    laserunit: laser PORT MAP(
    clk => clk,
    xcor => lock_x,
    ycor => lock_y, 
    zcor => lock_z,
    dist => lock_distance,
    servo3angle => laserpan, 
    servo4angle => lasertilt
    );
    
    laserflatservo: servo PORT MAP(
      clk => clk,
       cycle => laserpan,
        move  => servo3
    );
    
   laserverticalservo: servo PORT MAP(
      clk => clk,
       cycle => lasertilt,
        move  => servo4
    );
    
    process(clk)
    begin
        if rising_edge(clk) then
            
            if btnreset = '1' then
                attack_timer <= 0;
                buzzer <= '0';
                laser_fire <= '0';
                servo1pos     <= minangle;
                servo2pos     <= minangle+13000;
                servo1index   <= 0;
                servo2index   <= 0;
                targetlocked  <= '0';
                stop          <= '0';
                detecttimer   <= 0;
                waittimer     <= delaytime;
                lock_distance <= 0;
                lock_x        <= 0;
                lock_y        <= 0;
                lock_z        <= 0;
                
            else
                if targetlocked = '0' then
                    attack_timer <= 0;
                    buzzer <= '0';
                    laser_fire <= '0';

                    if waittimer > 0 then
                        waittimer <= waittimer - 1;
                    else
                        if distance > 70 or distance <15  then
                            stop <= '0';
                            detecttimer <= 0;
                            
                            if servo2pos + stepsize <= maxangle then
                                servo2pos <= servo2pos + stepsize;
                                servo2index <= servo2index + 1;
                                waittimer <= delaytime;
                            elsif servo2pos + stepsize > maxangle then
                                servo2pos <= minangle+13000;
                                servo2index <= 0;
                                waittimer <= 50000000;
                                
                                if servo1pos + stepsize <= maxangle then
                                    servo1pos <= servo1pos + stepsize;
                                    servo1index <= servo1index + 1;
                                    waittimer <= delaytime;
                                elsif servo1pos + stepsize > maxangle then
                                    servo1pos <= minangle;
                                    servo1index <= 0;
                                    waittimer <= delaytime;
                                end if;
                            end if;

                        elsif distance > 15 and distance <= 70 then
                            
                            if detecttimer < confirmationtime then
                                detecttimer <= detecttimer + 1;
                                stop <= '0';
                            else
                                stop <= '1';
                                targetlocked <= '1';
                                
                                lock_distance <= distance;
                                lock_x        <= (distance * COS_LUT(servo2index) * COS_LUT(servo1index));
                                lock_y        <= (distance * COS_LUT(servo2index) * SIN_LUT(servo1index));
                                lock_z        <= (distance * SIN_LUT(servo2index)) * 100;
                            end if;
                        end if;
                    end if;
                   else 
                    
                    if attack_timer < 200000000 then
                        attack_timer <= attack_timer + 1;
                    end if;

                    
                    if (attack_timer > 0 and attack_timer < 50000000) or 
                       (attack_timer > 100000000 and attack_timer < 150000000) then
                        buzzer <= '1';
                    else
                        buzzer <= '0';
                    end if;

                    
                    if attack_timer >= 150000000 then
                        laser_fire <= '1';
                    else
                        laser_fire <= '0';
                    end if;
                    stop <= '1';
                end if;
            end if;
        end if;
    end process;

 process(sw1, sw2, targetlocked, distance, lock_distance, lock_x, lock_y, lock_z)
begin
    if targetlocked = '1' then
        
        if sw1='0' and sw2='1' then
            showedvalue <= lock_x / 10000;  
        elsif sw1='1' and sw2='0' then
            showedvalue <= lock_y / 10000;  
        elsif sw1='1' and sw2='1' then
            showedvalue <= lock_z / 10000;  
        else 
            showedvalue <= lock_distance;   
        end if;
    else
        
        if sw1='0' and sw2='0' then
            showedvalue <= distance;
        else
            showedvalue <= 0; 
        end if;
    end if;
end process;
    
    

end Behavioral;