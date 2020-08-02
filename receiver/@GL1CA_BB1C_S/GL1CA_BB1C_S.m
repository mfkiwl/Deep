classdef GL1CA_BB1C_S < handle
% GPS L1 C/A & BDS B1C �����߽��ջ�

    properties
        Tms            %���ջ�������ʱ��,ms
        sampleFreq     %��Ʋ���Ƶ��,Hz
        blockSize      %һ�������Ĳ�������
        blockNum       %����������
        buffI          %���ݻ���,I·����
        buffQ          %���ݻ���,Q·����
        buffSize       %���ݻ����ܲ�������
        blockPtr       %���ݸ����ڼ����,��1��ʼ
        buffHead       %�������ݵ�λ��,blockSize�ı���
        GPSflag        %�Ƿ�����GPS
        BDSflag        %�Ƿ����ñ���
        ta             %���ջ�ʱ��,��������,����ʹ��ʲôʱ��ϵͳȡ���ڸ��ٵ��ź�,[s,ms,us]
        deltaFreq      %���ջ�ʱ��Ƶ�����,������,�ӿ�Ϊ��
        tms            %���ջ���ǰ����ʱ��,ms,�ò���������
        GPS            %GPSģ��
        BDS            %BDSģ��
        state          %���ջ�״̬
        pos            %���ջ�λ��,γ����,deg
        rp             %���ջ�λ��,ecef
        vel            %���ջ��ٶ�,������
        vp             %���ջ��ٶ�,ecef
        att            %��̬,deg
        dtpos          %��λʱ����,ms
        tp             %�´ζ�λ��ʱ��,[s,ms,us]
        ns             %ָ��ǰ�洢��,��ֵ��0,�洢֮ǰ��1
        storage        %�洢���ջ����
    end
    
    methods
        function obj = GL1CA_BB1C_S(conf) %���캯��
            %----������������
            obj.Tms = conf.Tms;
            obj.sampleFreq = conf.sampleFreq;
            obj.blockSize = conf.blockSize;
            obj.blockNum = conf.blockNum;
            obj.buffI = zeros(obj.blockSize, obj.blockNum); %������ʽ,ÿһ��Ϊһ����
            obj.buffQ = zeros(obj.blockSize, obj.blockNum);
            obj.buffSize = obj.blockSize * obj.blockNum;
            obj.blockPtr = 1;
            obj.buffHead = 0;
            %----�������ǵ���ϵͳ
            obj.GPSflag = conf.GPSflag;
            obj.BDSflag = conf.BDSflag;
            %----���ý��ջ�ʱ��
            if obj.BDSflag==1
                obj.ta = conf.BDS.ta;
            end
            if obj.GPSflag==1
                obj.ta = conf.GPS.ta;
            end
            obj.deltaFreq = 0;
            obj.tms = 0;
            %----����GPSģ��
            if obj.GPSflag==1
                obj.GPS.week = conf.GPS.week;
                obj.GPS.ta = conf.GPS.ta;
                obj.GPS.almanac = conf.GPS.almanac;
                obj.GPS.eleMask = conf.GPS.eleMask;
                obj.GPS.svList = conf.GPS.svList;
                % ʹ����������������ǵķ�λ�Ǹ߶Ƚ�
                if ~isempty(obj.GPS.almanac)
                    index = find(obj.GPS.almanac(:,2)==0); %��ȡ�������ǵ��к�
                    rs = rs_almanac(obj.GPS.almanac(index,6:end), obj.GPS.ta(1)); %����ecefλ��
                    [azi, ele] = aziele_xyz(rs, conf.p0);
                    obj.GPS.aziele = zeros(length(index),3); %[PRN,azi,ele]
                    obj.GPS.aziele(:,1) = obj.GPS.almanac(index,1);
                    obj.GPS.aziele(:,2) = azi;
                    obj.GPS.aziele(:,3) = ele;
                end
                % ��ȡ���������б�
                if isempty(obj.GPS.svList) %����б�Ϊ��,ʹ���������Ŀɼ�����
                    if isempty(obj.GPS.almanac) %������鲻����,����
                        error('GPS almanac doesn''t exist!')
                    end
                    obj.GPS.svList = obj.GPS.aziele(obj.GPS.aziele(:,3)>obj.GPS.eleMask,1)'; %ѡȡ�߶ȽǴ�����ֵ������
                end
                % ͨ������
                channel_config.sampleFreq = obj.sampleFreq;
                channel_config.buffSize = obj.buffSize;
                channel_config.Tms = obj.Tms;
                channel_config.acqTime = conf.GPS.acqTime;
                channel_config.acqThreshold = conf.GPS.acqThreshold;
                channel_config.acqFreqMax = conf.GPS.acqFreqMax;
                % ����ͨ��
                obj.GPS.chN = length(obj.GPS.svList);
                obj.GPS.channels = GPS.L1CA.channel(obj.GPS.svList(1), channel_config);
                for k=2:obj.GPS.chN
                    obj.GPS.channels(k) = GPS.L1CA.channel(obj.GPS.svList(k), channel_config);
                end
                obj.GPS.channels = obj.GPS.channels'; %ת��������
            end
            %----����BDSģ��
            if obj.BDSflag==1
                obj.BDS.week = conf.BDS.week;
                obj.BDS.ta = conf.BDS.ta;
                obj.BDS.almanac = conf.BDS.almanac;
                obj.BDS.eleMask = conf.BDS.eleMask;
                obj.BDS.svList = conf.BDS.svList;
                % ʹ����������������ǵķ�λ�Ǹ߶Ƚ�
                if ~isempty(obj.BDS.almanac)
                    index = find(obj.BDS.almanac(:,2)==0); %��ȡ�������ǵ��к�
                    rs = rs_almanac(obj.BDS.almanac(index,6:end), obj.BDS.ta(1)); %����ecefλ��
                    [azi, ele] = aziele_xyz(rs, conf.p0);
                    obj.BDS.aziele = zeros(length(index),3); %[PRN,azi,ele]
                    obj.BDS.aziele(:,1) = obj.BDS.almanac(index,1);
                    obj.BDS.aziele(:,2) = azi;
                    obj.BDS.aziele(:,3) = ele;
                end
                % ��ȡ���������б�
                if isempty(obj.BDS.svList) %����б�Ϊ��,ʹ���������Ŀɼ�����
                    if isempty(obj.BDS.almanac) %������鲻����,����
                        error('BDS almanac doesn''t exist!')
                    end
                    obj.BDS.svList = obj.BDS.aziele(obj.BDS.aziele(:,3)>obj.BDS.eleMask,1)'; %ѡȡ�߶ȽǴ�����ֵ������
                end
                % ͨ������
                channel_config.sampleFreq = obj.sampleFreq;
                channel_config.buffSize = obj.buffSize;
                channel_config.Tms = obj.Tms;
                channel_config.acqThreshold = conf.BDS.acqThreshold;
                channel_config.acqFreqMax = conf.BDS.acqFreqMax;
                % ����ͨ��
                obj.BDS.chN = length(obj.BDS.svList);
                obj.BDS.channels = BDS.B1C.channel(obj.BDS.svList(1), channel_config);
                for k=2:obj.BDS.chN
                    obj.BDS.channels(k) = BDS.B1C.channel(obj.BDS.svList(k), channel_config);
                end
                obj.BDS.channels = obj.BDS.channels'; %ת��������
            end
            %----���ý��ջ�״̬
            obj.state = 0;
            obj.pos = conf.p0;
            obj.rp = lla2ecef(obj.pos);
            obj.vel = [0,0,0];
            obj.vp = [0,0,0];
            obj.att = [0,0,0];
            %----���ö�λ���Ʋ���
            obj.dtpos = conf.dtpos;
            obj.tp = [obj.ta(1)+2,0,0]; %��ǰ���ջ�ʱ���2s��
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            row = floor(obj.Tms/obj.dtpos); %�洢�ռ�����
        end
    end
    
    methods (Access = public)
        run(obj, data)                %���к���
        clean_storage(obj)            %�������ݴ洢
        print_all_log(obj)            %��ӡ����ͨ����־
        plot_all_trackResult(obj)     %��ʾ����ͨ�����ٽ��
        interact_constellation(obj)   %����������ͼ
    end
    
    methods (Access = private)
        acqProcessGPS(obj)         %GPS�������
        trackProcessGPS(obj)       %GPS���ٹ���
        acqProcessBDS(obj)         %BDS�������
        trackProcessBDS(obj)       %BDS���ٹ���
        satmeas = get_satmeas(obj) %��ȡ���ǲ���
        pos_init(obj)              %��ʼ����λ
        pos_normal(obj)            %������λ
%         pos_tight(obj)             %����϶�λ
%         pos_deep(obj)              %����϶�λ
    end
    
end %end classdef