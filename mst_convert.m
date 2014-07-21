function casefile = mst_convert(casefile),
    function prepend2file(string, filename)
        tempFile = tempname;
        fw = fopen(tempFile, 'wt');
        fwrite(fw, sprintf('%s\n', string));
        fclose(fw);
        appendFiles(filename, tempFile);
        copyfile(tempFile, filename);
        delete(tempFile);
    end
    function status = appendFiles(readFile, writtenFile)
        fr = fopen(readFile, 'rt');
        fw = fopen(writtenFile, 'at');
        while feof(fr) == 0
            tline = fgetl(fr);
            fwrite(fw, sprintf('%s\n',tline));
        end
        fclose(fr);
        fclose(fw);
    end
    mpc = loadcase(casefile);
    mpc_tree = mst(mpc);
    opt = mpoption('OUT_ALL', 0);
    mpc_tree = runpf(mpc_tree, opt);
    filename = strcat(casefile(1:end-2), '_tree.m');
    savecase(filename, mpc_tree);
    if mpc_tree.success == 1,
        string = 'converged';
    else,
        string = 'failed';
    end
    prepend2file(string, filename);
end
