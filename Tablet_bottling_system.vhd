library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--药片装瓶系统
entity Tablet_bottling_system is
    port(
        start, clk, clr: in std_logic;
        --启动计数，10kHz，清零
        --SWB(5),CP1(56),SWA(4)
        tabper, maxbot: in std_logic_vector(7 downto 0);
        --Tablets per bottle（每瓶药片的BCD码输入），对应K7-K0
        --Maximum bottling volume（最大装瓶量的BCD码输入）,对应K15-K8
        --K15-K8:00011000,K7-K0:01010000
        tabletsum2, tabletsum1, tabletsum0: out std_logic_vector(3 downto 0);
        --3个数码管（药片总量），分别对应LG6，LG5，LG4
        warn, green, red: out std_logic;
        --闪烁(方波)报警，绿灯，红灯
        output1, output0: out std_logic_vector(3 downto 0)
        --2个数码管（每瓶药片数或者是已装瓶数），分别对应LG3，LG2
    );
end Tablet_bottling_system;

architecture behavioral of Tablet_bottling_system is
    --分频模块
    component Frequency_divider
        port(
            highfre: in std_logic;
            --High frequency（高频，10KHz）
            lowfre: out std_logic
            --Low frequency（低频，0.5Hz）
        );
    end component;

    --药片总量计数器模块
    component Tablet_total_counter
        port(
            start, lowfre, clr: in std_logic;
            --启动计数，0.5赫兹，清零
            green, red: buffer std_logic;
            tabletsum2, tabletsum1, tabletsum0: buffer std_logic_vector(3 downto 0)
            --3个数码管（药片总量），分别对应LG6，LG5，LG4
        );
    end component;

    --单瓶药片数计数器模块
    component Single_vial_tablet_counter
        port(
            start, lowfre, clr: in std_logic;
            --启动计数，0.5赫兹，清零
            tabper: in std_logic_vector(7 downto 0);
            --Tablets per bottle（每瓶药片的BCD码输入），对应K7-K0
            co: out std_logic;
            --carry-over，当前瓶满后的进位
            persum1, persum0: buffer std_logic_vector(3 downto 0)
            --2个数码管（每瓶药片数），分别对应LG3，LG2
        );
    end component;

    --装瓶量计数器模块
    component Bottling_counter
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
    end component;

    --选择器模块
    component Selector
        port(
            start: in std_logic;
            --启动计数
            botsum1, botsum0, persum1, persum0: in std_logic_vector(3 downto 0);
            --2个数码管(装瓶数)，2个数码管（每瓶药片数）
            output1,output0: out std_logic_vector(3 downto 0)
            --2个数码管，选择装瓶数或每瓶药片数中的一组，分别对应LG3，LG2
        );
    end component;
    
    --警报器模块
	component Siren is
		port(
			highfre: in std_logic; 
			--High frequency（高频，10KHz）
			lowfre: out std_logic; 
			--Low frequency（低频，0.5Hz）
			warn: in std_logic 
			--Warn signal（警告信号）
		);
	end component;

    signal lowfre,co,a,b: std_logic;
    signal botsum1,botsum0,persum1,persum0: std_logic_vector(3 downto 0);

begin
	--分频模块   对5kHz的脉冲进行分频
    u1: Frequency_divider port map(clk,lowfre);
    --药片总量计数模块  用时钟脉冲来对药片数进行计数
    u2: Tablet_total_counter port map(start,lowfre,clr,green,red,tabletsum2,tabletsum1,tabletsum0);
    --单瓶药片计数模块  用时钟脉冲来对药片数进行计数
    u3: Single_vial_tablet_counter port map(start,lowfre,clr,tabper,co,persum1,persum0);
    --装瓶量计数模块  用进位来对总瓶数进行计数
    u4: Bottling_counter port map(start,a,clr,botsum1,botsum0,maxbot,b);
    a <= lowfre when tabper = 1 else co;
    --报警器模块，根据报警信号输出报警方波
    u5: Siren  port map(clk,warn,b);
    --选择器模块  对开始暂停信号进行判断决定输出瓶数还是当前药片数
    u6: Selector port map(start,botsum1,botsum0,persum1,persum0,output1,output0);
end behavioral;