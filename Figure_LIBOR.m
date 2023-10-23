function Figure_LIBOR(data, data_LIBRE_phase, MAX_WS, FIG_XTICKLABELS, FIG_YTICKLABELS, YSTEP, FIG_title)

xticklabels = [min(FIG_XTICKLABELS)/1000:0.2:max(FIG_XTICKLABELS)/1000];
yticklabels = [min(FIG_YTICKLABELS):YSTEP:max(FIG_YTICKLABELS)]; 

water_index=find(FIG_XTICKLABELS == 0);
fat_index=find(FIG_XTICKLABELS == -440);

max_water_signal=max(abs(data(water_index,:)));
max_water_signal_index=find(data(water_index,:)==max_water_signal);

% MAX_ws = max(max(abs(data_water)));
numColor=11;
xticks = linspace(1, size(abs(data), 1), numel(xticklabels)); 
yticks = linspace(1, size(abs(data), 2), numel(yticklabels));
  
% Figure - 1
ColorVector=linspace(min(min(data)),max(max(data)),numColor); 
figure('color', [1 1 1]); 
contourf(data',  ColorVector, 'Edgecolor', 'none'); 
colormap(bone(numColor-1)); 
colorbar('YTick',ColorVector);
caxis([ColorVector(1) ColorVector(numColor)*0.9999]);  %caxis([min_signal, max_signal]);
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'TickDir', 'out','FontSize',16)
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels(:), 'TickDir', 'out','FontSize',16)
if(~isempty(data_LIBRE_phase))
   hold on; contour(data_LIBRE_phase',[180, 180], '-', 'color', [0.5 0.5 0.5], 'Linewidth', 1.0) % Line when phase difference is pi
    hold on; contour(data_LIBRE_phase',[180, 180], '--', 'color', [1 1 1], 'Linewidth', 1.0) % Line when phase difference is pi
end
title(['Max(colorbar) = ' num2str(max(ColorVector)) ' ' FIG_title], 'FontSize', 12)

hold on; line([fat_index fat_index],[1, size(data,2)],  'color', 'r', 'LineStyle', '--', 'Linewidth', 1.2)
hold on; line([water_index water_index],[1, size(data,2)],  'color', 'b', 'LineStyle', '--', 'Linewidth', 1.2)
% dont plot if there are duplicates
if length(max_water_signal_index)<2
    hold on; line([1 size(data,1)],[max_water_signal_index max_water_signal_index],  'color', 'k', 'LineStyle', '--', 'Linewidth', 1.2)
end

