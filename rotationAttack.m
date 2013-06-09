%% Rotation Attack
function rotationImageAttacked = rotationAttack(watermarked_image, angle)
rotationImageAttacked = imrotate(watermarked_image, angle, 'crop');
end