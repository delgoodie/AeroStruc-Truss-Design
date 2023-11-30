function position = NodeToPosition(Node)
    position = zeros(20, 1);
    for i = 1:10
        position(i*2-1) = Node(i, 1);
        position(i*2) = Node(i, 2);
    end
    position(20) = [];
    position(19) = [];
    position(14) = [];
    position(13) = [];
    position(2) = [];
end