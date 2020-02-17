classdef channel < handle
% GPS L1 C/A信号跟踪通道
% 可以配置的数:捕获采样点数,捕获阈值,搜索频率范围
    
    % 主机参数
    properties (GetAccess = public, SetAccess = private)
        sampleFreq      %标称采样频率,Hz
        buffSize        %数据缓存总采样点数
    end
    % 卫星参数
    properties (GetAccess = public, SetAccess = private)
        PRN             %卫星编号
        CAcode          %一个周期的C/A码
    end
    % 状态参数
    properties (GetAccess = public, SetAccess = private)
        state           %通道状态
    end
    % 捕获参数
    properties (GetAccess = public, SetAccess = private)
        acqN            %捕获采样点数
        acqThreshold    %捕获阈值,最高峰与第二大峰的比值
        acqFreq         %搜索频率范围
        acqM            %搜索频率个数
        CODE            %C/A码的FFT
    end
    % 跟踪参数
    properties (GetAccess = public, SetAccess = private)
        code            %本地码发生器用的C/A码
        timeIntMs       %积分时间,ms (1,2,4,5,10,20)
        timeIntS        %积分时间,s
        codeInt         %积分时间内码片个数
        pointInt        %一个比特有多少个积分点,一个比特20ms
        trackDataTail   %跟踪开始点在数据缓存中的位置
        trackBlockSize  %跟踪数据段采样点个数
        trackDataHead   %跟踪结束点在数据缓存中的位置
        dataIndex       %跟踪开始点在文件中的位置
        carrNco         %载波发生器驱动频率
        codeNco         %码发生器驱动频率
        remCarrPhase    %跟踪开始点的载波相位
        remCodePhase    %跟踪开始点的码相位
        carrFreq        %测量的载波频率
        codeFreq        %测量的码频率
        I               %I路积分值
        Q               %Q路积分值
        FLL             %锁频环
        PLL             %锁相环
        DLL             %延迟锁定环
        carrMode        %载波跟踪模式
        codeMode        %码跟踪模式
        ts0             %下一伪码周期的开始时间,ms
    end
    % 电文解析参数
    properties (GetAccess = public, SetAccess = private)
        msgStage        %电文解析阶段(字符)
        msgCnt          %电文解析计数器
        I0              %上次I路积分值(用于比特同步)
        bitSyncTable    %比特同步统计表
        bitBuff         %比特缓存
        frameBuff       %帧缓存
        frameBuffPoint  %帧缓存指针
    end
    % 星历
    properties (GetAccess = public, SetAccess = private)
        ephemeris       %星历
        ion             %电离层校正参数
    end
    % 数据存储
    properties (GetAccess = public, SetAccess = private)
        log             %日志
        ns              %指向当前存储行,初值是0,刚开始运行track时加1
        storage         %存储跟踪结果
    end
    
    methods
        %% 构造函数
        function obj = channel(sampleFreq, buffSize, PRN, Tms)
            % sampleFreq:采样频率,Hz
            % buffSize:数据缓存总采样点数
            % PRN:卫星编号
            % Tms:接收机运行的毫秒数,用来确定存储空间的大小
            %----设置不会变的参数
            obj.sampleFreq = sampleFreq;
            obj.buffSize = buffSize;
            obj.PRN = PRN;
            obj.CAcode = GPS.L1CA.codeGene(PRN);
            %----设置通道状态
            obj.state = 0;
            %----设置捕获参数
            obj.acqN = sampleFreq*0.001 * 2; %后面乘的数表示几ms的数据
            obj.acqThreshold = 1.4;
            obj.acqFreq = -5e3:(sampleFreq/obj.acqN/2):5e3;
            obj.acqM = length(obj.acqFreq);
            index = mod(floor((0:obj.acqN-1)*1.023e6/sampleFreq),1023) + 1; %C/A码采样的索引
            obj.CODE = fft(obj.CAcode(index));
            %---申请星历空间
            obj.ephemeris = NaN(25,1);
            obj.ion = NaN(8,1);
            %----申请数据存储空间
            obj.log = "log";
            obj.ns = 0;
            obj.storage.dataIndex    = NaN(Tms,1,'double'); %使用预设NaN存数据,方便通道断开时数据显示有中断
            obj.storage.remCodePhase = NaN(Tms,1,'single');
            obj.storage.codeFreq     = NaN(Tms,1,'double');
            obj.storage.remCarrPhase = NaN(Tms,1,'single');
            obj.storage.carrFreq     = NaN(Tms,1,'double');
            obj.storage.I_Q          = zeros(Tms,6,'int32');
            obj.storage.disc         = NaN(Tms,3,'single');
            obj.storage.bitFlag      = zeros(Tms,1,'uint8'); %导航电文比特开始标志
        end
        
        %% 清理数据储存
        function clean_storage(obj)
            n = obj.ns + 1;
            obj.storage.dataIndex(n:end)    = [];
            obj.storage.remCodePhase(n:end) = [];
            obj.storage.codeFreq(n:end)     = [];
            obj.storage.remCarrPhase(n:end) = [];
            obj.storage.carrFreq(n:end)     = [];
            obj.storage.I_Q(n:end,:)        = [];
            obj.storage.disc(n:end,:)       = [];
            obj.storage.bitFlag(n:end)      = [];
        end
        
    end %end methods
    
end %end classdef