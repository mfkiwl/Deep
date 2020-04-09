classdef channel < handle
% GPS L1 C/A�źŸ���ͨ��
% state:ͨ��״̬, 0-δ����, 1-�Ѽ��û������, 2-���Խ���α��α���ʲ���, 3-�����
    
    properties
        Tms             %������ʱ��,ms
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
        carrAcc         %�ز�Ƶ�ʱ仯��
        carrNco         %�ز�����������Ƶ��
        codeNco         %�뷢��������Ƶ��
        remCarrPhase    %���ٿ�ʼ����ز���λ
        remCodePhase    %���ٿ�ʼ�������λ
        carrFreq        %�������ز�Ƶ��
        codeFreq        %��������Ƶ��
        I               %I·����ֵ
        Q               %Q·����ֵ
        FLLp            %Ƶ��ǣ����Ƶ��
        PLL2            %�������໷
        DLL2            %�����ӳ�������
        carrMode        %�ز�����ģʽ
        codeMode        %�����ģʽ
        quality         %�ź�����
        tc0             %��һα�����ڵĿ�ʼʱ��,ms
        msgStage        %���Ľ����׶�(�ַ�)
        msgCnt          %���Ľ���������
        I0              %�ϴ�I·����ֵ(���ڱ���ͬ��)
        bitSyncTable    %����ͬ��ͳ�Ʊ�
        bitBuff         %���ػ���
        frameBuff       %֡����
        frameBuffPtr    %֡����ָ��
        ephe            %����
        iono            %�����У������
        log             %��־
        ns              %ָ��ǰ�洢��,��ֵ��0,�տ�ʼ����trackʱ��1
        ns0             %ָ���ϴζ�λ�Ĵ洢��,�����ʱ������ȡ��λ����ڵļ��������
        storage         %�洢���ٽ��
    end
    
    methods
        function obj = channel(PRN, conf) %���캯��
            % PRN:���Ǳ��
            % conf:ͨ�����ýṹ��
            %----���ò����Ĳ���
            obj.Tms = conf.Tms;
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
            obj.ephe = NaN(1,25);
            obj.iono = NaN(1,8);
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            obj.ns0 = 0;
            row = obj.Tms; %�洢�ռ�����
            obj.storage.dataIndex    =   NaN(row,1,'double'); %ʹ��Ԥ��NaN������,����ͨ���Ͽ�ʱ������ʾ���ж�
            obj.storage.remCodePhase =   NaN(row,1,'single');
            obj.storage.codeFreq     =   NaN(row,1,'double');
            obj.storage.remCarrPhase =   NaN(row,1,'single');
            obj.storage.carrFreq     =   NaN(row,1,'double');
            obj.storage.carrNco      =   NaN(row,1,'double');
            obj.storage.carrAcc      =   NaN(row,1,'single');
            obj.storage.I_Q          = zeros(row,6,'int32');
            obj.storage.disc         =   NaN(row,3,'single');
            obj.storage.bitFlag      = zeros(row,1,'uint8'); %�������ı��ؿ�ʼ��־
        end
    end
    
    methods (Access = public)
        acqResult = acq(obj, dataI, dataQ)         %���������ź�
        init(obj, acqResult, n)                    %��ʼ�����ٲ���
        track(obj, dataI, dataQ, deltaFreq)        %���������ź�
        ionoflag = parse(obj)                      %������������
        clean_storage(obj)                         %�������ݴ洢
        print_log(obj)                             %��ӡͨ����־
        markCurrStorage(obj)                       %��ǵ�ǰ�洢��(�����)
        [codeDisc, carrDisc] = getDiscOutput(obj)  %��ȡ��λ����ڼ��������(�����)
    end
    
end %end classdef