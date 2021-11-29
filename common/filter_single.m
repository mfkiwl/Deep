classdef filter_single < INS_GRC
% �����ߵ����˲���,λ���ٶȶ��ǹߵ���
% �̳��ڹߵ���
    
    properties
        dtr        %�Ӳ����ֵ,s
        dtv        %��Ƶ�����ֵ,s/s
        bias       %��ƫ����ֵ,[gyro,acc],[rad/s,m/s^2]
        P          %P��
        Q          %Q��
        motion     %�˶�״̬���
        Rwb        %�����������������
        wbDelay    %�ӳٵĽ��ٶ����
        arm        %�˱�ʸ��,��ϵ��IMUָ������
        wdotCal    %�Ǽ��ٶȼ���ģ��
        wdot       %�Ǽ��ٶ�ֵ,rad/s^2
        windupFlag %����ЧӦУ����־
    end
    
    methods
        %% ���캯��
        function obj = filter_single(para)
            %----�ߵ���ʼ��------------------
            para_ins.p0 = para.p0;
            para_ins.v0 = para.v0;
            para_ins.a0 = para.a0;
            para_ins.dt = para.dt;
            obj@INS_GRC(para_ins); %�ο�help-Subclass Syntax
            %--------------------------------
            d2r = pi/180;
            g0 = 9.8; %�������ٶȽ���ֵ
            c = 3e8; %���ٽ���ֵ
            obj.dtr = 0;
            obj.dtv = 0;
            obj.bias = [0,0,0,0,0,0];
            obj.T = para.dt;
            obj.P = diag([para.P0_att  *[1,1,1]*d2r, ...
                          para.P0_vel  *[1,1,1], ...
                          para.P0_pos  *[1,1,1], ...
                          para.P0_dtr  *c, ...
                          para.P0_dtv  *c, ...
                          para.P0_gyro *[1,1,1]*d2r, ...
                          para.P0_acc  *[1,1,1]*g0 ...
                         ])^2; %para��P0���Ǳ�׼��
            obj.Q = diag([para.Q_gyro *[1,1,1]*d2r, ...
                          para.Q_acc  *[1,1,1]*g0, ...
                          para.Q_acc  *[1,1,1]*g0*(obj.T*1), ...
                          para.Q_dtv  *c*(obj.T*1), ...
                          para.Q_dtv  *c, ...
                          para.Q_dg   *[1,1,1]*d2r, ...
                          para.Q_da   *[1,1,1]*g0 ...
                         ])^2 * obj.T^2; %para��Q���Ǳ�׼��
            obj.motion = motionDetector_gyro_vel(para.gyro0, obj.T, 0.8); %0.6
            obj.Rwb = (para.sigma_gyro*d2r)^2;
            obj.wbDelay = delayN(20, 3);
            obj.arm = para.arm;
            obj.wdotCal = omegadot_cal(obj.T, 3);
            obj.wdot = [0,0,0];
            obj.windupFlag = para.windupFlag;
        end
        
        %% ���к���
        function run(obj, imu, sv, indexP, indexV)
            % indexP,indexV���������߼�ֵ
            % flag=0,ֻ���ߵ������ʱ�����;flag=1,���������
            if nargin==2
                flag = 0;
            else
                flag = 1;
            end
            r2d = 180/pi;
            c = 299792458;
            dt = obj.T;
            wbo = imu(1:3); %ԭʼ�Ľ��ٶ�
            %----�˶�״̬���(ʹ�ý��ٶȺ��ٶ�)
            obj.motion.run(wbo*r2d, obj.vel); %deg/s
            %----����Ǽ��ٶ�
            obj.wdot = obj.wdotCal.run(wbo); %rad/s
            %----���ٶ��ӳ�
            wbd = obj.wbDelay.push(wbo);
            wbd = wbd - obj.bias(1:3); %����ǰ��ƫ
            %----��ƫ����
            imu = imu - obj.bias;
            wb1 = imu(1:3);
            fb1 = imu(4:6);
%             wb = (wb1+obj.imu0(1:3))/2;
%             fb = (fb1+obj.imu0(4:6))/2;
            %----�ߵ�����
            obj.solve(imu, 1);
            %----�����Ӳ�
            obj.dtr = obj.dtr + obj.dtv*dt;
            %----״̬����
            Cnb = quat2dcm(obj.quat);
            Cbn = Cnb';
            fn = fb1*Cnb;
            winn = obj.geogInfo.wien + obj.geogInfo.wenn;
%             winn2 = winn + obj.geogInfo.wien;
            A = zeros(17);
%             A(1:3,1:3) = antisym(winn);
            A(1:3,12:14) = -Cbn;
            A(4:6,1:3) = antisym(fn);
