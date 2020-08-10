classdef channel < handle
% ����B1C�źŸ���ͨ��
% state:ͨ��״̬, 0-δ����, 1-�Ѽ��û������, 2-���Խ���α��α���ʲ���, 3-�����

    properties
        Tms             %������ʱ��,ms,����ȷ����ͼ�ĺ�����
        sampleFreq      %��Ʋ���Ƶ��,Hz
        buffSize        %���ݻ����ܲ�������
        PRN             %���Ǳ��
        state           %ͨ��״̬
        
        acqN            %�����������
        acqThreshold    %������ֵ,��߷���ڶ����ı�ֵ
        acqFreq         %����Ƶ�ʷ�Χ
        acqM            %����Ƶ�ʸ���
        CODE            %�����õĵ�Ƶ�����FFT(�����ز�,ǰ�油��)
        
        codeData        %�����뷢������������(�����ز�)
        codePilot       %�����뷢������Ƶ����(�����ز�)
        codeSub         %�����뷢������Ƶ����
        timeIntMs       %����ʱ��,ms
        timeIntS        %����ʱ��,s
        pointInt        %һ�������ж��ٸ����ֵ�,һ������10ms
        codeTarget      %��ǰ����Ŀ������λ
        subPhase        %��ǰ������λ
        carrDiscFlag    %�ز���������־,0-�����޷����м�����,1-�����޷����м�����
        
        trackDataTail   %���ٿ�ʼ�������ݻ����е�λ��
        trackBlockSize  %�������ݶβ��������
        trackDataHead   %���ٽ����������ݻ����е�λ��
        dataIndex       %���ٿ�ʼ�����ļ��е�λ��
        
        carrAccS        %�����˶�������ز�Ƶ�ʱ仯��
        carrAccR        %���ջ��˶�������ز�Ƶ�ʱ仯��
        carrNco         %�ز�����������Ƶ��
        codeNco         %�뷢��������Ƶ��
        remCarrPhase    %���ٿ�ʼ����ز���λ
        remCodePhase    %���ٿ�ʼ�������λ
        carrFreq        %�������ز�Ƶ��
        codeFreq        %��������Ƶ��
        carrVar         %�ز��������������
        codeVar         %��������������
        I               %I·����ֵ(��Ƶ����)
        Q               %Q·����ֵ(��Ƶ����)
        Id              %���ݷ�������ֵ
        Ip              %��Ƶ��������ֵ
        PLL2            %�������໷
        DLL2            %�����ӳ�������
        carrMode        %�ز�����ģʽ
        codeMode        %�����ģʽ
        tc0             %��һα�����ڵĿ�ʼʱ��,ms
        
        msgStage        %���Ľ����׶�(�ַ�)
        msgCnt          %���Ľ���������
        Ip0             %�ϴε�Ƶ��������ֵ(���ڱ���ͬ��)
        bitSyncTable    %����ͬ��ͳ�Ʊ�
        bitBuff         %���ػ���
        frameBuff       %֡����
        frameBuffPtr    %֡����ָ��
        ephe            %����
        iono            %�����У������
        
        log             %��־
        ns              %ָ��ǰ�洢��,��ֵ��0,�տ�ʼ����trackʱ��1
        storage         %�洢���ٽ��
        
        quality         %�ź�����
        SQI             %�ź�����ָʾ��
        ns0             %ָ���ϴζ�λ�Ĵ洢��,�����ʱ������ȡ��λ����ڵļ��������
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
            %----����ͨ��״̬
            obj.state = 0;
            %----���ò������
            obj.acqN = obj.sampleFreq*0.02; %ȡ20ms����
            obj.acqThreshold = conf.acqThreshold;
            N = obj.sampleFreq*0.01; %һ��α�����ڲ�������
            obj.acqFreq = -conf.acqFreqMax:(obj.sampleFreq/N/2):conf.acqFreqMax;
            obj.acqM = length(obj.acqFreq);
            B1Ccode = BDS.B1C.codeGene_pilot(PRN); %����B1C��Ƶ����
            B1Ccode = reshape([B1Ccode;-B1Ccode],10230*2,1)'; %�����ز�,������
            index = floor((0:N-1)*1.023e6*2/obj.sampleFreq) + 1; %�����������
            codes = B1Ccode(index);
            code = [zeros(1,N), codes]; %ǰ�油��
            obj.CODE = fft(code);
            %---���������ռ�
            obj.ephe = NaN(1,30);
            obj.iono = NaN(1,9);
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
            obj.storage.I_Q          = zeros(row,8,'int32');
            obj.storage.disc         =   NaN(row,5,'single');
            obj.storage.bitFlag      = zeros(row,1,'uint8'); %�������ı��ؿ�ʼ��־
            obj.storage.quality      = zeros(row,1,'uint8');
        end
    end
    
    methods (Access = public)
        acqResult = acq(obj, dataI, dataQ)         %���������ź�
        init(obj, acqResult, n)                    %��ʼ�����ٲ���
        track(obj, dataI, dataQ, deltaFreq)        %���������ź�
        parse(obj)                                 %������������
        clean_storage(obj)                         %�������ݴ洢
        print_log(obj)                             %��ӡͨ����־
        
        % �����
        markCurrStorage(obj)                       %��ǵ�ǰ�洢��
        [codeDisc, carrDisc] = getDiscOutput(obj)  %��ȡ��λ����ڼ��������
        
        % ͨ����ͼ
        plot_trackResult(obj)
        plot_I_Q(obj)
        plot_I_P(obj)
        plot_I_P_flag(obj)
        plot_codeFreq(obj)
        plot_carrFreq(obj)
        plot_carrNco(obj)
        plot_carrAcc(obj)
        plot_codeDisc(obj)
        plot_carrDisc(obj)
        plot_freqDisc(obj)
        plot_quality(obj)
    end
    
end %end classdef