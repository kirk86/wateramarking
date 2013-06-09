%% Attacks
function attacks()

clear all;
close all;
clc;

watermarked_images_dir = fullfile( pwd, 'watermarked_images\*.png');
attacked_dir = fullfile(pwd, 'attacked\');
logos_dir = fullfile(pwd, 'logos\');

numOfKeys = length( dir( watermarked_images_dir ) );
% numOfKeys = 100;
decoded_correct = zeros(1, numOfKeys);
decoded_wrong = zeros(1, numOfKeys);
corr_coef = zeros(1, numOfKeys);

% Set constant variables
print_figures = false;
authentication = false;
attack = input('Please insert the name of the attack you wanna try!\n');

if ( ~isempty( dir( watermarked_images_dir ) ) )
    
    [watermark_logo_fname, watermark_pthname] = ...
        uigetfile('*.jpg; *.png; *.tif; *.bmp', 'Select the Watermark Logo');
    if (watermark_logo_fname ~= 0)
        watermark_logo = strcat(watermark_pthname, watermark_logo_fname);
        watermark_logo = double( im2bw( rgb2gray( imread( watermark_logo ) ) ) );
        watermark_logo = imresize(watermark_logo, [512 512], 'bilinear');
    else
        return;
    end
    
    for key = 1:numOfKeys
        watermarked_image = imread( fullfile( pwd, '\watermarked_images\', strcat(num2str(key), '.png') ) );
        
        switch ( lower(attack) )
            case 'mean'
                attackedImage = meanAttack(watermarked_image);
                imwrite(uint8(attackedImage), fullfile( attacked_dir, strcat(num2str(key), '.png') ), 'png');
                
            case 'median'
                attackedImage = medianAttack(watermarked_image);
                imwrite(uint8(attackedImage), fullfile( attacked_dir, strcat(num2str(key), '.png') ), 'png');
                
            case 'noise'
                attackedImage = noiseAttack(watermarked_image);
                imwrite(uint8(attackedImage), fullfile( attacked_dir, strcat(num2str(key), '.png') ), 'png');
                
            case 'rotation'
                attackedImage = rotationAttack(watermarked_image, 45);
                imwrite(uint8(attackedImage), fullfile( attacked_dir, strcat(num2str(key), '.png') ), 'png');
                
            case 'shear'
                attackedImage = shearAttack(watermarked_image);
                attackedImage = imresize(attackedImage, [512 512]);
                imwrite(uint8(attackedImage), fullfile( attacked_dir, strcat(num2str(key), '.png') ), 'png');
                
            case 'crop'
                attackedImage = cropAttack(watermarked_image);
                attackedImage = imresize(attackedImage, [512 512]);
                imwrite(uint8(attackedImage), fullfile( attacked_dir, strcat(num2str(key), '.png') ), 'png');
                
            otherwise
                errordlg('Please specify an attack mode!');
        end
        
        [message_correct, ~, recon_sig_corr, LL4, HH4] = ...
            watermark_extraction(double(attackedImage), watermark_logo, key, ...
            print_figures, authentication);
        
        imwrite(message_correct, fullfile( logos_dir, strcat(num2str(key), '.png') ), 'png');
        
        % Check correlation coefficient between original message (watermark_logo)
        % and the message_correct (watermark_logo after attack) after attack 
        correlation = corrcoef(watermark_logo, message_correct);
        corr_coef(key) = correlation(2, 1);
        
        % transform the watermark_correct(i.e. the reconstructed_signature)
        % and the watermark_wrong(i.e. the wrong reconstructed signature)
        % to the interval [-1, 1]
        recon_sig_corr(find(recon_sig_corr == 0)) = -1;
        
        LL4 = LL4(:)';
        HH4 = HH4(:)';
        LL4 = LL4 - mean(LL4);
        HH4 = HH4 - mean(HH4);
        comb_HH4_LL4 = [LL4 HH4];
        
        % Detection with the wrong key
        [~, watermark_wrong, recon_sig_wrng, LL4wr, HH4wr] = ...
            watermark_extraction(double(attackedImage), watermark_logo, key+11, ...
            print_figures, authentication);
        
        watermark_wrong(find(watermark_wrong == 0)) = -1;
        
        LL4wr = LL4wr(:)';
        HH4wr = HH4wr(:)';
        LL4wr = LL4wr - mean(LL4wr);
        HH4wr = HH4wr - mean(HH4wr);
        combwr_HH4_LL4 = [LL4wr HH4wr];
        
        % Keep track of the correlation between the watermark_correct and
        % the watermark_wrong
        correlation_correct  = corrcoef(comb_HH4_LL4, recon_sig_corr);
        decoded_correct(key) = correlation_correct(2, 1);
        correlation_wrong = corrcoef(combwr_HH4_LL4, watermark_wrong);
        decoded_wrong(key) = correlation_wrong(2, 1);
        
        % Clear workspace
        clear('meanAttackedImage', 'medianAttackedImage', 'noiseAttackedImage', ...
            'rotationAttackedImage', 'shearAttackedImage', 'cropAttackedImage', ...
            'message_correct', 'recon_sig_corr', 'LL4', 'HH4', 'comb_HH4_LL4', ...
            'watermark_wrong', 'recon_sig_wrng', 'LL4wr', 'HH4wr', 'combwr_HH4_LL4');
        
    end
    
    meanCorrCoef = mean(corr_coef);
    
    meanOfDecodCorr = mean(decoded_correct);
    stdOfDecodCorr = std(decoded_correct);
    meanOfDecodWrng = mean(decoded_wrong);
    stdOfDecodWrng = std(decoded_wrong);
    
    gaussians(meanOfDecodCorr, stdOfDecodCorr, meanOfDecodWrng, stdOfDecodWrng);
    [Pfa, Pfr] = PfaPfr(meanOfDecodCorr, stdOfDecodCorr, meanOfDecodWrng, stdOfDecodWrng, numOfKeys);
    
end

end