%             A(4:6,4:6) = antisym(winn2);
            A(4:6,15:17) = Cbn;
            A(7,4) = 1;
            A(8,5) = 1;
            A(9,6) = 1;
            A(10,11) = 1;
            Phi = eye(17) + A*dt + (A*dt)^2/2;
            %----״̬����
            P1 = Phi*obj.P*Phi' + obj.Q;
            X = zeros(17,1);
            %----�������
            measureFlag = 0;
            if flag==1 && sum(indexP)>0 && obj.accJump.state==0 %���������Ⲣ��û�м��ٶ�ͻ��
                measureFlag = 1;
                %----����ά��
                n1 = sum(indexP); %α���������
                n2 = sum(indexV); %α�����������
                %----��ȡ���ǲ���(ÿ��һ������)
                rs = sv(:,1:3);     %����ecefλ��
                vs = sv(:,4:6);     %����ecef�ٶ�
                rho = sv(:,7);      %������α��
                rhodot = sv(:,8);   %������α����
                R_rho = sv(:,9);    %α����������
                R_rhodot= sv(:,10); %α������������
                %----���ݵ�ǰ�����������������Ծ��������ٶ�
                [rho0, rhodot0, rspu, Cen] = rho_rhodot_cal_geog(rs, vs, obj.pos, obj.vel);
                %----����ϵ������ʸ��
                S = -sum(rspu.*vs,2);
                cm = 1 + S/c; %����������
                En = rspu*Cen'; %����Ϊ����ϵ������ָ����ջ��ĵ�λʸ��
                %----�����Ӳ���Ƶ��
                rho = rho - obj.dtr*c;
                rhodot = rhodot - obj.dtv*c - obj.windupFlag*wb1(3)*0.030286178664972; %299792458/1575.42e6/(2*pi)
                %----�Բ�����α��α���ʽ��и˱�����
                ran = Cbn*obj.arm'; %����ϵ�¸˱�ʸ��(������)
                rho = rho - En*ran; %������߷��ڹߵ�λ��Ӧ�ò�õ�α��
                van = Cbn*cross(wb1,obj.arm)'; %����ϵ�¸˱��ٶ�ʸ��(������)
                rhodot = rhodot - En*van; %������߷��ڹߵ�λ��Ӧ�ò�õ�α����
                %----α�����ⲿ��
                E = En(indexP,:);
                H1 = zeros(n1,17);
%                 H1(:,1:3) = E*antisym(ran); %�˱�
                H1(:,7:9) = E;
                H1(:,10) = -1;
                Z1 = rho0(indexP) - rho(indexP);
                R1 = diag(R_rho(indexP));
                %----α�������ⲿ��
                H2 = []; Z2 = []; R2 = [];
                if n2>0
                    E = En(indexV,:);
                    H2 = zeros(n2,17); %α�������ⷽ��
%                     H2(:,1:3) = E*antisym(van); %�˱�
                    H2(:,4:6) = E;
                    H2(:,11) = -cm(indexV);
%                     H2(:,12:14) = -E*antisym(ran); %�˱�
                    Z2 = rhodot0(indexV) - rhodot(indexV).*cm(indexV);
                    if obj.motion.state==0 %�˶�ʱ��α���ʵ����������Ŵ�
                        R2 = diag(R_rhodot(indexV));
                    else
                        R2 = diag(R_rhodot(indexV)*4);
                    end
                end
                %----���ٶ����ⲿ��
                H3 = []; Z3 = []; R3 = [];
                if obj.motion.state==0 %��ֹʱ������ٶ�����
                    H3 = zeros(3,17);
                    H3(:,12:14) = eye(3);
                    Z3 = (wbd-winn*Cbn)';
                    R3 = diag([1;1;1]*obj.Rwb);
                end
                %----�����������,������,��������������
                H = [H1; H2; H3];
                Z = [Z1; Z2; Z3];
                R = blkdiag(R1, R2, R3);
                %----�˲�
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                %----Huber��Ȩ(��)
                R_diag = diag(R); %R�ĶԽ���Ԫ��
                R_sqrt_diag = sqrt(R_diag); %R�ĶԽ���Ԫ�ص�ƽ����
                gamma = 1.3; %Huberϵ��
                for k=1:2 %������
                    Psi_R_diag = HuberWeight((Z-H*X)./R_sqrt_diag, gamma); %��������Ȩֵ
                    R0 = diag(R_diag./Psi_R_diag); %��Ȩ���R��
                    K = P1*H' / (H*P1*H'+R0);
                    X = K*Z;
                end
                %----����P��
                P1 = (eye(17)-K*H)*P1;
            elseif obj.motion.state==0 %��ֹʱ������ٶ�����
                measureFlag = 2;
                H = zeros(3,17);
                H(:,12:14) = eye(3);
                Z = (wbd-winn*Cbn)';
                R = diag([1;1;1]*obj.Rwb);
                K = P1*H' / (H*P1*H'+R);
                X = K*Z;
                P1 = (eye(17)-K*H)*P1;
            end
            %----״̬Լ��
            if measureFlag~=0
                Y = [];
                if obj.motion.state==0
                    Ysub = zeros(1,17); %��ֹʱ����������Լ��Ϊ0
                    Ysub(1,1) = Cnb(1,1)*Cnb(1,3);
                    Ysub(1,2) = Cnb(1,2)*Cnb(1,3);
                    Ysub(1,3) = -(Cnb(1,1)^2+Cnb(1,2)^2);
                    Y = [Y; Ysub];
                    Ysub = zeros(2,17); %��ֹʱ����ˮƽ���ٶȼ���ƫ
                    Ysub(1,15) = 1;
                    Ysub(2,16) = 1;
                    Y = [Y; Ysub];
                end
                if ~isempty(Y)
                    X = X - P1*Y'/(Y*P1*Y')*Y*X;
                end
            end
            %----����P��
            obj.P = (P1+P1')/2;
            %----��������
            X = X'; %ת��������
            obj.correct(X(1:9));
            obj.dtr = obj.dtr + X(10)/c; %s
            obj.dtv = obj.dtv + X(11)/c; %s/s
            obj.bias(1:3) = obj.bias(1:3) + X(12:14); %rad/s
            obj.bias(4:6) = obj.bias(4:6) + X(15:17); %m/s^2
        end
        
    end %end methods
    
end %end classdef