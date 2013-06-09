%% Median Attack
function medianImageAttacked = medianAttack(watermarked_image)
medianImageAttacked = medfilt2(watermarked_image);
end