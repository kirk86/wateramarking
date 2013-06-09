%% Plot ROC curves
function gaussians(meanOfDecodedCorrect, stdOfDecodedCorrect, meanOfDecodedWrong, stdOfDecodedWrong)

% x = 0:0.1:10;
% x = -10:0.02:10;
x = -0.2:0.001:0.2;

y_correct = gaussmf( x, [stdOfDecodedCorrect meanOfDecodedCorrect] );
y_wrong   = gaussmf( x, [stdOfDecodedWrong meanOfDecodedWrong] );

figure;
plot(x, y_correct, 'g');
hold on;
plot(x, y_wrong, 'r');
title('Guassians');

end