%% Bit Error Rate metric
% differenceOfWatermark is the actually the difference of signatures
% detected
function BER = BitErrorRate(differenceOfWatermark)

for ii = 1:size(differenceOfWatermark, 1)
    count_correct(ii) = sum( differenceOfWatermark(ii, :) == 0 );
    BER(ii) = (1 - ( mean ( count_correct(ii) ) / size(differenceOfWatermark, 2) ) ) * 100;
end
% BER = (1 - ( mean ( count_correct ) / size(differenceOfWatermark, 2) ) ) * 100;

end