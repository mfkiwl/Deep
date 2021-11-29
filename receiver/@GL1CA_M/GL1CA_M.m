classdef GL1CA_M < handle
% GPS L1 C/A�����߽��ջ�
    
    properties
        Tms            %���ջ�������ʱ��,ms
        sampleFreq     %��Ʋ���Ƶ��,Hz
        anN            %��������
        blockSize      %һ�������Ĳ�������
        blockTime      %һ��������Ӧ�Ľ��ջ�ʱ��
        blockNum       %����������
        buffI          %���ݻ���,I·����
        buffQ          %���ݻ���,Q·����
        buffSize       %���ݻ����ܲ�������
        blockPtr       %���ݸ����ڼ����,��1��ʼ
        buffHead       %�������ݵ�λ��,blockSize�ı���
        week           %GPS����
        ta             %���ջ�ʱ��,GPS��������,[s,ms,us]
        clockError     %�ۼ��Ӳ�������(������޽��ջ�ʱ�ӻ���������Ӳ�)
        deltaFreq      %���ջ�ʱ��Ƶ�����,������,�ӿ�Ϊ��
        tms            %���ջ���ǰ����ʱ��,ms,�ò���������
        CN0Thr         %�������ֵ
        almanac        %�������ǵ�����
        aziele         %ʹ�������������Ƿ�λ�Ǹ߶Ƚ�
        eleMask        %�߶Ƚ���ֵ
        svList         %���������б�
        chN            %����ͨ������
        channels       %����ͨ��
        state          %���ջ�״̬
        pos            %���ջ�λ��,γ����,deg
        rp             %���ջ�λ��,ecef
        vel            %���ջ��ٶ�,������
        vp             %���ջ��ٶ�,ecef
        att            %��̬,deg
        fn0            %�ϴε���ϵ�µļ��ٶ�
        geogInfo       %������Ϣ
        iono           %�����У������
        dtpos          %��λʱ����,ms
        tp             %�´ζ�λ��ʱ��,[s,ms,us]
        imu            %IMU����
        navFilter      %�����˲���
        vectorMode     %ʸ������ģʽ
        ns             %ָ��ǰ�洢��,��ֵ��0,�洢֮ǰ��1
        storage        %�洢���ջ����
        result         %���ջ����н��
    end
    
    methods
        function obj = GL1CA_M(conf) %���캯��
            % conf:���ջ����ýṹ��
            %----������������
            obj.Tms = conf.Tms;
            obj.sampleFreq = conf.sampleFreq;
            obj.anN = conf.anN;
            obj.blockSize = conf.blockSize;
            obj.blockTime = obj.blockSize / obj.sampleFreq;
            obj.blockNum = conf.blockNum;
            obj.buffI = cell(1,obj.anN);
            obj.buffQ = cell(1,obj.anN);
            for m=1:obj.anN
                obj.buffI{m} = zeros(obj.blockSize, obj.blockNum); %������ʽ,ÿһ��Ϊһ����
                obj.buffQ{m} = zeros(obj.blockSize, obj.blockNum);
            end
            obj.buffSize = obj.blockSize * obj.blockNum;
            obj.blockPtr = 1;
            obj.buffHead = 0;
            %----���ý��ջ�ʱ��
            obj.week = conf.week;
            obj.ta = conf.ta;
            obj.clockError = 0;
            obj.deltaFreq = 0;
            obj.tms = 0;
            %----�����������ֵ
            obj.CN0Thr = CNR_threshold(conf.CN0Thr);
            %----��������
            obj.almanac = conf.almanac;
            %----ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
            if ~isempty(obj.almanac) %���û������,azieleΪ��
                index = find(obj.almanac(:,2)==0); %��ȡ�������ǵ��к�
                rs = rs_almanac(obj.almanac(index,5:end), [obj.week,obj.ta(1)]); %����ecefλ��
                [azi, ele] = aziele_xyz(rs, conf.p0);
                obj.aziele = zeros(length(index),3); %[PRN,azi,ele]
                obj.aziele(:,1) = obj.almanac(index,1);
                obj.aziele(:,2) = azi;
                obj.aziele(:,3) = ele;
            end
            %----��ȡ���������б�
            obj.eleMask = conf.eleMask;
            obj.svList = conf.svList;
            if isempty(obj.svList) %����б�Ϊ��,ʹ���������Ŀɼ�����
                if isempty(obj.almanac) %������鲻����,����
                    error('Almanac doesn''t exist!')
                end
                obj.svList = obj.aziele(obj.aziele(:,3)>obj.eleMask,1)'; %ѡȡ�߶ȽǴ�����ֵ������
            end
            %----ͨ������
            channel_config.sampleFreq = obj.sampleFreq;
            channel_config.buffSize = obj.buffSize;
            channel_config.Tms = obj.Tms;
            channel_config.acqTime = conf.acqTime;
            channel_config.acqThreshold = conf.acqThreshold;
            channel_config.acqFreqMax = conf.acqFreqMax;
            channel_config.CN0Thr = obj.CN0Thr;
            %----����ͨ��
            obj.chN = length(obj.svList);
            obj.channels = GPS.L1CA.channel.empty; %������Ŀվ���
            for m=1:obj.anN
                for k=1:obj.chN
                    obj.channels(k+(m-1)*obj.chN) = GPS.L1CA.channel(obj.svList(k), channel_config);
                end
            end
            obj.channels = reshape(obj.channels, obj.chN, obj.anN); %ÿ����һ������
            %----���ý��ջ�״̬
            obj.state = 0;
            obj.pos = conf.p0;
            obj.rp = lla2ecef(obj.pos);
            obj.vel = [0,0,0];
            obj.vp = [0,0,0];
            obj.att = [0,0,0];
            obj.fn0 = NaN(1,3);
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
            obj.iono = NaN(1,8);
            %----���ö�λ���Ʋ���
            obj.dtpos = conf.dtpos;
            obj.tp = [obj.ta(1)+2,0,0]; %��ǰ���ջ�ʱ���2s��
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            row = floor(obj.Tms/obj.dtpos); %�洢�ռ�����
            obj.storage.ta      = zeros(row,1,'double');
            obj.storage.df      = zeros(row,1,'single');
            obj.storage.satpv   = zeros(obj.chN,6,row,'double');
            obj.storage.satmeas = zeros(obj.chN,6,row,obj.anN,'double'); %��ά����(��,��,��,��)
            obj.storage.svsel   = zeros(obj.chN,1,row,obj.anN,'uint8');
            obj.storage.satnav  = zeros(row,8,'double');
            obj.storage.pos     = zeros(row,3,'double');
            obj.storage.vel     = zeros(row,3,'single');
            obj.storage.att     =   NaN(row,3,'single');
            obj.storage.imu     =   NaN(row,6,'single');
            obj.storage.bias    =   NaN(row,6,'single');
            obj.storage.P       =   NaN(row,20,'single');
            obj.storage.motion  = zeros(row,1,'uint8'); %�˶�״̬
            obj.storage.others  =   NaN(row,12,'single');
        end
    end
    
    methods (Access = public)
        run(obj, data)                %���к���
        clean_storage(obj)            %�������ݴ洢
        set_ephemeris(obj, filename)  %Ԥ������
        save_ephemeris(obj, filename) %��������
        interact_constellation(obj)   %����������ͼ
        get_result(obj)               %��ȡ���ջ����н��
        imu_input(obj, tp, imu)       %IMU��������
        channel_vector(obj)           %ͨ���л�ʸ�����ٻ�·
    end
    
    methods (Access = private)
        acqProcess(obj)            %�������
        trackProcess(obj)          %���ٹ���
        [satpv, satmeas] = get_satmeas(obj) %��ȡ���ǲ���
        pos_init(obj)              %��ʼ����λ
        pos_normal(obj)            %������λ
    end
    
end %end classdef