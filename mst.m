function [mpc_tree, t] = mst(mpc),
    function simplified_mpc = simplify_case(mpc),
        simplified_mpc = mpc;
        simplified_mpc.branch(:,5) = 0; % ignore shunt
        simplified_mpc.branch(:,11) = 1; % set status to on
        simplified_mpc.branch(:,3:4) = mpc.branch(:,3:4)/mpc.baseMVA;
        simplified_mpc.baseMVA = 1;
    end
    opt = mpoption('OUT_ALL', 0, 'VERBOSE', 0);
    mpc_tree = simplify_case(mpc);
    r = runpf(mpc_tree, opt);
    if r.success ~= 1,
        t = [];
        display('runpf failed');
        return;
    end
    r = ext2int(r);
    n = size(r.bus, 1);
    m = size(r.branch, 1);
    branchmap = sparse(n, n);
    DG = sparse(n, n); % directed graph
    values = -sqrt(sum(r.branch(:,[16 17]).^2,2));
    for line=1:m,
        i = r.branch(line,1);
        j = r.branch(line,2);
        value = values(line);
        prev = branchmap(i,j);
        % if multiple lines connect same two buses, take minimum
        if ~prev || value < values(prev), 
            branchmap(i,j) = line;
            branchmap(j,i) = line;
            DG(i, j) = value;
        end
    end
    UG = tril(DG + DG'); % undirected graph, MST function needs this
    t2 = graphminspantree(UG, 'Method', 'Kruskal');
    [i,j] = find(t2);
    t = full(branchmap(sub2ind([n n],i,j)));
    %sort(t)'
    %t = r.order.branch.i2e(t); # TODO: crap, do I need to worry about this?
    mpc_tree.branch = mpc_tree.branch(t, :);
end
