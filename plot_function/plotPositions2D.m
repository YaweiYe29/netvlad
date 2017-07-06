function plotPositions2D(positions)
% co = get(gca,'ColorOrder'); % Initial
% % Change to new colors.
% set(gca, 'ColorOrder', co(2:end, :), 'NextPlot', 'replacechildren');
plot(positions(:, 2), positions(:, 1), '.', 'MarkerSize', 4);
end