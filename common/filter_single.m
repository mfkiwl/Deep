classdef filter_single < handle
% �����ߵ����˲���,λ���ٶȶ��ǹߵ���
    
    properties
        motion  %�˶�״̬���
        pos     %λ��,γ����
        vel     %�ٶ�,����ϵ
        att     %��̬
        rp      %λ��,ecef
        vp      %�ٶ�,ecef
        quat    %��̬��Ԫ��
        dtr     %�Ӳ�,s
        dtv     %��Ƶ��,s/s
        bias    %��ƫ,[gyro,acc],[deg/s,g]
        T       %��������
        Rm      %����Ȧ�뾶
        Rn      %î��Ȧ�뾶
        g       %�������ٶ�,m/s^2
        dlatdn  %γ�ȶԱ���λ�Ƶĵ���
        dlonde  %���ȶԶ���λ�Ƶĵ���
        P       %P��
        Q       %Q��
        Rwb     %�����������������
        wbDelay %�ӳٵĽ��ٶ����
        arm     %�˱�ʸ��,��ϵ��IMUָ������
        wdot    %�Ǽ��ٶ�,deg/s/s,(��������ֵ)
        wdotK   %����Ǽ��ٶ�ʱ�õ�K
        wdotX   %����Ǽ��ٶ�ʱ�˲���Ľ��ٶ�
    end
    
    methods
        %% ���캯��
        function obj = filter_single(para)
            d2r = pi/180;
            obj.motion = motionDetector_gyro(para.gyro0, para.dt, 0.8);
            obj.pos = para.p0;
            obj.vel = para.v0;
            obj.att = para.a0;
            Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
            obj.rp = lla2ecef(obj.pos);
            obj.vp = obj.vel*Cen;
            obj.quat = angle2quat(obj.att(1)*d2r, obj.att(2)*d2r, obj.att(3)*d2r);
            obj.dtr = 0;
            obj.dtv = 0;
            obj.bias = [0,0,0,0,0,0];
            obj.T = para.dt;
            lat = obj.pos(1); %deg
            h = obj.pos(3);
            [obj.Rm, obj.Rn] = earthCurveRadius(lat);
            obj.g = gravitywgs84(h, lat);
            obj.dlatdn = 1/(obj.Rm+h);
            obj.dlonde = secd(lat)/(obj.Rn+h);
            obj.P = diag([para.P0_att  *[1,1,1]*d2r, ...
                          para.P0_vel  *[1,1,1], ...
                          para.P0_pos  *[obj.dlatdn,obj.dlonde,1], ...
                          para.P0_dtr  *3e8, ...
                          para.P0_dtv  *3e8, ...
                          para.P0_gyro *[1,1,1]*d2r, ...
                          para.P0_acc  *[1,1,1]*9.8 ...
                         ])^2; %para��P0���Ǳ�׼��
            obj.Q = diag([para.Q_gyro *[1,1,1]*d2r, ...
                          para.Q_acc  *[1,1,1]*9.8, ...
                          para.Q_acc  *[obj.dlatdn,obj.dlonde,1]*9.8*(obj.T*1), ...
                          para.Q_dtv  *3e8*(obj.T*1), ...
                          para.Q_dtv  *3e8, ...
                          para.Q_dg   *[1,1,1]*d2r, ...
                          para.Q_da   *[1,1,1]*9.8 ...
                         ])^2 * obj.T^2; %para��Q���Ǳ�׼��
