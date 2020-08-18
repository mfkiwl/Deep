classdef GL1CA_S < handle
% GPS L1 C/A�����߽��ջ�
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
        week           %GPS����
        ta             %���ջ�ʱ��,GPS��������,[s,ms,us]
        deltaFreq      %���ջ�ʱ��Ƶ�����,������,�ӿ�Ϊ��
        tms            %���ջ���ǰ����ʱ��,ms,�ò���������
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
        iono           %�����У������
        dtpos          %��λʱ����,ms
        tp             %�´ζ�λ��ʱ��,[s,ms,us]
        imu            %IMU����
        navFilter      %�����˲���
        deepMode       %�����ģʽ
        ns             %ָ��ǰ�洢��,��ֵ��0,�洢֮ǰ��1
        storage        %�洢���ջ����
        result         %���ջ����н��
    end
    
    methods
        function obj = GL1CA_S(conf) %���캯��
            % conf:���ջ����ýṹ��
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
            %----���ý��ջ�ʱ��
            obj.week = conf.week;
            obj.ta = conf.ta;
            obj.deltaFreq = 0;
            obj.tms = 0;
            %----��������
            obj.almanac = conf.almanac;
            %----ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
            if ~isempty(obj.almanac) %���û������,azieleΪ��
                index = find(obj.almanac(:,2)==0); %��ȡ�������ǵ��к�
                rs = rs_almanac(obj.almanac(index,6:end), obj.ta(1)); %����ecefλ��
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
            %----����ͨ��
            obj.chN = length(obj.svList);
            obj.channels = GPS.L1CA.channel(obj.svList(1), channel_config);
            % �ȴ���һ����������ȷ��channel����������,�������������������
            for k=2:obj.chN
                obj.channels(k) = GPS.L1CA.channel(obj.svList(k), channel_config);
            end
            obj.channels = obj.channels'; %ת��������
            %----���ý��ջ�״̬
            obj.state = 0;
            obj.pos = conf.p0;
            obj.rp = lla2ecef(obj.pos);
            obj.vel = [0,0,0];
            obj.vp = [0,0,0];
            obj.att = [0,0,0];
            obj.iono = NaN(1,8);
            %----���ö�λ���Ʋ���
            obj.dtpos = conf.dtpos;
            obj.tp = [obj.ta(1)+2,0,0]; %��ǰ���ջ�ʱ���2s��
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            row = floor(obj.Tms/obj.dtpos); %�洢�ռ�����
            obj.storage.ta      = zeros(row,1,'double');
            obj.storage.df      = zeros(row,1,'single');
            obj.storage.satmeas = zeros(obj.chN,8,row,'double');
            obj.storage.satnav  = zeros(row,8,'double');
            obj.storage.pos     = zeros(row,3,'double');
            obj.storage.vel     = zeros(row,3,'single');
            obj.storage.att     =   NaN(row,3,'single');
            obj.storage.imu     =   NaN(row,6,'single');
            obj.storage.bias    =   NaN(row,6,'single');
            obj.storage.P       =   NaN(row,17,'single');
            obj.storage.quality = zeros(row,obj.chN,'uint8'); %��ΪɶҪ��һ��?
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
        channel_deep(obj)             %ͨ���л�����ϸ��ٻ�·
        
        print_all_log(obj)            %��ӡ����ͨ����־
        plot_all_trackResult(obj)     %��ʾ����ͨ�����ٽ��
        plot_all_I_Q(obj)
        plot_all_carrNco(obj)
        plot_all_carrAcc(obj)
        
        plot_sv_3d(obj)
        [azi, ele] = cal_aziele(obj)
        cal_iono(obj)
        plot_df(obj)
        plot_pos(obj)
        plot_vel(obj)
        plot_att(obj)
        plot_bias_gyro(obj)
        plot_bias_acc(obj)
        kml_output(obj)
    end
    
    methods (Access = private)
        acqProcess(obj)            %�������
        trackProcess(obj)          %���ٹ���
        satmeas = get_satmeas(obj) %��ȡ���ǲ���
        pos_init(obj)              %��ʼ����λ
        pos_normal(obj)            %������λ
        pos_tight(obj)             %����϶�λ
        pos_deep(obj)              %����϶�λ
    end
    
end %end classdef