library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--警报器模块
entity Siren is
    port(
        highfre: in std_logic; --High frequency（高频，10KHz）
        lowfre: out std_logic; --Low frequency（低频，250Hz方波）
        warn: in std_logic --Warn signal（警告信号）
    );
end Siren;

--对10kHz的脉冲进行分频
architecture behavioral of Siren is
    signal temp: integer range 0 to 39;
    --临时变量，在0-39四十个数之间随频率递增
begin
    process(highfre)
    begin
        if (highfre'event and highfre = '1') then
            if warn = '1' then
                if temp = 39 then
                    temp <= 0;
                else
                    temp <= temp + 1;
                end if;
                
                if (temp < 20) then
                    lowfre <= '1';
                else
                    lowfre <= '0';
                end if;
            else
                lowfre <= '0';
            end if;
        end if;
    end process;

end behavioral;