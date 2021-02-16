classdef filter_sat < handle
% ���ǵ����˲���
    
    properties
        pos        %λ��,γ����
        vel        %�ٶ�,����ϵ
        rp         %λ��,ecef
        vp         %�ٶ�,ecef
        acc        %���ٶ�
        dtr        %�Ӳ�,s
        dtv        %��Ƶ��,s/s
        geogInfo   %������Ϣ
        T          %��������
        P          %P��
        Q          %Q��
    end
    
    methods
        %% ���캯��
        function obj = filter_sat(para)
            c = 3e8; %���ٽ���ֵ
            obj.pos = para.p0;
            obj.vel = para.v0;
            Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
            obj.rp = lla2ecef(obj.pos);
            obj.vp = obj.vel*Cen;
            obj.acc = [0,0,0];
            obj.dtr = 0;
            obj.dtv = 0;
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
            obj.T = para.dt;
            obj.P = diag([para.P0_pos *[obj.geogInfo.dlatdn,obj.geogInfo.dlonde,1], ...
                          para.P0_vel *[1,1,1], ...
                          para.P0_acc *[1,1,1], ...
                          para.P0_dtr *c, ...
                          para.P0_dtv *c ...
                         ])^2; %para��P0���Ǳ�׼��
            obj.Q = diag([para.Q_pos *[obj.geogInfo.dlatdn,obj.geogInfo.dlonde,1], ...
                          para.Q_vel *[1,1,1], ...
                          para.Q_acc *[1,1,1], ...
                          para.Q_dtr *c, ...
                          para.Q_dtv *c ...
                         ])^2 * obj.T^2; %para��Q���Ǳ�׼��
        end
        
        %% ���к���
        function run(obj, sv, indexP, indexV)
            % indexP,indexV���������߼�ֵ
            %----��ȡ���ǲ���(ÿ��һ������)
            rs = sv(:,1:3);     %����ecefλ��
            vs = sv(:,4:6);     %����ecef�ٶ�
            rho = sv(:,7);      %������α��
            rhodot = sv(:,8);   %������α����
            %----����̵ı�����
            r2d = 180/pi;
            c = 299792458;
            dt = obj.T;
            v0 = obj.vel;
            lat = obj.pos(1); %deg
            lon = obj.pos(2); %deg
            h = obj.pos(3);
            %----�ٶȽ���
            v = v0 + obj.acc*dt;
            %----λ�ý���
            dp = (v0+v)/2*dt; %λ������
            lat = lat + dp(1)*obj.geogInfo.dlatdn*r2d; %deg
            lon = lon + dp(2)*obj.geogInfo.dlonde*r2d; %deg
            h = h - dp(3);
            %----�����Ӳ�
            obj.dtr = obj.dtr + obj.dtv*dt;
            %----״̬����
            A = zeros(11);
            A(1,4) = obj.geogInfo.dlatdn;
            A(2,5) = obj.geogInfo.dlonde;
            A(3,6) = -1;
            A(4:6,7:9) = eye(3);
            A(10,11) = 1;
            Phi = eye(11) + A*dt + (A*dt)^2/2;
            %----״̬����
            P1 = Phi*obj.P*Phi' + obj.Q;
            X = zeros(11,1);
            %----����ά��
            n1 = sum(indexP); %α���������
            n2 = sum(indexV); %α�����������
            %----�������
            if n1>0 %����������
                %----���ݵ�ǰ�����������������Ծ��������ٶ�
                [rho0, rhodot0, rspu, Cen] = rho_rhodot_cal_geog(rs, vs, [lat,lon,h], v);
                %----�������ⷽ��,������,��������������
                S = -sum(rspu.*vs,2);
                cm = 1 + S/c; %����������
                F = jacobi_lla2ecef(lat, lon, h, obj.geogInfo.Rn);
                HA = rspu*F;
                HB = rspu*Cen'; %����Ϊ����ϵ������ָ����ջ��ĵ�λʸ��
                Ha = HA(indexP,:); %ȡ��Ч����
                Hb = HB(indexV,:);
                H = zeros(n1+n2,11);
                H(1:n1,1:3) = Ha;
                H(1:n1,10) = -ones(n1,1);
                H((n1+1):end,4:6) = Hb;
                H((n1+1):end,11) = -cm(indexV);
                %-------------------�����Ӳ���Ƶ��-------------------------%
                rho = rho - obj.dtr*c;
                rhodot = rhodot - obj.dtv*c;
                %---------------------------------------------------------%
                Z = [rho0(indexP) - rho(indexP); ...
                     rhodot0(indexV) - rhodot(indexV).*cm(indexV)]; %����ֵ������ֵ
                R = diag([ones(n1,1)*9; ones(n2,1)*0.0015]);
                %----�˲�
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                P1 = (eye(11)-K*H)*P1;
            end
            %----����P��
            obj.P = (P1+P1')/2;
            %----��������
            lat = lat - X(1)*r2d; %deg
            lon = lon - X(2)*r2d; %deg
            h = h - X(3);
            v = v - X(4:6)';
            %----���µ�������
            obj.pos = [lat,lon,h];
            obj.vel = v;
            obj.rp = lla2ecef(obj.pos);
            Cen = dcmecef2ned(lat, lon);
            obj.vp = v*Cen;
            obj.acc = obj.acc - X(7:9)';
            obj.dtr = obj.dtr + X(10)/c; %s
            obj.dtv = obj.dtv + X(11)/c; %s/s
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel); %���µ�����Ϣ
        end
        
    end %end methods
    
end %end classdef