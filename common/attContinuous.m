function angle = attContinuous(angle)
% ����̬�Ǳ�����,�Ƕȵ�λ:deg

for k=2:length(angle)
    if angle(k)-angle(k-1)<-300
        angle(k:end) = angle(k:end) + 360;
    elseif angle(k)-angle(k-1)>300
        angle(k:end) = angle(k:end) - 360;
    end
end

end