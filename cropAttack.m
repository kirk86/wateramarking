%% Crop Attack
function cropImageAttacked = cropAttack(watermarked_image)
cropImageAttacked = imcrop(watermarked_image, [75 68 340 380]);
end