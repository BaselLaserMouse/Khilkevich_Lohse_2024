function subdirs = getsubdirs(rootDir)
% return subdirectories of specified root directory

subdirs = bdir(rootDir);
subdirs = subdirs([subdirs.isdir]);
subdirs = cellfun(@(x) [rootDir filesep x], {subdirs.name}, ...
            'uniformoutput', false);
