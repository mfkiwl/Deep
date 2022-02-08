function [phaseError, freqError, R_freq] = freqError_cal(phaseError, dt, R_phase)
% Ƶ�������㣬��С���˷�
% phaseError:�ز���λ���,������
% dt:��ɻ���ʱ��

n = length(phaseError);
A = [ones(n,1),(1:n)'*dt];
R_phase = diag(R_phase);
X = (A'*A) \ (phaseError*A)';
phaseError = X(1) + X(2)*n*dt;
freqError = X(2);
R = inv(A'/R_phase*A);
R_freq = R(4);

end