function isOverlapping = checkOverlap(node)
    NUM_ELEM = 18;
    LINK = [1 2; 1 3; 2 3; 2 4; 2 5; 3 5; 3 6; 4 5; 5 6; 4 7; 4 8; 5 8; 5 9; 6 9; 6 10; 7 8; 8 9; 9 10];

    for i = 1:NUM_ELEM
        for j = 1:NUM_ELEM
            if i == j || any(any(LINK(i,:)==LINK(j,:)'))
                continue;
            end
            a1 = node(LINK(i,1),:);
            a2 = node(LINK(i,2),:);
            b1 = node(LINK(j,1),:);
            b2 = node(LINK(j,2),:);

            if dot([a1(2) - a2(2), a2(1) - a1(1)], b1(:)) * dot([a1(2) - a2(2), a2(1) - a1(1)], b2(:)) < 0 % Opposite half spaces
                if ~any((a1-b1).*(a2-b1) > 0) || ~any((a1-b2).*(a2-b2) > 0) || ~any((b1-a1).*(b2-a1) > 0) || ~any((b1-a2).*(b2-a2) > 0)
                    isOverlapping = true;

                    clf
                    hold on
                    for b = 1:NUM_ELEM
                        if b==i || b==j
                            plot(node(LINK(b,:),1), node(LINK(b,:),2), 'b');
                        else
                            plot(node(LINK(b,:),1), node(LINK(b,:),2), 'r');
                        end
                    end
                    hold off

                    pause(2)


                    return;
                end
            end
        end
    end

    isOverlapping = false;
end