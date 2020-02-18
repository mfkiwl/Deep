classdef GL1CA_S < handle
% GPS L1 C/A�����߽��ջ�
% �������õ���:�ɼ��Ǹ߶Ƚ���ֵ
    
    % ��������
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
    end
    % ʱ�Ӳ���
    properties (GetAccess = public, SetAccess = private)
        tms            %���ջ���ǰ����ʱ��,ms
        week           %GPS����
        ta             %���ջ�ʱ��,GPS��������,[s,ms,us]
        deltaFreq      %���ջ�ʱ��Ƶ�����,������,�ӿ�Ϊ��
    end
    % ����
    properties (GetAccess = public, SetAccess = private)
        almanac        %�������ǵ�����
        aziele         %ʹ�������������Ƿ�λ�Ǹ߶Ƚ�
        eleMask = 10   %�߶Ƚ���ֵ
    end
    % ͨ������
    properties (GetAccess = public, SetAccess = private)
        svList         %���������б�
        chN            %����ͨ������
        channels       %����ͨ��
    end
    % ��λ����
    properties (GetAccess = public, SetAccess = private)
        iono           %�����У������
        pos            %���ջ�λ��,γ����
        vel            %���ջ��ٶ�,������
    end
    % ���ݴ洢
%     properties (GetAccess = public, SetAccess = private)
%         
%     end
    
    methods
        %% ���캯��
        function obj = GL1CA_S(sampleFreq, t0, Tms, p0)
            % sampleFreq:����Ƶ��,Hz
            % t0:���ջ���ʼʱ��,[week,s,ms,us]
            % Tms:���ջ�������ʱ��,ms
            % p0:��ʼλ��,γ����
            %----������������
            obj.Tms = Tms;
            obj.sampleFreq = sampleFreq;
            obj.blockSize = sampleFreq*0.001; %һ�������̶�Ϊ1ms
            obj.blockNum = 40; %����������̶�һ��ֵ
            obj.buffI = zeros(obj.blockSize,obj.blockNum); %������ʽ,ÿһ��Ϊһ����
            obj.buffQ = zeros(obj.blockSize,obj.blockNum);
            obj.buffSize = obj.blockSize * obj.blockNum;
            obj.blockPoint = 1;
            obj.buffHead = 0;
            %----����ʱ�Ӳ���
            obj.tms = 0;
            obj.week = t0(1);
            obj.ta = t0(2:4);
            obj.deltaFreq = 0;
            %----���ó�ʼλ��
            obj.pos = p0;
            obj.vel = [0,0,0];
            %----�������ݴ洢�ռ�
        end
        
        %% ���к���
        function run(obj, data)
            % data:��������,����,�ֱ�ΪI/Q����,ԭʼ��������
            %----�����ݻ������
            obj.buffI(:,obj.blockPoint) = data(1,:); %�����ݻ����ָ�������,���ü�ת��,�Զ����������
            obj.buffQ(:,obj.blockPoint) = data(2,:);
            obj.buffHead = obj.blockPoint * obj.blockSize; %�������ݵ�λ��
            obj.blockPoint = obj.blockPoint + 1; %ָ����һ��
            if obj.blockPoint>obj.blockNum
                obj.blockPoint = 1;
            end
            obj.tms = obj.tms + 1;
            %----���½��ջ�ʱ��
            fs = obj.sampleFreq * (1+obj.deltaFreq); %������Ĳ���Ƶ��
            obj.ta = timeCarry(obj.ta + sample2dt(obj.blockSize, fs));
            %----����
            if mod(obj.tms,1000)==0 %1s����һ��
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
            %----����
            for k=1:obj.chN
                if obj.channels(k).state==0 %���ͨ��δ����,��������
                    continue
                end
                while 1
                    % �ж��Ƿ��������ĸ�������
                    if mod(obj.buffHead-obj.channels(k).trackDataHead,obj.buffSize)>(obj.buffSize/2)
                        break
                    end
                    n1 = obj.channels(k).trackDataTail;
                    n2 = obj.channels(k).trackDataHead;
                    if n2>n1
                        obj.channels(k).track(obj.buffI(n1:n2), obj.buffQ(n1:n2), obj.deltaFreq);
                    else
                        obj.channels(k).track([obj.buffI(n1:end),obj.buffI(1:n2)], ...
                                              [obj.buffQ(n1:end),obj.buffQ(1:n2)], obj.deltaFreq);
                    end
                    iono0 = obj.channels(k).parse; %������������
                    if ~isempty(iono0)
                        obj.iono = iono0; %��ȡ��������
                    end
                end
            end
            %----��λ
        end
        
        %% ��ȡ����
        function get_almanac(obj, filepath)
            % filepath:����洢·��,��β����\
            t = [obj.week, obj.ta(1)]; %��ǰʱ��
            filename = GPS.almanac.download(filepath, t); %��������,�õ������ļ���
            obj.almanac = GPS.almanac.read(filename); %�������ļ�
            %----ʹ����������������Ƿ�λ�Ǹ߶Ƚ�
            index = find(obj.almanac(:,2)==0); %��ȡ�������ǵ��к�
            n = length(index); %�������Ǹ���
            obj.aziele = zeros(n,3); %[ID,azi,ele]
            obj.aziele(:,1) = obj.almanac(index,1); %ID
            obj.aziele(:,2:3) = aziele_almanac(obj.almanac(index,3:end), t, obj.pos); %[azi,ele]
        end
        
        %% ���ø��������б�
        function set_svList(obj, svList)
            obj.svList = svList;
            if isempty(obj.svList) %����б�Ϊ��,ʹ���������Ŀɼ�����
                if isempty(obj.almanac) %������鲻����,����
                    error('Almanac doesn''t exist!')
                end
                obj.svList = obj.aziele(obj.aziele(:,3)>obj.eleMask,1)'; %ѡȡ�߶ȽǴ�����ֵ������
            end
            %----����ͨ������
            obj.chN = length(obj.svList);
            obj.channels = GPS.L1CA.channel(obj.sampleFreq, obj.buffSize, obj.svList(1), obj.Tms);
            % �ȴ���һ����������ȷ��channel����������,�������������������
            for k=2:obj.chN
                obj.channels(k) = GPS.L1CA.channel(obj.sampleFreq, obj.buffSize, obj.svList(k), obj.Tms);
            end
            obj.channels = obj.channels'; %ת��������
        end
        
        %% �������ݴ���
        function clean_storage(obj)
            for k=1:obj.chN
                obj.channels(k).clean_storage;
            end
        end
        
        %% Ԥ������
        function set_ephemeris(obj, filename)
            load(filename, 'ephemeris') %����Ԥ�������
            if ~isfield(ephemeris, 'GPS_ephe') %��������в�����GPS����,����������
                ephemeris.GPS_ephe = NaN(25,32);
                ephemeris.GPS_iono = NaN(8,1);
                save(filename, 'ephemeris') %���浽�ļ���
            end
            obj.iono = ephemeris.GPS_iono; %��ȡ�����У������
            for k=1:obj.chN %Ϊÿ��ͨ��������
                obj.channels(k).ephe = ephemeris.GPS_ephe(:,obj.channels(k).PRN);
            end
        end
        
        %% ��������
        function save_ephemeris(obj, filename)
            load(filename, 'ephemeris') %����Ԥ�������
            ephemeris.GPS_iono = obj.iono; %��������У������
            for k=1:obj.chN %��ȡ������ͨ��������
                if ~isnan(obj.channels(k).ephe(1))
                    ephemeris.GPS_ephe(:,obj.channels(k).PRN) = obj.channels(k).ephe;
                end
            end
            save(filename, 'ephemeris') %���浽�ļ���
        end
        
        %% ��ӡͨ����־
        function print_log(obj)
            for k=1:obj.chN
                fprintf('PRN %d\n', obj.channels(k).PRN); %ʹ��\r\n���һ������
                n = length(obj.channels(k).log); %ͨ����־������
                if n>1 %��������1,��־������
                    for m=2:n %���д�ӡ
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
            end
        end
        
        %% ��ʾ����ͼ
        function plot_constellation(obj)
            %----��ѡ�߶ȽǴ���0������
            index = find(obj.aziele(:,3)>0); %�߶ȽǴ���0����������
            n = length(index); %���Ǹ���
            PRN = obj.aziele(index,1);
            azi = mod(obj.aziele(index,2),360)/180*pi; %��λ��ת�ɻ���,0~360��
            ele = obj.aziele(index,3); %�߶Ƚ�,deg
            %----ͳ�Ƹ��ٵ�������
            svTrack = obj.svList([obj.channels.ns]~=0);
            %----��ͼ
            figure
            ax = polaraxes; %������������
            hold(ax, 'on')
            ax.RLim = [0,90]; %�߶ȽǷ�Χ
            ax.RDir = 'reverse'; %�߶Ƚ�������90��
            ax.RTick = [0,15,30,45,60,75,90]; %�߶Ƚǿ̶�
            ax.ThetaDir = 'clockwise'; %˳ʱ�뷽λ������
            ax.ThetaZeroLocation = 'top'; %��λ��0����
            for k=1:n %�������и߶ȽǴ���0������
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