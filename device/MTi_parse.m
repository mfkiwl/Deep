% ����MTi����

clear
clc

%% ���ļ�
fileID = fopen('MTi710.DAT');
data = fread(fileID, Inf, 'uint8=>uint8');
fclose(fileID);

%% ͳ��֡����
n = length(data); %�ֽ���
k = 1; %�ֽ�ָ��
pn = 0; %֡����
while 1
    if k+3>n
        break
    end
    if data(k)==250 && data(k+1)==255 && data(k+2)==54 %54����������֡
        m = double(data(k+3)); %һ֡�����ݳ���
        if m==255
            error('externed length message')
        end
        if k+4+m>n
            break
        end
        packet = data(k:k+m+4); %һ֡����
        if mod(sum(double(packet(2:end))),256) %У��
            error('checksum error')
        end
        pn = pn+1; %֡������1
        k = k+m+5; %ָ����һ֡���ֽ�
    else
        k = k+1;
    end
end

%% ������
packetCnt = NaN(pn,1);
sampleTime = NaN(pn,1);
UTC = NaN(pn,8);
imu = NaN(pn,6);
angle = NaN(pn,3);
temp = NaN(pn,1);
i = 1; %�����ݵ�λ��
k = 1; %�ֽ�ָ��
while 1
    if k+3>n
        break
    end
    if data(k)==250 && data(k+1)==255 && data(k+2)==54 %54����������֡
        m = double(data(k+3)); %һ֡�����ݳ���
        if k+4+m>n
            break
        end
        dk = 1;
        while dk<m
            id = data(k+3+dk+[0,1]); %���ݱ�ʶ,��λ
            dm = double(data(k+3+dk+2)); %���ݳ���
            bytes = data(k+3+dk+2+(1:dm))';
            if id(1)==16 && id(2)==32 %0x1020,������
                packetCnt(i) = swapbytes(typecast(bytes,'uint16'));
            elseif id(1)==16 && id(2)==96 %0x1060,����ʱ��
                sampleTime(i) = swapbytes(typecast(bytes,'uint32'));
            elseif id(1)==64 && id(2)==32 %0x4020,���ٶ�
                imu(i,4:6) = swapbytes(typecast(bytes,'single'));
            elseif id(1)==128 && id(2)==32 %0x8020,���ٶ�
                imu(i,1:3) = swapbytes(typecast(bytes,'single'));
            elseif id(1)==32 && id(2)==48 %0x2030,��̬��
                angle(i,:) = swapbytes(typecast(bytes,'single'));
            elseif id(1)==8 && id(2)==16 %0x0810,�¶�
                temp(i) = swapbytes(typecast(bytes,'single'));
            elseif id(1)==16 && id(2)==16 %0x1010,UTC
                UTC(i,1) = swapbytes(typecast(bytes(1:4),'uint32'));
                UTC(i,2) = swapbytes(typecast(bytes(5:6),'uint16'));
                UTC(i,3:8) = bytes(7:12);
            end
            dk = dk+3+dm;
        end
        i = i+1; %ָ����һ�洢λ��
        k = k+m+5;
    else
        k = k+1;
    end
end

%% ��������
imu(:,1:3) = imu(:,1:3) /pi*180; %���ٶȱ��deg/s
imu(:,[2,3,5,6]) = -imu(:,[2,3,5,6]); %��ϵתΪǰ����
index = ~isnan(imu(:,1));
imu = [sampleTime(index), imu(index,:)];

angle = angle(:,[3,2,1]); %[yaw,pitch,roll]
index = ~isnan(angle(:,1));
angle = [sampleTime(index), angle(index,:)];

index = ~isnan(temp);
temp = [sampleTime(index), temp(index)];