classdef filter_single < handle
% �����ߵ����˲���,λ���ٶȶ��ǹߵ���
    
    properties
        firstFlag  %�״����б�־
        pos        %λ��,γ����
        vel        %�ٶ�,����ϵ
        att        %��̬
        rp         %λ��,ecef
        vp         %�ٶ�,ecef
        quat       %��̬��Ԫ��
        dtr        %�Ӳ�,s
        dtv        %��Ƶ��,s/s
        geogInfo   %������Ϣ
        imu0       %�ϴε�IMU���(��ƫ������)
        bias       %��ƫ,[gyro,acc],[rad/s,m/s^2]
        T          %��������
        P          %P��
        Q          %Q��
        Rwb        %�����������������
        wbDelay    %�ӳٵĽ��ٶ����
        arm        %�˱�ʸ��,��ϵ��IMUָ������
        wdotCal    %�Ǽ��ٶȼ���ģ��
        wdot       %�Ǽ��ٶ�ֵ,rad/s^2
        motion     %�˶�״̬���
        accJump    %���ٶ�ͻ����(Ӧ�Է���ʱ���ܳ��ֵļ��ٶ�ͻ������)
    end
    
    methods
        %% ���캯��
        function obj = filter_single(para)
            d2r = pi/180;
            g0 = 9.8; %�������ٶȽ���ֵ
            c = 3e8; %���ٽ���ֵ
            obj.firstFlag = 0;
            obj.pos = para.p0;
            obj.vel = para.v0;
            obj.att = para.a0;
            Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
            obj.rp = lla2ecef(obj.pos);
            obj.vp = obj.vel*Cen;
            obj.quat = angle2quat(obj.att(1)*d2r, obj.att(2)*d2r, obj.att(3)*d2r);
            obj.dtr = 0;
            obj.dtv = 0;
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
            obj.imu0 = [0,0,0,0,0,0];
            obj.bias = [0,0,0,0,0,0];
            obj.T = para.dt;
            obj.P = diag([para.P0_att  *[1,1,1]*d2r, ...
                          para.P0_vel  *[1,1,1], ...
                          para.P0_pos  *[obj.geogInfo.dlatdn,obj.geogInfo.dlonde,1], ...
                          para.P0_dtr  *c, ...
                          para.P0_dtv  *c, ...
                          para.P0_gyro *[1,1,1]*d2r, ...
                          para.P0_acc  *[1,1,1]*g0 ...
                         ])^2; %para��P0���Ǳ�׼��
            obj.Q = diag([para.Q_gyro *[1,1,1]*d2r, ...
                          para.Q_acc  *[1,1,1]*g0, ...
                          para.Q_acc  *[obj.geogInfo.dlatdn,obj.geogInfo.dlonde,1]*g0*(obj.T*1), ...
                          para.Q_dtv  *c*(obj.T*1), ...
                          para.Q_dtv  *c, ...
                          para.Q_dg   *[1,1,1]*d2r, ...
                          para.Q_da   *[1,1,1]*g0 ...
                         ])^2 * obj.T^2; %para��Q���Ǳ�׼��
            obj.Rwb = (para.sigma_gyro*d2r)^2;
            obj.wbDelay = delayN(20, 3);
            obj.arm = para.arm;
            obj.wdotCal = omegadot_cal(obj.T, 3);
            obj.wdot = [0,0,0];
            obj.motion = motionDetector_gyro_vel(para.gyro0, obj.T, 0.8);
            obj.accJump = accJumpDetector(obj.T);
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
            r2d = 180/pi;
            c = 299792458;
            dt = obj.T;
            q = obj.quat;
            v0 = obj.vel;
            lat = obj.pos(1); %deg
            lon = obj.pos(2); %deg
            h = obj.pos(3);
            %----�״�����ʱ��¼IMUֵ
            if obj.firstFlag==0
                obj.imu0 = imu;
                obj.firstFlag = 1;
            end
            %----���ٶ�ͻ����
            obj.accJump.run(imu(4:6));
            %----�˶�״̬���
            obj.motion.run(imu(1:3)*r2d, obj.vel); %deg/s
            %----����Ǽ��ٶ�
            obj.wdot = obj.wdotCal.run(imu(1:3)); %rad/s
            %----���ٶ��ӳ�
            wbd = obj.wbDelay.push(imu(1:3));
            wbd = wbd - obj.bias(1:3); %����ǰ��ƫ
            %----��ƫ����
            imu = imu - obj.bias;
            %----�ϴε�IMUֵ
            if norm(obj.imu0(1:3)-imu(1:3))>(17.5*dt) %���ٶ�ͻ��(1000deg/s^2)
                wb0 = imu(1:3);
            else
                wb0 = obj.imu0(1:3);
            end
            if obj.accJump.state==1 && obj.accJump.cnt==0 %���ٶ�ͻ��
                fb0 = imu(4:6);
            else
                fb0 = obj.imu0(4:6);
            end
            %----��ǰ��IMUֵ
            wb1 = imu(1:3);
            fb1 = imu(4:6);
            %----��̬����
            Cnb = quat2dcm(q); %�ϴε���̬��
            Cbn = Cnb';
