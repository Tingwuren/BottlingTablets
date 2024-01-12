library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--选择器模块
entity Selector is
    port(
        start: in std_logic;
        --启动计数
        botsum1, botsum0, persum1, persum0: in std_logic_vector(3 downto 0);
        --2个数码管(装瓶数)，2个数码管（每瓶药片数）
        output1,output0: out std_logic_vector(3 downto 0)
        --2个数码管，选择装瓶数或每瓶药片数中的一组，分别对应LG3，LG2
    );
end;

--对开始暂停信号进行判断决定输出瓶数还是当前药片数
architecture behavioral of Selector is
begin
    process(start)
    begin
        if start = '0' then
            --暂停时输出瓶数
            output1 <= botsum1;
            output0 <= botsum0;
        else
            --计数时输出单瓶药片数
            output1 <= persum1;
            output0 <= persum0;
        end if;
    end process;
end behavioral;