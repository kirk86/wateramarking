%% Mean Attack
function meanImageAttacked = meanAttack(watermarked_image)
h = fspecial('average', [5, 5]);
meanImageAttacked = filter2(h, watermarked_image);
end