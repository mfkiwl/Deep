classdef GL1CA_BB1C_S < handle
% GPS L1 C/A & BDS B1C �����߽��ջ�
% state:���ջ�״̬, 0-��ʼ��, 1-����, 2-�����, 3-�����
% deepMode:�����ģʽ, 1-�뻷ʸ������, 2-�뻷�ز�����ʸ������

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
        GPSweek        %GPS����
        BDSweek        %��������
        ta             %���ջ�ʱ��,GPS��������,[s,ms,us]
        dtBDS          %GPSʱ��Ա���ʱ��ʱ���,[s,ms,us],tBDS=tGPS-dtBDS
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
        % �������ر���������ϳ�ʼ��ʱ�Ÿ�ֵ
        imu            %IMU����
        navFilter      %�����˲���
        deepMode       %�����ģʽ
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
            obj.GPSweek = conf.GPSweek;
            obj.BDSweek = conf.BDSweek;
            obj.ta = conf.ta;
            obj.dtBDS = [14,0,0]; %GPSʱ�ȱ���ʱ��14s
            obj.deltaFreq = 0;
            obj.tms = 0;
            %----����GPSģ��
            if obj.GPSflag==1
                obj.GPS.almanac = conf.GPS.almanac;
                obj.GPS.eleMask = conf.GPS.eleMask;
                obj.GPS.svList = conf.GPS.svList;
                % ʹ����������������ǵķ�λ�Ǹ߶Ƚ�
                if ~isempty(obj.GPS.almanac)
                    index = find(obj.GPS.almanac(:,2)==0); %��ȡ�������ǵ��к�
                    rs = rs_almanac(obj.GPS.almanac(index,6:end), obj.ta(1)); %����ecefλ��
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
                obj.GPS.iono = NaN(1,8); %GPS��������
            end
            %----����BDSģ��
            if obj.BDSflag==1
                obj.BDS.almanac = conf.BDS.almanac;
                obj.BDS.eleMask = conf.BDS.eleMask;
                obj.BDS.svList = conf.BDS.svList;
                % ʹ����������������ǵķ�λ�Ǹ߶Ƚ�
                if ~isempty(obj.BDS.almanac)
                    index = find(obj.BDS.almanac(:,2)==0); %��ȡ�������ǵ��к�
                    rs = rs_almanac(obj.BDS.almanac(index,6:end), obj.ta(1)-14); %����ecefλ��
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
                obj.BDS.iono = NaN(1,9); %BDS��������
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
            obj.storage.ta        = zeros(row,1,'double');
            obj.storage.df        = zeros(row,1,'single');
            obj.storage.satnav    = zeros(row,8,'double');
            obj.storage.satnavGPS = zeros(row,8,'double');
            obj.storage.satnavBDS = zeros(row,8,'double');
            obj.storage.pos       = zeros(row,3,'double');
            obj.storage.vel       = zeros(row,3,'single');
            obj.storage.att     =   NaN(row,3,'single');
            obj.storage.imu     =   NaN(row,6,'single');
            obj.storage.bias    =   NaN(row,6,'single');
            obj.storage.P       =   NaN(row,17,'single');
        end
    end
    
    methods (Access = public)
        run(obj, data)                %���к���
        clean_storage(obj)            %�������ݴ洢
        set_ephemeris(obj, filename)  %Ԥ������
        save_ephemeris(obj, filename) %��������
        print_all_log(obj)            %��ӡ����ͨ����־
        plot_all_trackResult(obj)     %��ʾ����ͨ�����ٽ��
        interact_constellation(obj)   %����������ͼ
%         get_result(obj)               %��ȡ���ջ����н��
        imu_input(obj, tp, imu)       %IMU��������
        channel_deep(obj)             %ͨ���л�����ϸ��ٻ�·
        
%         plot_sv_3d(obj)
        plot_df(obj)
        plot_pos(obj)
        plot_vel(obj)
        plot_att(obj)
        plot_bias_gyro(obj)
        plot_bias_acc(obj)
        kml_output(obj)
    end
    
    methods (Access = private)
        acqProcessGPS(obj)             %GPS�������
        trackProcessGPS(obj)           %GPS���ٹ���
        acqProcessBDS(obj)             %BDS�������
        trackProcessBDS(obj)           %BDS���ٹ���
        satmeas = get_satmeas_GPS(obj) %��ȡGPS���ǲ���
        satmeas = get_satmeas_BDS(obj) %��ȡBDS���ǲ���
        pos_init(obj)                  %��ʼ����λ
        pos_normal(obj)                %������λ
%         pos_tight(obj)                 %����϶�λ
        pos_deep(obj)                  %����϶�λ
    end
    
end %end classdef