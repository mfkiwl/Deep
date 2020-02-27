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
        iono           %�����У������
        dtpos          %��λʱ����,ms
        tp             %�´ζ�λ��ʱ��,[s,ms,us]
        ns             %ָ��ǰ�洢��,��ֵ��0,�洢֮ǰ��1
        storage        %�洢���ջ����
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
                obj.aziele = zeros(length(index),3); %[ID,azi,ele]
                obj.aziele(:,1) = obj.almanac(index,1);
                obj.aziele(:,2:3) = aziele_almanac(obj.almanac(index,6:end), obj.ta(1), conf.p0);
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
            obj.iono = NaN(1,8);
            %----���ö�λ���Ʋ���
            obj.dtpos = conf.dtpos;
            obj.tp = obj.ta + [2,0,0]; %��ǰ���ջ�ʱ���2s��
            %----�������ݴ洢�ռ�
            obj.ns = 0;
            row = floor(obj.Tms/obj.dtpos); %�洢�ռ�����
            obj.storage.ta     = zeros(row,1,'double');
            obj.storage.state  = zeros(row,1,'uint8');
            obj.storage.satnav = zeros(row,11,'double');
            obj.storage.sat    = zeros(obj.chN,8,row,'double');
            obj.storage.df     = zeros(row,1,'double');
        end
        
        %% ���к���
        function run(obj, data)
            % data:��������,����,�ֱ�ΪI/Q����,ԭʼ��������
            % ʹ��Ƕ�׺���д,��߳���ɶ���,Ҫ��ֻ֤��obj��ȫ�ֱ���
            %----�����ݻ������
            obj.buffI(:,obj.blockPoint) = data(1,:); %�����ݻ����ָ�������,���ü�ת��,�Զ����������
            obj.buffQ(:,obj.blockPoint) = data(2,:);
            obj.buffHead = obj.blockPoint * obj.blockSize; %�������ݵ�λ��
            obj.blockPoint = obj.blockPoint + 1; %ָ����һ��
            if obj.blockPoint>obj.blockNum
                obj.blockPoint = 1;
            end
            obj.tms = obj.tms + 1; %��ǰ����ʱ���1ms
            %----���½��ջ�ʱ��
            fs = obj.sampleFreq * (1+obj.deltaFreq); %������Ĳ���Ƶ��
            obj.ta = timeCarry(obj.ta + sample2dt(obj.blockSize, fs));
            %----����
            if mod(obj.tms,1000)==0 %1s����һ��
                acqProcess;
            end
            %----����
            trackProcess;
            %----��λ
            dtp = (obj.ta-obj.tp) * [1;1e-3;1e-6]; %��ǰ���ջ�ʱ���붨λʱ��֮��,s
            if dtp>=0 %��λʱ�䵽��
                % ��ȡ���ǲ�����Ϣ
                sat = getSat(dtp, fs);
                % λ���ٶȽ���
                sv = sat(~isnan(sat(:,1)),:); %ѡ�����ݵ���
                satnav = satnavSolve(sv, obj.rp);
                if ~isnan(satnav(1))
                    obj.pos = satnav(1:3);
                    obj.rp = satnav(4:6);
                    obj.vel = satnav(7:9);
                end
                % ���ջ�ʱ������
                
                % ���ݴ洢
                obj.ns = obj.ns+1; %ָ��ǰ�洢��
                m = obj.ns;
                obj.storage.ta(m) = obj.tp * [1;1e-3;1e-6]; %��λʱ��,s
                obj.storage.state(m) = obj.state;
                obj.storage.satnav(m,:) = satnav;
                obj.storage.sat(:,:,m) = sat;
                obj.storage.df(m) = obj.deltaFreq;
                % ���ջ�ʱ�ӳ�ʼ��
                if obj.state==0
                    clockInit(satnav(10));
                end
                % �����´ζ�λʱ��
                obj.tp = timeCarry(obj.tp + [0,obj.dtpos,0]);
            end
            
            %% �������
            function acqProcess
                for k=1:obj.chN
                    if obj.channels(k).state~=0 %���ͨ���Ѽ���,��������
                        continue
                    end
                    n = obj.channels(k).acqN; %�����������
                    acqResult = obj.channels(k).acq(obj.buffI((end-2*n+1):end), obj.buffQ((end-2*n+1):end));
                    if ~isempty(acqResult) %����ɹ����ʼ��ͨ��
                        obj.channels(k).init(acqResult, obj.tms/1000*obj.sampleFreq);
                    end
                end
            end
            
            %% ���ٹ���
            function trackProcess
                for k=1:obj.chN
                    if obj.channels(k).state==0 %���ͨ��δ����,��������
                        continue
                    end
                    while 1
                        %----�ж��Ƿ��������ĸ�������
                        if mod(obj.buffHead-obj.channels(k).trackDataHead,obj.buffSize)>(obj.buffSize/2)
                            break
                        end
                        %----�źŴ���
                        n1 = obj.channels(k).trackDataTail;
                        n2 = obj.channels(k).trackDataHead;
                        if n2>n1
                            obj.channels(k).track(obj.buffI(n1:n2), obj.buffQ(n1:n2), obj.deltaFreq);
                        else
                            obj.channels(k).track([obj.buffI(n1:end),obj.buffI(1:n2)], ...
                                                  [obj.buffQ(n1:end),obj.buffQ(1:n2)], obj.deltaFreq);
                        end
                        %----������������
                        ionoflag = obj.channels(k).parse;
                        %----��ȡ�����У������
                        if ionoflag==1
                            obj.iono = obj.channels(k).iono;
                        end
                    end
                end
            end
            
            %% ��ȡ���ǲ���
            function sat = getSat(dtp, fs)
                % dtp:��ǰ�����㵽��λ���ʱ���,s,dtp=ta-tp
                % fs:���ջ���Ƶ��У����Ĳ���Ƶ��,Hz
                % sat:[x,y,z,vx,vy,vz,rho,rhodot]
                lamda = 0.190293672798365; %�ز�����,m,299792458/1575.42e6
                sat = NaN(obj.chN,8);
                for k=1:obj.chN
                    if obj.channels(k).state==2 %ֻҪ�����ϵ�ͨ�����ܲ�,���ﲻ�ù��ź�����,ѡ�Ƕ�������
                        %----���㶨λ�����ӵ���ķ���ʱ��
                        dn = mod(obj.buffHead-obj.channels(k).trackDataTail+1, obj.buffSize) - 1; %ǡ�ó�ǰһ��������ʱdn=-1
                        dtc = dn / fs; %��ǰ�����㵽���ٵ��ʱ���,dtc=ta-tc
                        dt = dtc - dtp; %��λ�㵽���ٵ��ʱ���,dtc-dtp=(ta-tc)-(ta-tp)=tp-tc=dt
                        codePhase = obj.channels(k).remCodePhase + obj.channels(k).codeNco*dt; %��λ������λ
                        te = [floor(obj.channels(k).tc0/1e3), mod(obj.channels(k).tc0,1e3), 0] + ...
                              [0, floor(codePhase/1023), mod(codePhase/1023,1)*1e3]; %��λ���뷢��ʱ��
                        %----�����źŷ���ʱ������λ���ٶ�
                        % [sat(k,1:6), corr] =LNAV.rsvs_emit(obj.channels(k).ephe(5:end), te, obj.rp, obj.iono, obj.pos);
                        %----�����źŷ���ʱ������λ���ٶȼ��ٶ�
                        [rsvsas, corr] =LNAV.rsvsas_emit(obj.channels(k).ephe(5:end), te, obj.rp, obj.iono, obj.pos);
                        sat(k,1:6) = rsvsas(1:6);
                        %----���������˶�������ز�Ƶ�ʱ仯��(��ʱ����Ʋ���,ʹ����һʱ�̵�λ�ü������,����ʸ����𲻴�)
                        rs = rsvsas(1:3); %����λ��ʸ��
                        vs = rsvsas(4:6); %�����ٶ�ʸ��
                        as = rsvsas(7:9); %���Ǽ��ٶ�ʸ��
                        rps = rs - obj.rp; %���ջ�ָ������λ��ʸ��
                        R = norm(rps); %���ջ������ǵľ���
                        carrAcc = -(as*rps'+vs*vs'-(vs*rps'/R)^2)/R / lamda; %�ز�Ƶ�ʱ仯��,Hz/s
                        obj.channels(k).set_carrAcc(carrAcc); %���ø���ͨ���ز�Ƶ�ʱ仯��
                        %----����α��α����
                        tt = (obj.tp-te) * [1;1e-3;1e-6]; %�źŴ���ʱ��,s
                        doppler = obj.channels(k).carrFreq/1575.42e6 + obj.deltaFreq; %��һ��,���ջ��ӿ�ʹ�����ձ�С(�������±�Ƶ)
                        sat(k,7:8) = satmeasCorr(tt, doppler, corr);
                    end
                end
            end
            
            %% ���ջ�ʱ�ӳ�ʼ��
            function clockInit(dtr)
                % dtr:���ǵ�������õ����Ӳ�,s
                if isnan(dtr) %û���Ӳ�ֱ���˳�
                    return
                end
                if abs(dtr)>0.1e-3 %�Ӳ����0.1ms,�������ջ�ʱ��
                    obj.ta = obj.ta - sec2smu(dtr);
                    obj.ta = timeCarry(obj.ta);
                    obj.tp(1) = obj.ta(1); %�����´ζ�λʱ��
                    obj.tp(2) = ceil(obj.ta(2)/obj.dtpos) * obj.dtpos;
                    obj.tp = timeCarry(obj.tp);
                else %�Ӳ�С��0.1ms����ʼ������
                    obj.state = 1;
                end
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
                obj.channels(k).ephe = ephemeris.GPS_ephe(obj.channels(k).PRN,:);
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
        
        %% �������ݴ���
        function clean_storage(obj)
            % ����ͨ���ڶ���Ĵ洢�ռ�
            for k=1:obj.chN
                obj.channels(k).clean_storage;
            end
            % �������Ľ��ջ�����洢�ռ�
            n = obj.ns + 1;
            obj.storage.ta(n:end)       = [];
            obj.storage.state(n:end)    = [];
            obj.storage.satnav(n:end,:) = [];
            obj.storage.sat(:,:,n:end)  = [];
            obj.storage.df(n:end)       = [];
            % ɾ�����ջ�δ��ʼ��ʱ������
            index = find(obj.storage.state==0);
            obj.storage.ta(index)       = [];
            obj.storage.state(index)    = [];
            obj.storage.satnav(index,:) = [];
            obj.storage.sat(:,:,index)  = [];
            obj.storage.df(index)       = [];
            % �������ǲ�����Ϣ,Ԫ������,ÿ��ͨ��һ������
            n = size(obj.storage.sat,3); %�洢Ԫ�ظ���
            if n>0
                sat = cell(obj.chN,1);
                for k=1:obj.chN
                    sat{k} = reshape(obj.storage.sat(k,:,:),8,n)';
                end
                obj.storage.sat = sat;
            end
        end
        
        %% ��ӡͨ����־
        function print_log(obj)
            for k=1:obj.chN
                fprintf('PRN %d\n', obj.channels(k).PRN); %ʹ��\r\n���һ������
                n = length(obj.channels(k).log); %ͨ����־������
                if n>0 %�����־������,���д�ӡ
                    for m=1:n
                        disp(obj.channels(k).log(m));
                    end
                end
                disp(' ');
            end
        end
        
        %% ��ʾ���ٽ��
        function show_trackResult(obj)
            for k=1:obj.chN %��������ͨ��
                if obj.channels(k).ns==0 %����û���ٵ�ͨ��
                    continue
                end
                figure('Position', screenBlock(1140,670,0.5,0.5)); %�½���ͼ����
                ax1 = axes('Position', [0.08, 0.4, 0.38, 0.53]);
                hold(ax1,'on');
                axis(ax1, 'equal');
                title(['PRN = ',sprintf('%d',obj.channels(k).PRN)])
                ax2 = axes('Position', [0.53, 0.7 , 0.42, 0.25]);
                hold(ax2,'on');
                ax3 = axes('Position', [0.53, 0.38, 0.42, 0.25]);
                hold(ax3,'on');
                grid(ax3,'on');
                ax4 = axes('Position', [0.53, 0.06, 0.42, 0.25]);
                hold(ax4,'on');
                grid(ax4,'on');
                ax5 = axes('Position', [0.05, 0.06, 0.42, 0.25]);
                hold(ax5,'on');
                grid(ax5,'on');
                t = obj.channels(k).storage.dataIndex/obj.sampleFreq; %ʹ�ò���������ʱ��
                % I/Qͼ
                plot(ax1, obj.channels(k).storage.I_Q(1001:end,1),obj.channels(k).storage.I_Q(1001:end,4), ...
                          'LineStyle','none', 'Marker','.')
                % I_Pͼ
                plot(ax2, t, double(obj.channels(k).storage.I_Q(:,1))) %����������������Ҫһ��
                set(ax2, 'XLim',[1,obj.Tms/1000])
                % �ز�Ƶ��
                plot(ax4, t, obj.channels(k).storage.carrFreq, 'LineWidth',1.5)
                set(ax4, 'XLim',[1,obj.Tms/1000])
                % �ز�Ƶ�ʱ仯��
                plot(ax5, t, obj.channels(k).storage.carrAcc, 'LineWidth',1.5)
                set(ax5, 'XLim',[1,obj.Tms/1000])
            end
        end
        
        %% ��ʾ����ͼ
        function plot_constellation(obj)
            if isempty(obj.almanac) %���û�����鲻��ͼ
                disp('Almanac doesn''t exist!')
                return
            end
            %----��ѡ�߶ȽǴ���0������
            index = find(obj.aziele(:,3)>0); %�߶ȽǴ���0����������
            PRN = obj.aziele(index,1);
            azi = mod(obj.aziele(index,2),360)/180*pi; %��λ��ת�ɻ���,0~360��
            ele = obj.aziele(index,3); %�߶Ƚ�,deg
            %----ͳ�Ƹ��ٵ�������
            svTrack = obj.svList([obj.channels.ns]~=0);
            %----��ͼ
            figure
            ax = polaraxes; %������������
            ax.NextPlot = 'add';
            ax.RLim = [0,90]; %�߶ȽǷ�Χ
            ax.RDir = 'reverse'; %�߶Ƚ�������90��
            ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
            ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
            ax.ThetaZeroLocation = 'top'; %��λ��0����
            for k=1:length(PRN) %�������и߶ȽǴ���0������
                % �͸߶Ƚ�����,͸��
                if ele(k)<obj.eleMask
                    polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                                 'MarkerEdgeColor',[127,127,127]/255, 'MarkerFaceAlpha',0.5)
                    text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                        'VerticalAlignment','middle');
                    continue
                end
                % û���ٵ�����,�߿�����
                if ~ismember(PRN(k),svTrack)
                    polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                                 'MarkerEdgeColor',[127,127,127]/255)
                    text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                        'VerticalAlignment','middle');
                    continue
                end
                % ���ٵ�������,�߿�Ӵ�,�����Ҽ��˵�,�μ�uicontextmenu help
                polarscatter(azi(k),ele(k), 220, 'MarkerFaceColor',[65,180,250]/255, ...
                             'MarkerEdgeColor',[127,127,127]/255, 'LineWidth',2)
                t = text(azi(k),ele(k),num2str(PRN(k)), 'HorizontalAlignment','center', ...
                                                        'VerticalAlignment','middle');
                c = uicontextmenu; %����Ŀ¼
                t.UIContextMenu = c; %Ŀ¼�ӵ�text��,��Ϊ���ָ�����ԲȦ
                ch = find(obj.svList==PRN(k)); %�ÿ����ǵ�ͨ����
                uimenu(c, 'MenuSelectedFcn',@customplot, 'UserData',ch, 'Text','I_Q'); %����Ŀ¼��
                uimenu(c, 'MenuSelectedFcn',@customplot, 'UserData',ch, 'Text','I_P');
                uimenu(c, 'MenuSelectedFcn',@customplot, 'UserData',ch, 'Text','I_P(flag)');
                uimenu(c, 'MenuSelectedFcn',@customplot, 'UserData',ch, 'Text','carrFreq');
                uimenu(c, 'MenuSelectedFcn',@customplot, 'UserData',ch, 'Text','codeFreq');
            end
            %----�ص�����
            function customplot(source, ~)
                % ����Ҫ�������������(source, callbackdata),���ֲ���Ҫ
                % ��һ������matlab.ui.container.Menu����
                % �ڶ�������ui.eventdata.ActionData
                % source.UserDataΪͨ����
                switch source.Text
                    case 'I_Q'
                        plot_I_Q(obj, source.UserData)
                    case 'I_P'
                        plot_I_P(obj, source.UserData)
                    case 'I_P(flag)' %��I_Pͼ�ϱ�Ǳ��ؿ�ʼ��־
                        plot_I_P_flag(obj, source.UserData)
                    case 'carrFreq'
                        plot_carrFreq(obj, source.UserData)
                    case 'codeFreq'
                        plot_codeFreq(obj, source.UserData)
                end
            end
        end
        
    end %end methods
    
