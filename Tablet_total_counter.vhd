--药片总量计数器模块，主要功能有：
--通过清零端clr完成清零功能
--根据禁止信号disable和开始信号start通过时钟脉冲信号lowfre完成总药片数的计数
--通过tabletsum2,tabletsum1,tabletsum0显示总药片的8421BCD码输出，分别对应百位，十位，个位
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;

--药片总量计数模块
entity Tablet_total_counter is
    port(
        start: in std_logic;
        --启动计数信号，高有效
        lowfre: in std_logic;
        --0.5Hz时钟脉冲信号
        clr: in std_logic;
        --清零信号，高有效
        disable: in std_logic;
        --计数使能信号，为高时计数
        tabletsum2: out std_logic_vector(3 downto 0);
        --药片总数百位
        tabletsum1: out std_logic_vector(3 downto 0);
        --药片总数十位
        tabletsum0: out std_logic_vector(3 downto 0)
        --药片总数个位
    );
end;

architecture Behavioral of Tablet_total_counter is
    signal count: integer range 0 to 999 := 0;
    signal tabletsum: integer range 0 to 999 := 0;
begin
    -- 处理count和tabletsum信号的进程
    process(lowfre, clr)
    begin
        if clr = '1' then
            count <= 0;
            --tabletsum <= 0;
            tabletsum2 = "0000";
            tabletsum1 = "0000";
            tabletsum0 = "0000";
        elsif rising_edge(lowfre) then
            if start = '1' and disable = '0' then
                if tabletsum2 = "1001" and tabletsum1 = "1001" and tabletsum0 = "1001" then
                    --药片总数999后变为000，即进千位
                    tabletsum2 <= "0000";
                    tabletsum1 <= "0000";
                    tabletsum0 <= "0000";
                elsif tabletsum1 = "1001" and tabletsum0 = "1001" then
                    --药片总数(X)99后变为(X+1)00，括号里为一位，即进百位
                    tabletsum2 <= tabletsum2 + 1;
                    tabletsum1 <= "0000";
                    tabletsum0 <= "0000";
                elsif tabletsum0 = "1001" then
                    --药片总数(X)(Y)9后变为(X)(Y+1)0，括号里为一位，即进十位
                    tabletsum1 <= tabletsum1 + 1;
                    tabletsum0 <= "0000";
                else
                    --只增个位
                    tabletsum0 <= tabletsum0 + 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;