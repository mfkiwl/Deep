classdef channel < handle
% GPS L1 C/A�źŸ���ͨ��
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
        CODE            %C/A���FFT
        code            %�����뷢�����õ�C/A��
        Tseq            %�����źŷ�����ʹ�õ�ʱ������
        coherentCnt     %��ɻ��ּ���,ÿ1ms��1
        coherentN       %��ɻ��ִ���
        coherentTime    %��ɻ���ʱ��,s
        trackDataTail   %���ٿ�ʼ�������ݻ����е�λ��
        trackBlockSize  %�������ݶβ��������
        trackDataHead   %���ٽ����������ݻ����е�λ��
        dataIndex       %���ٿ�ʼ�����ļ��е�λ��
        carrAccS        %�����˶�������ز�Ƶ�ʱ仯��
        carrAccR        %���ջ��˶�������ز�Ƶ�ʱ仯��
        carrAccE        %�����˲������ƵĽ��ջ��˶�������ز�Ƶ�ʱ仯��
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
        codeDiscBuff    %��������������(ʸ������ʱ�õ�)
        codeDiscBuffPtr %��������������ָ��
        varCoef         %�����������ϵ��,[α��,α����,�������]
        varValue        %��������ֵ
        tc0             %��һα�����ڵĿ�ʼʱ��,ms
        CN0Thr          %�������ֵ,��һ��handle��,����ջ�����
        CNR             %����ȼ���ģ��
        CN0             %�����ֵ,20msһ����
        lossCnt         %ʧ��������
        trackCnt        %���ټ�����,ÿ1ms��1
        IpBuff          %1�������ڵ�20��I·����ֵ
        QpBuff          %1�������ڵ�20��Q·����ֵ
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
            obj.acqN = obj.sampleFreq*0.001 * conf.acqTime;
            obj.acqThreshold = conf.acqThreshold;
            obj.acqFreq = -conf.acqFreqMax:(obj.sampleFreq/obj.acqN/2):conf.acqFreqMax;
            obj.acqM = length(obj.acqFreq);
            index = mod(floor((0:obj.acqN-1)*1.023e6/obj.sampleFreq),1023) + 1; %C/A�����������
            CAcode = GPS.L1CA.codeGene(PRN);
            obj.CODE = fft(CAcode(index));
            %----�����뷢�����õ�C/A��
            obj.code = [CAcode(end),CAcode,CAcode(1)]'; %������,�����þ���˷������ۼ����;ǰ�����һ����,����ȡ��ǰ�ͺ���
            %----�����źŷ�����ʹ�õ�ʱ������
            obj.Tseq = (0:obj.sampleFreq*0.001+4)/obj.sampleFreq; %���������
            %----�������ֵ
            obj.CN0Thr = conf.CN0Thr;
            %----���������ռ�
            obj.ephe = NaN(1,25);
            obj.iono = NaN(1,8);
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
%             obj.storage.carrAccE     =   NaN(row,1,'single');
            obj.storage.I_Q          = zeros(row,6,'int32');
            obj.storage.disc         =   NaN(row,3,'single');
            obj.storage.CN0          =   NaN(row,1,'single');
            obj.storage.bitFlag      = zeros(row,1,'uint8'); %���ر߽��־
        end
    end
    
    methods (Access = public)
        acqResult = acq(obj, dataI, dataQ)         %���������ź�
        init(obj, acqResult, n)                    %��ʼ�����ٲ���
        track(obj, dataI, dataQ)                   %���������ź�
        ionoflag = parse(obj)                      %������������
        set_coherentTime(obj, Tms)                 %������ɻ���ʱ��
        adjust_coherentTime(obj, policy)           %������ɻ���ʱ��
        clean_storage(obj)                         %�������ݴ洢
        print_log(obj)                             %��ӡͨ����־
        %----��ͼ����
        varargout = plot_trackResult(obj, varargin)
        varargout = plot_I_Q(obj, varargin)
        varargout = plot_I_P(obj, varargin)
        plot_I_P_flag(obj, varargin)
        varargout = plot_codeFreq(obj, varargin)
        varargout = plot_carrFreq(obj, varargin)
        plot_carrNco(obj, varargin)
        varargout = plot_carrAcc(obj, varargin)
        varargout = plot_codeDisc(obj, varargin)
        varargout = plot_carrDisc(obj, varargin)
        varargout = plot_freqDisc(obj, varargin)
        varargout = plot_CN0(obj, varargin)
        plot_quality(obj, varargin)
    end
    
end %end classdef