%             obj.Q(6,6) = obj.Q(6,6) * 100; %�����õ����ٶȹ���������,�����ٶȹ��Ƶ�ƫ���Ǹ߶ȱ仯�����
            obj.Rwb = (para.sigma_gyro*d2r)^2;
            obj.wbDelay = delayN(3, 20);
            obj.arm = para.arm;
            obj.wdot = [0,0,0];
            [K1, K2] = order2LoopCoefD(8, 0.707, obj.T);
            obj.wdotK = [K1,K2];
            obj.wdotX = [0,0,0];
        end
        
        %% ���к���
        function run(obj, imu, sv, indexP, indexV)
            % indexP,indexV���������߼�ֵ
            %----��ȡ���ǲ���(ÿ��һ������)
            rs = sv(:,1:3);     %����ecefλ��
            vs = sv(:,4:6);     %����ecef�ٶ�
            rho = sv(:,7);      %������α��
            rhodot = sv(:,8);   %������α����
            R_rho = sv(:,9);    %α����������
            R_rhodot= sv(:,10); %α������������
            %----����̵ı�����
            d2r = pi/180;
            r2d = 180/pi;
            dt = obj.T;
            q = obj.quat;
            v0 = obj.vel;
            lat = obj.pos(1); %deg
            lon = obj.pos(2); %deg
            h = obj.pos(3);
            %----���µ������(λ�ñ仯С���Բ���)
            [obj.Rm, obj.Rn] = earthCurveRadius(lat);
            obj.g = gravitywgs84(h, lat);
            obj.dlatdn = 1/(obj.Rm+h);
            obj.dlonde = secd(lat)/(obj.Rn+h);
            %----�˶�״̬���
            obj.motion.run(imu(1:3)); %deg/s
            %----����Ǽ��ٶ�
            wdotE = imu(1:3) - obj.wdotX; %���
            obj.wdot = obj.wdot + obj.wdotK(2)*wdotE; %������
            obj.wdotX = obj.wdotX + (obj.wdotK(1)*wdotE+obj.wdot)*obj.T;
            %----���ٶ��ӳ�
            wbd = obj.wbDelay.push(imu(1:3));
            wbd = (wbd - obj.bias(1:3)) *d2r; %����ǰ��ƫ
            %----��ƫ����
            imu = imu - obj.bias;
            wb = imu(1:3) *d2r; %rad
            fb = imu(4:6) *obj.g; %m/s^2
            %----��̬����
            Omega = [  0,    wb(1),  wb(2),  wb(3);
                    -wb(1),    0,   -wb(3),  wb(2);
                    -wb(2),  wb(3),    0,   -wb(1);
                    -wb(3), -wb(2),  wb(1),    0 ];
            q = q + 0.5*q*Omega*dt;
            q = q / norm(q);
            Cnb = quat2dcm(q);
            Cbn = Cnb';
            %----�ٶȽ���
            fn = fb*Cnb;
            v = v0 + (fn+[0,0,obj.g])*dt;
            %----λ�ý���
            dp = (v0+v)/2*dt; %λ������
            lat = lat + dp(1)*obj.dlatdn*r2d; %deg
            lon = lon + dp(2)*obj.dlonde*r2d; %deg
            h = h - dp(3);
            %----״̬����
            A = zeros(17);
            A(1:3,12:14) = -Cbn;
            A(4:6,1:3) = [0,-fn(3),fn(2); fn(3),0,-fn(1); -fn(2),fn(1),0];
            A(4:6,15:17) = Cbn;
            A(7,4) = obj.dlatdn;
            A(8,5) = obj.dlonde;
            A(9,6) = -1;
            A(10,11) = 1;
            Phi = eye(17) + A*dt;
            %----״̬����
            P1 = Phi*obj.P*Phi' + obj.Q;
            X = zeros(17,1);
            %----����ά��
            n1 = sum(indexP); %α���������
            n2 = sum(indexV); %α�����������
            %----�������
            if n1>0 %����������
                %----���ݵ�ǰ�����������������Ծ��������ٶ�
                [rho0, rhodot0, rspu, Cen] = rho_rhodot_cal_geog(rs, vs, [lat,lon,h], v);
                %----�������ⷽ��,������,��������������
                F = jacobi_lla2ecef(lat, lon, h, obj.Rn);
                HA = rspu*F;
                HB = rspu*Cen'; %����Ϊ����ϵ������ָ����ջ��ĵ�λʸ��
                Ha = HA(indexP,:); %ȡ��Ч����
                Hb = HB(indexV,:);
                H = zeros(n1+n2,17);
                H(1:n1,7:9) = Ha;
                H(1:n1,10) = -ones(n1,1);
                H((n1+1):end,4:6) = Hb;
                H((n1+1):end,11) = -ones(n2,1);
                %----�Բ�����α��α���ʽ��и˱�����-------------------------%
                rho = rho - HB*Cbn*obj.arm'; %������߷��ڹߵ�λ��Ӧ�ò�õ�α��
                vab = cross(wb,obj.arm); %�˱�������ٶ�
                rhodot = rhodot - HB*Cbn*vab'; %������߷��ڹߵ�λ��Ӧ�ò�õ�α����
                %---------------------------------------------------------%
                Z = [rho0(indexP) - rho(indexP); ...
                     rhodot0(indexV) - rhodot(indexV)]; %����ֵ������ֵ
                if obj.motion.state==0 %��ֹʱ������ٶ�����
                    H(end+(1:3),12:14) = eye(3);
                    Z = [Z; wbd']; %ʹ���ӳٺ�Ľ��ٶ�,��ֹ����ǰ������Ľ��ٶȶ���
                    R = diag([R_rho(indexP);R_rhodot(indexV);[1;1;1]*obj.Rwb]);
                else %�˶�ʱ��α���ʵ����������Ŵ�
                    R = diag([R_rho(indexP);R_rhodot(indexV)*4]);
                end
                %----�˲�
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                P1 = (eye(17)-K*H)*P1;
                obj.P = (P1+P1')/2;
                %----״̬Լ��
                Y = [];
                if obj.motion.state==0 %��ֹʱ����������Լ��Ϊ0
                    Ysub = zeros(1,17);
                    Ysub(1,1) = Cnb(1,1)*Cnb(1,3);
                    Ysub(1,2) = Cnb(1,2)*Cnb(1,3);
                    Ysub(1,3) = -(Cnb(1,1)^2+Cnb(1,2)^2);
                    Y = [Y; Ysub];
                end
%                 if n1<4 %α������С��4,�����Ӳ�
%                     Ysub = zeros(1,17);
%                     Ysub(1,10) = 1;
%                     Y = [Y; Ysub];
%                 end
%                 if n2<4 %α��������С��4,������Ƶ��
%                     Ysub = zeros(1,17);
%                     Ysub(1,11) = 1;
%                     Y = [Y; Ysub];
%                 end
                if abs(obj.bias(1)+X(12)*r2d)>0.1
                    Ysub = zeros(1,17);
                    Ysub(1,12) = 1;
                    Y = [Y; Ysub];
                end
                if abs(obj.bias(2)+X(13)*r2d)>0.1
                    Ysub = zeros(1,17);
                    Ysub(1,13) = 1;
                    Y = [Y; Ysub];
                end
                if abs(obj.bias(3)+X(14)*r2d)>0.1
                    Ysub = zeros(1,17);
                    Ysub(1,14) = 1;
                    Y = [Y; Ysub];
                end
                if abs(obj.bias(4)+X(15)/obj.g)>5e-3
                    Ysub = zeros(1,17);
                    Ysub(1,15) = 1;
                    Y = [Y; Ysub];
                end
                if abs(obj.bias(5)+X(16)/obj.g)>5e-3
                    Ysub = zeros(1,17);
                    Ysub(1,16) = 1;
                    Y = [Y; Ysub];
                end
                if abs(obj.bias(6)+X(17)/obj.g)>5e-3
                    Ysub = zeros(1,17);
                    Ysub(1,17) = 1;
                    Y = [Y; Ysub];
                end
                if ~isempty(Y)
                    X = X - P1*Y'/(Y*P1*Y')*Y*X;
                end
            end
            %----�˶�����ֹʱ������̬ʧ׼��,��ƫ��Ӧ��P
%             if obj.motion.state0==1 && obj.motion.state==0
%                 obj.P(12,12) = 3e-7; %(0.03/180*pi)^2
%                 obj.P(13,13) = 3e-7;
%                 obj.P(14,14) = 3e-7;
%                 obj.P(15,15) = 1e-4; %(0.01)^2
%                 obj.P(16,16) = 1e-4;
%                 obj.P(17,17) = 1e-4;
%             end
            %----��������
            q = quatCorr(q, X(1:3)');
            v = v - X(4:6)';
            lat = lat - X(7)*r2d; %deg
            lon = lon - X(8)*r2d; %deg
            h = h - X(9);
            %----���µ�������
            obj.pos = [lat,lon,h];
            obj.vel = v;
            [r1,r2,r3] = quat2angle(q);
            obj.att = [r1,r2,r3]*r2d; %deg
            obj.rp = lla2ecef(obj.pos);
            Cen = dcmecef2ned(lat, lon);
            obj.vp = v*Cen;
            obj.quat = q;
            obj.dtr = X(10)/299792458; %s
            obj.dtv = X(11)/299792458; %s/s
            obj.bias(1:3) = obj.bias(1:3) + X(12:14)'*r2d; %deg/s
            obj.bias(4:6) = obj.bias(4:6) + X(15:17)'/obj.g; %g
        end
        
    end %end methods
    
end %end classdef