classdef GL1CA_S < handle
% GPS L1 C/A�����߽��ջ�
    
    properties (GetAccess = public, SetAccess = private)
        Tms            %���ջ�������ʱ��,ms
        sampleFreq     %��Ʋ���Ƶ��,Hz
        blockSize      %һ�������Ĳ�������
        blockNum       %����������
        buffI          %���ݻ���,I·����
        buffQ          %���ݻ���,Q·����
        buffSize       %���ݻ����ܲ�������
        blockPoint     %���ݸ����ڼ����,��1��ʼ
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
        iono           %�����У������
        dtpos          %��λʱ����,ms
        tp             %�´ζ�λ��ʱ��,[s,ms,us]
        imu            %IMU����
        ns             %ָ��ǰ�洢��,��ֵ��0,�洢֮ǰ��1
        storage        %�洢���ջ����
        result         %���ջ����н��
    end
    
    methods
        %% ���캯��
        function obj = GL1CA_S(conf)
            % conf:���ջ����ýṹ��
            %----������������
            obj.Tms = conf.Tms;
            obj.sampleFreq = conf.sampleFreq;
            obj.blockSize = conf.blockSize;
            obj.blockNum = conf.blockNum;
            obj.buffI = zeros(obj.blockSize, obj.blockNum); %������ʽ,ÿһ��Ϊһ����
            obj.buffQ = zeros(obj.blockSize, obj.blockNum);
            obj.buffSize = obj.blockSize * obj.blockNum;
            obj.blockPoint = 1;
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
            obj.iono = NaN(1,8);
            %----���ö�λ���Ʋ���
            obj.dtpos = conf.dtpos;
            obj.tp = obj.ta + [2,0,0]; %��ǰ���ջ�ʱ���2s��
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            row = floor(obj.Tms/obj.dtpos); %�洢�ռ�����
            obj.storage.ta      = zeros(row,1,'double');
            obj.storage.state   = zeros(row,1,'uint8');
            obj.storage.df      = zeros(row,1,'single');
            obj.storage.satmeas = zeros(obj.chN,8,row,'double');
            obj.storage.satnav  = zeros(row,8,'double');
            obj.storage.pos     = zeros(row,3,'double');
            obj.storage.vel     = zeros(row,3,'single');
        end
        
        %% �������ݴ洢
        function clean_storage(obj)
            % ����ͨ���ڶ���Ĵ洢�ռ�
            for k=1:obj.chN
                obj.channels(k).clean_storage;
            end
            % ��ȡ���г���,Ԫ������
            fields = fieldnames(obj.storage);
            % �������Ľ��ջ�����洢�ռ�
            n = obj.ns + 1;
            for k=1:length(fields)
                if size(obj.storage.(fields{k}),3)==1 %��ά�洢�ռ�
                    obj.storage.(fields{k})(n:end,:) = [];
                else %��ά�洢�ռ�
                    obj.storage.(fields{k})(:,:,n:end) = [];
                end
            end
            % �������ǲ�����Ϣ,Ԫ������,ÿ��ͨ��һ������
            n = size(obj.storage.satmeas,3); %�洢Ԫ�ظ���
            if n>0
                satmeas = cell(obj.chN,1);
                for k=1:obj.chN
                    satmeas{k} = reshape(obj.storage.satmeas(k,:,:),8,n)';
                end
                obj.storage.satmeas = satmeas;
            end
        end
        
        %% Ԥ������
        function set_ephemeris(obj, filename)
            if ~exist(filename, 'file') %����ļ������ھʹ���һ��
                ephemeris = []; %������Ϊephemeris,�Ǹ��ṹ��
                save(filename, 'ephemeris')
            end
            load(filename, 'ephemeris') %����Ԥ�������
            if ~isfield(ephemeris, 'GPS_ephe') %��������в�����GPS����,������GPS����
                ephemeris.GPS_ephe = NaN(32,25);
                ephemeris.GPS_iono = NaN(1,8);
                save(filename, 'ephemeris') %���浽�ļ���
            end
            obj.iono = ephemeris.GPS_iono; %��ȡ�����У������
            for k=1:obj.chN %Ϊÿ��ͨ��������
                obj.channels(k).set_ephe(ephemeris.GPS_ephe(obj.channels(k).PRN,:));
            end
        end
        
        %% ��������
        function save_ephemeris(obj, filename)
            load(filename, 'ephemeris') %����Ԥ�������
            ephemeris.GPS_iono = obj.iono; %��������У������
            for k=1:obj.chN %��ȡ������ͨ��������
                if ~isnan(obj.channels(k).ephe(1))
                    ephemeris.GPS_ephe(obj.channels(k).PRN,:) = obj.channels(k).ephe;
                end
            end
            save(filename, 'ephemeris') %���浽�ļ���
        end
        
        %% ��ӡ����ͨ����־
        function print_all_log(obj)
            disp('<----------------------------------------------------->')
            for k=1:obj.chN
                obj.channels(k).print_log;
            end
        end
        
        %% ��ʾ����ͨ�����ٽ��
        function plot_all_trackResult(obj)
            for k=1:obj.chN
                if obj.channels(k).ns>0 %ֻ���и������ݵ�ͨ��
                    plot_trackResult(obj.channels(k));
                end
            end
        end
        
        %% IMU��������
        function imu_input(obj, tp, imu)
            % tp:�´εĶ�λʱ��,s
            % imu:�´ε�IMU����
            obj.tp = sec2smu(tp); %[s,ms,us]
            obj.imu = imu;
        end
        
        %% ���������ģʽ
        function enter_deep(obj)
            obj.state = 2;
        end
        
    end %end methods
    
end %end classdef