end %end classdef

%% ������ͼ����
function plot_I_Q(obj, k)
    figure
    plot(obj.channels(k).storage.I_Q(1001:end,1),obj.channels(k).storage.I_Q(1001:end,4), ...
         'LineStyle','none', 'Marker','.')
    axis equal
end

function plot_I_P(obj, k)
    figure('Position', screenBlock(1000,300,0.5,0.5));
    axes('Position', [0.05, 0.15, 0.9, 0.75]);
    t = obj.channels(k).storage.dataIndex/obj.sampleFreq;
    plot(t, double(obj.channels(k).storage.I_Q(:,1)))
    set(gca, 'XLim',[1,obj.Tms/1000])
end

function plot_I_P_flag(obj, k)
    figure('Position', screenBlock(1000,300,0.5,0.5));
    axes('Position', [0.05, 0.15, 0.9, 0.75]);
    t = obj.channels(k).storage.dataIndex/obj.sampleFreq;
    plot(t, double(obj.channels(k).storage.I_Q(:,1)))
    hold on
    index = find(obj.channels(k).storage.bitFlag=='H'); %Ѱ��֡ͷ�׶�,��βΪ[1,0,0,0,1,0,1,1]
    t = obj.channels(k).storage.dataIndex(index)/obj.sampleFreq;
    plot(t, double(obj.channels(k).storage.I_Q(index,1)), 'LineStyle','none', 'Marker','.', 'Color','m')
    index = find(obj.channels(k).storage.bitFlag=='C'); %У��֡ͷ�׶�,��βΪ[1,0,0,0,1,0,1,1]
    t = obj.channels(k).storage.dataIndex(index)/obj.sampleFreq;
    plot(t, double(obj.channels(k).storage.I_Q(index,1)), 'LineStyle','none', 'Marker','.', 'Color','b')
    index = find(obj.channels(k).storage.bitFlag=='E'); %���������׶�
    t = obj.channels(k).storage.dataIndex(index)/obj.sampleFreq;
    plot(t, double(obj.channels(k).storage.I_Q(index,1)), 'LineStyle','none', 'Marker','.', 'Color','r')
    set(gca, 'XLim',[1,obj.Tms/1000])
end

function plot_carrFreq(obj, k)
    figure
    t = obj.channels(k).storage.dataIndex/obj.sampleFreq;
    plot(t, obj.channels(k).storage.carrFreq)
    set(gca, 'XLim',[1,obj.Tms/1000])
    grid on
end

function plot_codeFreq(obj, k)
    figure
    t = obj.channels(k).storage.dataIndex/obj.sampleFreq;
    plot(t, obj.channels(k).storage.codeFreq)
    set(gca, 'XLim',[1,obj.Tms/1000])
    grid on
end