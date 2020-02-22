classdef channel < handle
% GPS L1 C/A�źŸ���ͨ��
    
    properties (GetAccess = public, SetAccess = private)
        sampleFreq      %��Ʋ���Ƶ��,Hz
        buffSize        %���ݻ����ܲ�������
        PRN             %���Ǳ��
        CAcode          %һ�����ڵ�C/A��
        state           %ͨ��״̬
        acqN            %�����������
        acqThreshold    %������ֵ,��߷���ڶ����ı�ֵ
        acqFreq         %����Ƶ�ʷ�Χ
        acqM            %����Ƶ�ʸ���
        CODE            %C/A���FFT
        code            %�����뷢�����õ�C/A��
        timeIntMs       %����ʱ��,ms (1,2,4,5,10,20)
        timeIntS        %����ʱ��,s
        codeInt         %����ʱ������Ƭ����
        pointInt        %һ�������ж��ٸ����ֵ�,һ������20ms
        trackDataTail   %���ٿ�ʼ�������ݻ����е�λ��
        trackBlockSize  %�������ݶβ��������
        trackDataHead   %���ٽ����������ݻ����е�λ��
        dataIndex       %���ٿ�ʼ�����ļ��е�λ��
        carrNco         %�ز�����������Ƶ��
        codeNco         %�뷢��������Ƶ��
        remCarrPhase    %���ٿ�ʼ����ز���λ
        remCodePhase    %���ٿ�ʼ�������λ
        carrFreq        %�������ز�Ƶ��
        codeFreq        %��������Ƶ��
        I               %I·����ֵ
        Q               %Q·����ֵ
        FLL             %��Ƶ��
        PLL             %���໷
        DLL             %�ӳ�������
        carrMode        %�ز�����ģʽ
        codeMode        %�����ģʽ
        ts0             %��һα�����ڵĿ�ʼʱ��,ms
        msgStage        %���Ľ����׶�(�ַ�)
        msgCnt          %���Ľ���������
        I0              %�ϴ�I·����ֵ(���ڱ���ͬ��)
        bitSyncTable    %����ͬ��ͳ�Ʊ�
        bitBuff         %���ػ���
        frameBuff       %֡����
        frameBuffPoint  %֡����ָ��
        iono            %�����У������
        log             %��־
        ns              %ָ��ǰ�洢��,��ֵ��0,�տ�ʼ����trackʱ��1
        storage         %�洢���ٽ��
    end
    
    % �����������ⲿ��ֵ
    properties (GetAccess = public, SetAccess = public)
        ephe            %����
    end
    
    methods
        %% ���캯��
        function obj = channel(PRN, conf)
            % PRN:���Ǳ��
            % conf:ͨ�����ýṹ��
            %----���ò����Ĳ���
            obj.sampleFreq = conf.sampleFreq;
            obj.buffSize = conf.buffSize;
            obj.PRN = PRN;
            obj.CAcode = GPS.L1CA.codeGene(PRN);
            %----����ͨ��״̬
            obj.state = 0;
            %----���ò������
            obj.acqN = obj.sampleFreq*0.001 * conf.acqTime;
            obj.acqThreshold = conf.acqThreshold;
            obj.acqFreq = -conf.acqFreqMax:(obj.sampleFreq/obj.acqN/2):conf.acqFreqMax;
            obj.acqM = length(obj.acqFreq);
            index = mod(floor((0:obj.acqN-1)*1.023e6/obj.sampleFreq),1023) + 1; %C/A�����������
            obj.CODE = fft(obj.CAcode(index));
            %---���������ռ�
            obj.ephe = NaN(25,1);
            obj.iono = NaN(8,1);
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            obj.storage.dataIndex    = NaN(conf.Tms,1,'double'); %ʹ��Ԥ��NaN������,����ͨ���Ͽ�ʱ������ʾ���ж�
            obj.storage.remCodePhase = NaN(conf.Tms,1,'single');
            obj.storage.codeFreq     = NaN(conf.Tms,1,'double');
            obj.storage.remCarrPhase = NaN(conf.Tms,1,'single');
            obj.storage.carrFreq     = NaN(conf.Tms,1,'double');
            obj.storage.I_Q          = zeros(conf.Tms,6,'int32');
            obj.storage.disc         = NaN(conf.Tms,3,'single');
            obj.storage.bitFlag      = zeros(conf.Tms,1,'uint8'); %�������ı��ؿ�ʼ��־
        end
        
        %% �������ݴ���
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