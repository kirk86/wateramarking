%% Noise Attack
function noiseImageAttacked = noiseAttack(watermarked_image)
noiseImageAttacked = imnoise(watermarked_image, 'salt & pepper', 0.01);
end