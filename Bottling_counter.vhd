library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--装瓶量计数模块
entity Bottling_counter is
    port(
        start, co, clr: in std_logic;
        --启动计数，进位，清零
        botsum1,botsum0: buffer std_logic_vector(3 downto 0);
        --2个数码管(装瓶数)，分别对应LG3，LG2
        maxbot: in std_logic_vector(7 downto 0);
        --Maximum bottling volume（最大装瓶量的BCD码输入）,对应K15-K8          
        warn: out std_logic
        --闪烁(方波)报警
    );
end;

--用进位来对总瓶数进行计数
architecture behavioral of Bottling_counter is
begin
    process(co, clr, start)
    begin
        if clr = '1' then
            --清零
            botsum1 <= "0000";
            botsum0 <= "0000";
        elsif co'event and co = '1' and start = '1' then
            --计数
            if botsum0 = "1001" then
                --进十位
                botsum0 <= "0000";
                if botsum1 = "1001" then
                    --99变为00
                    botsum1 <= "0000";
                else
                    --(X)9变为(X+1)0
                    botsum1 <= botsum1 + 1;
                end if;
            else
                --个位上加
                botsum0 <= botsum0 + 1;
            end if;
        end if;
    end process;

    warn <= '1' when ((botsum1 & botsum0) = maxbot) else '0';
    --瓶数大于等于最大瓶数时报警
end behavioral;