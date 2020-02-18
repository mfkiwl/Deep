classdef channel < handle
% GPS L1 C/A�źŸ���ͨ��
% �������õ���:�����������,������ֵ,����Ƶ�ʷ�Χ
    
    % ��������
    properties (GetAccess = public, SetAccess = private)
        sampleFreq      %��Ʋ���Ƶ��,Hz
        buffSize        %���ݻ����ܲ�������
    end
    % ���ǲ���
    properties (GetAccess = public, SetAccess = private)
        PRN             %���Ǳ��
        CAcode          %һ�����ڵ�C/A��
    end
    % ״̬����
    properties (GetAccess = public, SetAccess = private)
        state           %ͨ��״̬
    end
    % �������
    properties (GetAccess = public, SetAccess = private)
        acqN            %�����������
        acqThreshold    %������ֵ,��߷���ڶ����ı�ֵ
        acqFreq         %����Ƶ�ʷ�Χ
        acqM            %����Ƶ�ʸ���
        CODE            %C/A���FFT
    end
    % ���ٲ���
    properties (GetAccess = public, SetAccess = private)
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
    end
    % ���Ľ�������
    properties (GetAccess = public, SetAccess = private)
        msgStage        %���Ľ����׶�(�ַ�)
        msgCnt          %���Ľ���������
        I0              %�ϴ�I·����ֵ(���ڱ���ͬ��)
        bitSyncTable    %����ͬ��ͳ�Ʊ�
        bitBuff         %���ػ���
        frameBuff       %֡����
        frameBuffPoint  %֡����ָ��
    end
    % ����
    properties (GetAccess = public, SetAccess = public)
        ephe            %����
        iono            %�����У������
    end
    % ���ݴ洢
    properties (GetAccess = public, SetAccess = private)
        log             %��־
        ns              %ָ��ǰ�洢��,��ֵ��0,�տ�ʼ����trackʱ��1
        storage         %�洢���ٽ��
    end
    
    methods
        %% ���캯��
        function obj = channel(sampleFreq, buffSize, PRN, Tms)
            % sampleFreq:����Ƶ��,Hz
            % buffSize:���ݻ����ܲ�������
            % PRN:���Ǳ��
            % Tms:���ջ����еĺ�����,����ȷ���洢�ռ�Ĵ�С
            %----���ò����Ĳ���
            obj.sampleFreq = sampleFreq;
            obj.buffSize = buffSize;
            obj.PRN = PRN;
            obj.CAcode = GPS.L1CA.codeGene(PRN);
            %----����ͨ��״̬
            obj.state = 0;
            %----���ò������
            obj.acqN = sampleFreq*0.001 * 2; %����˵�����ʾ��ms������
            obj.acqThreshold = 1.4;
            obj.acqFreq = -5e3:(sampleFreq/obj.acqN/2):5e3;
            obj.acqM = length(obj.acqFreq);
            index = mod(floor((0:obj.acqN-1)*1.023e6/sampleFreq),1023) + 1; %C/A�����������
            obj.CODE = fft(obj.CAcode(index));
            %---���������ռ�
            obj.ephe = NaN(25,1);
            obj.iono = NaN(8,1);
            %----�������ݴ洢�ռ�
            obj.log = "log";
            obj.ns = 0;
            obj.storage.dataIndex    = NaN(Tms,1,'double'); %ʹ��Ԥ��NaN������,����ͨ���Ͽ�ʱ������ʾ���ж�
            obj.storage.remCodePhase = NaN(Tms,1,'single');
            obj.storage.codeFreq     = NaN(Tms,1,'double');
            obj.storage.remCarrPhase = NaN(Tms,1,'single');
            obj.storage.carrFreq     = NaN(Tms,1,'double');
            obj.storage.I_Q          = zeros(Tms,6,'int32');
            obj.storage.disc         = NaN(Tms,3,'single');
            obj.storage.bitFlag      = zeros(Tms,1,'uint8'); %�������ı��ؿ�ʼ��־
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