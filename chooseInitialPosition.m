function r0 = chooseInitialPosition(index)
    NUM_ELEM = 18;
    LINK = [1 2; 1 3; 2 3; 2 4; 2 5; 3 5; 3 6; 4 5; 5 6; 4 7; 4 8; 5 8; 5 9; 6 9; 6 10; 7 8; 8 9; 9 10];

    r0_sym = NodeToPosition([36/2, 36
                        2/5*36, 2/3*36 ; 3/5*36, 2/3*36
            2/6*36, 1/3*36 ; 3/6*36, 1/3*36 ; 4/6*36, 1/3*36
            0 0 ; 1/3*36, 0; 2/3*36, 0; 36, 0]);
    
    r0_ashlyn = NodeToPosition([0 36 ; 3 24 ; 4 36 ; 2 12 ; 16 16 ; 36 3 ; 0 0 ; 3 0 ; 20 0 ; 36 0]);
    r0_demo = [11.5; 11.5; 35.5; 22.5; 21.5; 7; 18; 13; 21; 36; 1; 22; 0; 35.5; 0];

    r0_random = rand(15,1)*36;
    
    
    gen_r0s = readmatrix('ResultData.txt');
    gen_r0s = [];

    for k=1:length(gen_r0s)/10
        curNode = gen_r0s(k*10-9:k*10, :);
        [f0, maxIndex] = SolveTruss_Optimized(curNode);
        if f0 > 1.999e3
            continue
        end

        % SolveTruss_Momot(curNode,0);

        clf
        hold on
        for i = 1:NUM_ELEM
            if i==maxIndex
                plot(curNode(LINK(i,:),1), curNode(LINK(i,:),2), 'b');
                text(sum(curNode(LINK(i,:),1))/2, sum(curNode(LINK(i,:),2))/2, string(f0))
            else
                plot(curNode(LINK(i,:),1), curNode(LINK(i,:),2), 'r');
            end
        end
        for i = 1:10
            text(curNode(i,1),curNode(i,2), string(i))
        end
        hold off
        pause(.5);
    end

    r0 = r0_sym;

end