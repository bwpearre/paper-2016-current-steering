clear;

% Read the data file
fid = fopen('splay.txt', 'r');
header = textscan(fid, '%s %s %s %s %s %s %s\n', 1, 'Delimiter', '\t');
d = textscan(fid, '%s %c %s %d %f %f %f\n', 'Delimiter', '\t');
fclose(fid);

data = zeros(size(d, 1), 6);

for i = 1:length(d{1})
    if strcmp(d{2}(i), 'a')
        data(i, 1) = 1;
    elseif strcmp(d{2}(i), 'b')
        data(i, 1) = 2;
    elseif strcmp(d{2}(i), 'c')
        data(i, 1) = 3;
    elseif strcmp(d{2}(i), 'd')
        data(i, 1) = 4;
    end
    
    if strcmp(d{3}(i), 'clumped')
        data(i, 2) = 1;
    elseif strcmp(d{3}(i), 'partial')
        data(i, 2) = 2;
    elseif strcmp(d{3}(i), 'splayed')
        data(i, 2) = 3;
    end
end

for j = 4:7
    data(:, j-1) = double(d{j});
end

key_ind = 1:3;
colours = distinguishable_colors(length(key_ind));
colormap(colours);
key_legend = {'Clumped', 'Partial', 'Splayed'};

indices = {};
counts = [];
for i = 1:length(key_ind)
    indices{i} = find(data(:,2) == i);
    counts(i) = length(indices{i});
end

figure(126);

%% Pie chart
subplot(3,3,1);
pie(counts, key_legend);
set(gca, 'ColorOrder', colours);
title('Splay reliability');

%% Mean inter-electrode distance
subplot(3,3,2);
for i = 1:length(key_ind)
    means(i) = mean(data(indices{i},4));
    stds(i) = std(data(indices{i},4));
end
h = bar(key_ind, means, 'FaceColor', 0.5*[1 1 1]);

hold on;
errorbar(key_ind, means, stds, 'k. ');
hold off;
%set(gca, 'XTickLabels', key_legend);
xticklabel_rotate(key_ind, 30, key_legend);
ylabel('Distance (\mu m)');
title('Mean inter-electrode distance');


%% Inter-electrode distance
subplot(3,3,3);
for i = 1:length(key_ind)
    means(i) = mean(data(indices{i},6));
    stds(i) = std(data(indices{i},6));
end
h = bar(key_ind, means, 'FaceColor', 0.5*[1 1 1]);
hold on;
errorbar(key_ind, means, stds, 'k. ');
hold off;
foo = get(gca, 'YLim');
set(gca, 'YLim', [0 foo(2)]);
%set(gca, 'XTickLabels', key_legend);
xticklabel_rotate(key_ind, 30, key_legend);
ylabel('Distance (\mu m)');
title('Maximum inter-electrode distance');


%% Electrode distances per bundle
subplot(3,3,[4:9]);
cla;
hold on;
markers = {'^', 'd', 's'};
handles = [];
for i = 1:length(key_ind)
    handles(i) = scatter(data(indices{i},4), data(indices{i},6), [], colours(i,:), markers{i});
end
hold off;
xlabel('Average inter-electrode distance per bundle (\mu m)');
ylabel('Maximal distance per bundle (\mu m)');
title('Electrode distances per bundle');
hLegend = legend(handles, key_legend, 'Location', 'SouthEast');
%hMarkers = findobj(hLegend,'type','patch');
%set(hMarkers, 'MarkerEdgeColor','k', 'MarkerFaceColor','b');

set(gca, 'XScale', 'log', 'YScale', 'log');


