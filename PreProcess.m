%% Make a unique list of land uses
LU = imread('Local/model_input_LU2005.tif');
LU_cat = unique(LU);
%% Find names for each LU category
% temp1 has all the numerical values and temp2 the text values
[temp1, temp2] = xlsread('Local/LanduseTable_2017_0515.xlsx', 'FINAL Landuse Table','A2:E208');
for ii = 1:length(LU_cat)
   id = find( temp1(:,1) == LU_cat(ii));
   LU_name{ii,1} = temp2{id,1};
end
%% save this to a mat file
save('LU_data', 'LU_cat','LU_name');
%% Create an Raster Ascii for GIS. This is just for test purposes
% from the Local/Ngw_2005.tif.xml it appears that the 
% left lower corner of the raster is at -223300, -344600
% and that the cell size is 50 m
% The coordinate system is the EPSG: 3310
WriteAscii4Raster('Local/LU_2005_ascii',LU, -223300, -344600, 50, 0);
%% Load URF data and make sure they are in the same coordinate system
% First make one variable with all streamline points
URFS = [];
for ii = 1:6 % This is the number of processors used in the simulation
    % w = load(['Local/Tule/wellURFS_000' num2str(ii-1) '.mat']);
    w = load(['Local/Tule/TuleRiverURFs_' num2str(ii-1) '.mat']);
    URFS = [URFS; w.WellURF];
end
%% Create a shapefile with the streamlines points at the land side.
% This shape file will be overlaid onto raster and convert the coordinates
% The coordinates of this shapefile are in EPSG:26911 
clear S
S = [];
S(size(URFS,1), 1).Geometry = [];
S(size(URFS,1), 1).X = [];
S(size(URFS,1), 1).Y = [];
S(size(URFS,1), 1).Eid = [];
S(size(URFS,1), 1).Sid = [];
for ii = 1:size(URFS,1)
   S(ii,1).Geometry = 'Point';
   S(ii,1).X = URFS(ii,1).p_lnd(1);
   S(ii,1).Y = URFS(ii,1).p_lnd(2);
   S(ii,1).Eid = double(URFS(ii,1).Eid);
   S(ii,1).Sid = double(URFS(ii,1).Sid);
   S(ii,1).Vland = URFS(ii,1).v_lnd;
end
shapewrite(S,'Local/Tule/TuleStrmlnPoints');
%% load the converted shapefile
% The converted shapefile has coordinates on EPSG:3310
% S = shaperead('gis_data/TuleStrmlnPoints');
S = shaperead('gis_data/TuleStrmlnPointsHome');
%% Save all data into one file for loading from python
years = 1945:15:2050;
for ii = 1:8
    if ii <= 5
        eval(['LU' num2str(years(ii)) ' = LUmaps{' num2str(ii) ',1};']);
    end
    eval(['Ngw' num2str(years(ii)) ' = Ngw{' num2str(ii) ',1};']);
end
%%
LUcat = LU.LU_cat;
save('data4python.mat', 'LUcat', 'LU1945','Ngw1945','-v7');
for ii = 2:8
    if ii <= 5
        save('data4python.mat',['LU' num2str(years(ii))], ['Ngw' num2str(years(ii))], '-append');
    else
        save('data4python.mat', ['Ngw' num2str(years(ii))], '-append');
    end
    
end
%% 
Spnts = shaperead('gis_data/TuleStrmlnPointsHome');
Sxyv = [[Spnts.X]' [Spnts.Y]' [Spnts.Vland]'];
Sid =  [[Spnts.Eid]' [Spnts.Sid]'];
urfs = zeros(size(URFS.URFS,1),200);
for ii = 1:size(URFS.URFS,1)
    urfs(ii,:) = URFS.URFS(ii,1).URF;
end
urfV = [URFS.URFS.v_lnd]';
save('URFdata.mat', 'Sxyv', 'Sid', 'urfs', 'urfV', '-v7');
%%

