classdef channel < handle
% ����B1C�źŸ���ͨ��
% state:ͨ��״̬, 0-δ����, 1-�Ѽ��û������, 2-���Խ���α��α���ʲ���, 3-ʸ������

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
        Tseq            %�����źŷ�����ʹ�õ�ʱ������
        coherentCnt     %��ɻ��ּ���,ÿ1ms��1
        coherentN       %��ɻ��ִ���
        coherentTime    %��ɻ���ʱ��,s
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
        carrCirc        %�ز���λ������,�ز���λ��α���Ӧ
        I_Q             %��ǰ6·��ɻ���I/Qֵ
        I0              %�ϴ�I_P����ֵ,���ڼ�Ƶ���ͱ���ͬ��
        Q0              %�ϴ�Q_P����ֵ
        FLLp            %Ƶ��ǣ����Ƶ��
        PLL2            %�������໷
        PLL3            %�������໷
        DLL2            %�����ӳ�������
        carrMode        %�ز�����ģʽ
        codeMode        %�����ģʽ
        discBuff        %�������������(ʸ������ʱ�õ�)
        discBuffPtr     %�������������ָ��
        varCoef         %�����������ϵ��,[α��,α����,�������]
        varValue        %��������ֵ
        tc0             %��һα�����ڵĿ�ʼʱ��,ms
        CN0Thr          %�������ֵ,��һ��handle��,����ջ�����
        CNR             %����ȼ���ģ��
        CN0             %�����ֵ,10msһ����
        lossCnt         %ʧ��������
        trackCnt        %���ټ�����,ÿ1ms��1
        IpBuff          %1�������ڵ�10��I·����ֵ(��Ƶ)
        QpBuff          %1�������ڵ�10��Q·����ֵ(��Ƶ)
        IdBuff          %1�������ڵ�10��I·����ֵ(����)
        bitSyncFlag     %����ͬ����־
        bitSyncTable    %����ͬ��ͳ�Ʊ�
        msgStage        %���Ľ����׶�(�ַ�)
        frameBuff       %֡����
        frameBuffPtr    %֡����ָ��
        ephe            %����
        iono            %�����У������
        log             %��־
        ns              %ָ��ǰ�洢��,��ֵ��0,�տ�ʼ����trackʱ��1
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
            %----�����뷢�����õ���
            code = BDS.B1C.codeGene_data(PRN);
            code = reshape([code;-code],10230*2,1);
            obj.codeData = [code(end);code;code(1)]; %������
            code = BDS.B1C.codeGene_pilot(PRN);
            code = reshape([code;-code],10230*2,1);
            obj.codePilot = [code(end);code;code(1)]; %������
            obj.codeSub = BDS.B1C.codeGene_sub(obj.PRN); %������
            %----�����źŷ�����ʹ�õ�ʱ������
            obj.Tseq = (0:obj.sampleFreq*0.001+4)/obj.sampleFreq; %���������
            %----�������ֵ
            obj.CN0Thr = conf.CN0Thr;
            %----���������ռ�
            obj.ephe = NaN(1,30);
            obj.iono = NaN(1,9);
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            row = obj.Tms; %�洢�ռ�����
            obj.storage.dataIndex    =   NaN(row,1,'double'); %ʹ��Ԥ��NaN������,����ͨ���Ͽ�ʱ������ʾ���ж�
            obj.storage.remCodePhase =   NaN(row,1,'single');
            obj.storage.codeFreq     =   NaN(row,1,'double');
            obj.storage.remCarrPhase =   NaN(row,1,'single');
            obj.storage.carrFreq     =   NaN(row,1,'double');
            obj.storage.carrNco      =   NaN(row,1,'double');
            obj.storage.carrAcc      =   NaN(row,1,'single');
            obj.storage.I_Q          = zeros(row,8,'int32');
            obj.storage.disc         =   NaN(row,3,'single');
            obj.storage.CN0          =   NaN(row,1,'single');
            obj.storage.bitFlag      = zeros(row,1,'uint8'); %���ر߽��־
        end
    end
    
    methods (Access = public)
        acqResult = acq(obj, dataI, dataQ)         %���������ź�
        init(obj, acqResult, n)                    %��ʼ�����ٲ���
        track(obj, dataI, dataQ)                   %���������ź�
        parse(obj)                                 %������������
        set_coherentTime(obj, Tms)                 %������ɻ���ʱ��
        adjust_coherentTime(obj, policy)           %������ɻ���ʱ��
        clean_storage(obj)                         %�������ݴ洢
        print_log(obj)                             %��ӡͨ����־
        %----��ͼ����
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