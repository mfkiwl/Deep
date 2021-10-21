classdef ins_solve < handle
% �ߵ�����
    
    properties
        firstFlag  %�״����б�־
        pos        %λ��,γ����
        vel        %�ٶ�,����ϵ
        att        %��̬
        rp         %λ��,ecef
        vp         %�ٶ�,ecef
        quat       %��̬��Ԫ��
        geogInfo   %������Ϣ
        imu0       %�ϴε�IMU���
        T          %��������
        accJump    %���ٶ�ͻ����(Ӧ�Է���ʱ���ܳ��ֵļ��ٶ�ͻ������)
    end
    
    methods
        %% ���캯��
        function obj = ins_solve(para)
            d2r = pi/180;
            obj.firstFlag = 0;
            obj.pos = para.p0;
            obj.vel = para.v0;
            obj.att = para.a0;
            Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
            obj.rp = lla2ecef(obj.pos);
            obj.vp = obj.vel*Cen;
            obj.quat = angle2quat(obj.att(1)*d2r, obj.att(2)*d2r, obj.att(3)*d2r);
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel);
            obj.imu0 = [0,0,0,0,0,0];
            obj.T = para.dt;
            obj.accJump = accJumpDetector(obj.T);
        end
        
        %% ���к���
        function run(obj, imu, updateFlag)
            %----����̵ı�����
            r2d = 180/pi;
            dt = obj.T;
            q = obj.quat;
            v0 = obj.vel;
            %----�״�����ʱ��¼IMUֵ
            if obj.firstFlag==0
                obj.imu0 = imu;
                obj.firstFlag = 1;
            end
            %----���ٶ�ͻ����
            obj.accJump.run(imu(4:6));
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
            %----���������ٶ�����
            fb = (fb0+fb1)/2;
            wb = (wb0+wb1)/2;
            dv = fb*dt; %�ٶ�����
            dtheta = wb*dt; %�Ƕ�����
            %----��̬����
            Cnb = quat2dcm(q); %�ϴε���̬��
            winn = obj.geogInfo.wien + obj.geogInfo.wenn;
            winb = winn * Cnb';
            X = dtheta - winb*dt; %����������
            phi = norm(X);
            if phi>1e-12
                dq = [cos(phi/2), X/phi*sin(phi/2)];
                q = quatmultiply(q, dq);
            end
            obj.quat = q / norm(q);
            %----�ٶȽ���
            winn2 = winn + obj.geogInfo.wien;
            dvc = 0.5*cross(X,dv); %�ٶ�����������
            obj.vel = v0 + (dv+dvc)*Cnb + ([0,0,obj.geogInfo.g]-cross(winn2,v0))*dt;
            %----λ�ý���
            dp = (v0+obj.vel)/2*dt; %λ������
            obj.pos(1) = obj.pos(1) + dp(1)*obj.geogInfo.dlatdn*r2d; %deg
            obj.pos(2) = obj.pos(2) + dp(2)*obj.geogInfo.dlonde*r2d; %deg
            obj.pos(3) = obj.pos(3) - dp(3);
            %----���µ�������
            obj.imu0 = imu; %����IMU����
            if updateFlag==1
                obj.rp = lla2ecef(obj.pos);
                Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
                obj.vp = obj.vel*Cen;
                [r1,r2,r3] = quat2angle(obj.quat);
                obj.att = [r1,r2,r3]*r2d; %deg
                obj.geogInfo = geogInfo_cal(obj.pos, obj.vel); %���µ�����Ϣ
            end
        end
        
        %% ��������
        function correct(obj, X)
            % XΪ������,[phi,dv,dp]
            r2d = 180/pi;
            obj.quat = quatCorr(obj.quat, X(1:3));
            obj.vel = obj.vel - X(4:6);
            obj.pos(1) = obj.pos(1) - X(7)*obj.geogInfo.dlatdn*r2d; %deg
            obj.pos(2) = obj.pos(2) - X(8)*obj.geogInfo.dlonde*r2d; %deg
            obj.pos(3) = obj.pos(3) + X(9);
            % ���µ�������
            obj.rp = lla2ecef(obj.pos);
            Cen = dcmecef2ned(obj.pos(1), obj.pos(2));
            obj.vp = obj.vel*Cen;
            [r1,r2,r3] = quat2angle(obj.quat);
            obj.att = [r1,r2,r3]*r2d; %deg
            obj.geogInfo = geogInfo_cal(obj.pos, obj.vel); %���µ�����Ϣ
        end
        
    end %end methods
    
end %end classdef