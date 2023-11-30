function PlotTruss(node, color)
    NUM_ELEM = 18;
    LINK = [1 2; 1 3; 2 3; 2 4; 2 5; 3 5; 3 6; 4 5; 5 6; 4 7; 4 8; 5 8; 5 9; 6 9; 6 10; 7 8; 8 9; 9 10];

    for i=1:NUM_ELEM
        plot(node(LINK(i,:),1), node(LINK(i,:),2), color);
    end
end