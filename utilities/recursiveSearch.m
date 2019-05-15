function [fPaths] = recursiveSearch(fDir,varargin)
% Performs recursive search for all files under a parent directory for
% files containing target extension or keyword

target_ext = '.mat';
opts={};
fPaths = {};

for i=1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'ext'
                i=i+1;
                target_ext = varargin{i};   % restricts files to those with target extension
            case 'keyword'
                i=i+1;
                key = varargin{i};          % restricts files to those with keyword in the name
                opts = [opts{:},{'keyword',key}];
        end
    end
end

if isempty(fDir) || (~iscell(fDir) && ~ischar(fDir))...
        || (~iscell(fDir) && ~(exist(fDir,'file')==2 || exist(fDir,'dir')==7))
   return; 
end
if ~iscell(fDir)
   fDir = {fDir}; 
end
if isempty(fDir)
    fDir = pwd;
end

for i=1:numel(fDir)
    if any(strcmpi({'\';'/'},fDir{i}(end)))
        fDir{i}(end) = [];
    end
end

% pack input options into cell
opts = [opts{:} {'ext',target_ext}];

% get directory info and restrict contents to subdirectories
%dir_info = cellfun(@(d) dir(d), fDir, 'UniformOutput', false);
for j=1:numel(fDir)
    
    dir_info = dir(fDir{j});
    dirs = dir_info([dir_info.isdir]);
    files = dir_info(~[dir_info.isdir]);

    for i=1:numel(files)

        [path,name,ext]=fileparts([fDir{j} '/' files(i).name]);

        if strcmpi(ext,target_ext) && exist('key','var') && ~isempty(strfind(name,key))
            path = [path '/' name ext];
            fPaths = [fPaths {path}];
        elseif strcmpi(ext,target_ext) && ~exist('key','var')
            path = [path '/' name ext];
            fPaths = [fPaths {path}];
        end

    end

    ignore = {'.';'..';};
    for i=1:numel(dirs)

        if ~any(strcmpi(dirs(i).name,ignore))

            subdir = [fDir{j} '/' dirs(i).name];
            subpaths = recursiveSearch(subdir,opts{:});

            if ~isempty(subpaths)
                fPaths = [fPaths;subpaths];
            end

        end
    end
    
end


fPaths = cellfun(@unixify, fPaths, 'UniformOutput',false);

if size(fPaths,2) > size(fPaths,1)
    fPaths = fPaths';
end