%             winn = obj.geogInfo.wien + obj.geogInfo.wenn;
%             winb = winn * Cbn;
%             wb0 = wb0 - winb;
%             wb1 = wb1 - winb;
            wenb = obj.geogInfo.wenn * Cbn;
            wb0 = wb0 - wenb; %�ٳ�����ϵ��ת,û�ٵ�����ת
            wb1 = wb1 - wenb;
            q = RK2(@fun_dq, q, dt, wb0, wb1);
            q = q / norm(q);
            %----�ٶȽ���
            winn2 = 2*obj.geogInfo.wien + obj.geogInfo.wenn;
            fb = (fb0+fb1)/2;
            wb = (wb0+wb1)/2;
            dv = fb*dt; %�ٶ�����
            dtheta = wb*dt; %�Ƕ�����
            dvc = 0.5*cross(dtheta,dv); %�ٶ�����������
            v = v0 + (dv+dvc)*Cnb + ([0,0,obj.geogInfo.g]-cross(winn2,v0))*dt;
            %----λ�ý���
            dp = (v0+v)/2*dt; %λ������
            lat = lat + dp(1)*obj.geogInfo.dlatdn*r2d; %deg
            lon = lon + dp(2)*obj.geogInfo.dlonde*r2d; %deg
            h = h - dp(3);
            %----״̬����
            Cnb = quat2dcm(q);
            Cbn = Cnb';
            fn = fb1*Cnb;
            A = zeros(17);
%             A(1:3,1:3) = [0,winn(3),-winn(2); -winn(3),0,winn(1); winn(2),-winn(1),0];
            A(1:3,12:14) = -Cbn;
            A(4:6,1:3) = [0,-fn(3),fn(2); fn(3),0,-fn(1); -fn(2),fn(1),0];
%             A(4:6,4:6) = [0,winn2(3),-winn2(2); -winn2(3),0,winn2(1); winn2(2),-winn2(1),0];
            A(4:6,15:17) = Cbn;
            A(7,4) = obj.geogInfo.dlatdn;
            A(8,5) = obj.geogInfo.dlonde;
            A(9,6) = -1;
            A(10,11) = 1;
            Phi = eye(17) + A*dt; % + (A*dt)^2/2;
            %----״̬����
            P1 = Phi*obj.P*Phi' + obj.Q;
            X = zeros(17,1);
            %----����ά��
            n1 = sum(indexP); %α���������
            n2 = sum(indexV); %α�����������
            %----�������
            if n1>0 && obj.accJump.state==0 %���������Ⲣ��û�м��ٶ�ͻ��
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
                H = zeros(n1+n2,17);
                H(1:n1,7:9) = Ha;
                H(1:n1,10) = -ones(n1,1);
                H((n1+1):end,4:6) = Hb;
                H((n1+1):end,11) = -cm(indexV);
                %----�Բ�����α��α���ʽ��и˱�����-------------------------%
                rho = rho - HB*Cbn*obj.arm'; %������߷��ڹߵ�λ��Ӧ�ò�õ�α��
                vab = cross(wb1,obj.arm); %�˱�������ٶ�
                rhodot = rhodot - HB*Cbn*vab'; %������߷��ڹߵ�λ��Ӧ�ò�õ�α����
                %---------------------------------------------------------%
                Z = [rho0(indexP) - rho(indexP); ...
                     rhodot0(indexV) - rhodot(indexV).*cm(indexV)]; %����ֵ������ֵ
                if obj.motion.state==0 %��ֹʱ������ٶ�����
                    H(end+(1:3),12:14) = eye(3);
                    Z = [Z; wbd']; %ʹ���ӳٺ�Ľ��ٶ�,��ֹ����ǰ������Ľ��ٶȶ���
                    R = diag([R_rho(indexP);R_rhodot(indexV);[1;1;1]*obj.Rwb]);
                else %�˶�ʱ��α���ʵ����������Ŵ�
                    R = diag([R_rho(indexP);R_rhodot(indexV)*1]);
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
%                 if abs(obj.bias(1)+X(12))*r2d>0.1
%                     Ysub = zeros(1,17);
%                     Ysub(1,12) = 1;
%                     Y = [Y; Ysub];
%                 end
%                 if abs(obj.bias(2)+X(13))*r2d>0.1
%                     Ysub = zeros(1,17);
%                     Ysub(1,13) = 1;
%                     Y = [Y; Ysub];
%                 end
%                 if abs(obj.bias(3)+X(14))*r2d>0.1
%                     Ysub = zeros(1,17);
%                     Ysub(1,14) = 1;
%                     Y = [Y; Ysub];
%                 end
%                 if abs(obj.bias(4)+X(15))>0.05
%                     Ysub = zeros(1,17);
%                     Ysub(1,15) = 1;
%                     Y = [Y; Ysub];
%                 end
%                 if abs(obj.bias(5)+X(16))>0.05
%                     Ysub = zeros(1,17);
%                     Ysub(1,16) = 1;
%                     Y = [Y; Ysub];
%                 end
%                 if abs(obj.bias(6)+X(17))>0.05
%                     Ysub = zeros(1,17);
%                     Ysub(1,17) = 1;
%                     Y = [Y; Ysub];
%                 end
                if ~isempty(Y)
                    X = X - P1*Y'/(Y*P1*Y')*Y*X;
                end
            end
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
            obj.dtr = X(10)/c; %s
            obj.dtv = X(11)/c; %s/s
            obj.bias(1:3) = obj.bias(1:3) + X(12:14)'; %rad/s
            obj.bias(4:6) = obj.bias(4:6) + X(15:17)'; %m/s^2
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel); %���µ�����Ϣ
            obj.imu0 = imu; %����IMU����
        end
        
    end %end methods
    
end %end classdef