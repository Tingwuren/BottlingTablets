--控制模块，主要功能有：
--当最大瓶数maxbot或每瓶药片数tabper超出限制后报警warn并禁止计数disable；
--最大瓶数maxbot<=18，每瓶药片数<=50
--当药瓶总数botsum1&botsum0达到上限botsum后报警warn并禁止计数disable
--当允许计数时绿灯置1，红灯置0
--当禁止计数时红灯置1，绿灯置0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

entity Controller is
    port(
        botsum1: in std_logic_vector(3 downto 0); 
        --瓶数十位
        botsum0: in std_logic_vector(3 downto 0);
        --瓶数个位
        maxbot: in std_logic_vector(7 downto 0);
        --Maximum bottling volume（最大装瓶量的BCD码输入）,对应K15-K8
        tabper: in std_logic_vector(7 downto 0);

        disable: out std_logic;
        --计数使能，若总瓶数到达上限则禁止计数
        green: out std_logic;
        --绿灯，为1则代表正在计数
        red: out std_logic;
        --红灯，为1代表停止计数
        warn: out std_logic
        --报警使能信号，为高时报警
    );
end;

architecture Behavioral of Controller is
begin
    -- 处理disable，warn，green和red输出的进程
    process(botsum1, botsum0, maxbot, tabper)
    begin
        -- 将botsum1和botsum0转换为整数值
        -- 表示总瓶数
        -- （假设botsum1和botsum0是BCD编码的）
        -- （假设maxbot是BCD编码的）
        if botsum1 & botsum0 =  maxbot
        or maxbot > "00011000"
        or tabper > "01010000" then
            disable <= '1';
            warn <= '1';
            green <= '0';
            red <= '1';
        else
            disable <= '0';
            warn <= '0';
            green <= '1';
            red <= '0';
        end if;
    end process;
    
end Behavioral;