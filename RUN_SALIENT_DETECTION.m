
clear all; close all; clc;

%% the global parameter
spnumberList   = [100,200,300,400];

Input_Dir  = ['.\' 'DataSet-1000' '\'];
Super_Dir  = '.\Superpixels\'; mkdir(Super_Dir);
Result_Dir = '.\Result\';      mkdir(Result_Dir);

addpath('.\SRC\');
addpath('.\SRC\corner_voting\'); 
addpath('.\SRC\corner_color_voting\');
addpath('.\SRC\graph_cut\');

INTER_RES_DIR = '.\SRC\superpixels\'; mkdir(INTER_RES_DIR);


%% the src code
imNames  =dir([Input_Dir '*' 'bmp']);
for ii = 1:length(imNames)
     %if(strcmp(imNames(ii).name,'0_0_272.bmp'))
       % imNames(ii).name ='1_59_59909.bmp';
        InputFile = [Input_Dir imNames(ii).name];
       
        [InputImg,w] = removeframe(InputFile);
    
          % eye fixation
            
          out = gbvs(InputFile);
          % you can choose the alternative fixation algorihtm(Itti's)
          %out = ittikochmap(InputFile); 
         fixResult = out.master_map_resized;
         
        [m n k] = size(InputImg);
        temp1 = zeros(m,n); temp2 = zeros(m,n); temp3 = zeros(m,n); temp4 = zeros(m,n);    
        for jj = 1:length(spnumberList)
            spnumber = spnumberList(jj);
            % segment the original image for re-grouping
            
            comm   = ['SLICSuperpixelSegmentation' ' ' InputFile ' ' int2str(40) ' ' int2str(spnumber) ' ' Super_Dir]; system(comm);    
            spname = [Super_Dir imNames(ii).name(1:end-4)  '.dat'];
            Superpixels =ReadDAT([m,n],spname);
          
            % extract the covariance feature on the mid-level
            [Spatial_Covariance, Spatial_Feature, Spatial_Coordinate] = cal_Spatial_Feature(InputImg,Superpixels);
                   
            
            % superpixel mapping
            fixSPResult = spMapping(Superpixels,fixResult);

%             graph optimization
            alpha = 10; beta = 0; sigama = 0.1; delta = 1.0;
            % Lapacian Embedding algorithm
            [salientMapBySpRefinedLGraphSmoothingUnor, binResultBySpLGraphSmoothingUnor]   = resultRefiningbyLaplacianEmbedding(fixSPResult,Superpixels,Spatial_Feature,alpha,beta,sigama);
            % Manifold Ranking Algorihtm
            [salientMapBySpRefinedLGraphSmoothingNor, binResultBySpLGraphSmoothingNor]     = resultRefiningbyManifoldRanking2(fixSPResult,Superpixels,Spatial_Feature,sigama,2);
            
            %Cauchy Embedding
            [salientMapBySpRefinedCGraphSmoothing1, binResultBySpCGraphSmoothing1]         = resultRefiningbyCaucyEmbedding(fixSPResult,Superpixels,Spatial_Feature,alpha,beta,sigama,1,2);
                        
            imshow(salientMapBySpRefinedCGraphSmoothing1);
            [salientMapBySpRefinedCGraphSmoothingProc]                                     = preProcessRes(salientMapBySpRefinedCGraphSmoothing1);
                        
            [salientMapBySpRefinedCGraphSmoothing2, binResultBySpCGraphSmoothing2]         = resultRefiningbyCaucyEmbedding(salientMapBySpRefinedCGraphSmoothingProc,Superpixels,Spatial_Feature,alpha,beta,sigama,0.1,2);
           
                      
            
            % change to the original size
            salientMapBySpRefinedLGraphSmoothingUnorRes =zeros(w(1),w(2)); salientMapBySpRefinedLGraphSmoothingUnorRes(:) = min(salientMapBySpRefinedLGraphSmoothingUnor(:));
            salientMapBySpRefinedLGraphSmoothingUnorRes(w(3):w(4),w(5):w(6)) = salientMapBySpRefinedLGraphSmoothingUnor;
            
            salientMapBySpRefinedLGraphSmoothingNorRes =zeros(w(1),w(2)); salientMapBySpRefinedLGraphSmoothingNorRes(:) = min(salientMapBySpRefinedLGraphSmoothingNor(:));
            salientMapBySpRefinedLGraphSmoothingNorRes(w(3):w(4),w(5):w(6)) = salientMapBySpRefinedLGraphSmoothingNor;
            
            salientMapBySpRefinedCGraphSmoothing1Res =zeros(w(1),w(2)); salientMapBySpRefinedCGraphSmoothing1Res(:) = min(salientMapBySpRefinedCGraphSmoothing1(:));
            salientMapBySpRefinedCGraphSmoothing1Res(w(3):w(4),w(5):w(6)) = salientMapBySpRefinedCGraphSmoothing1;
            
            salientMapBySpRefinedCGraphSmoothing2Res =zeros(w(1),w(2)); salientMapBySpRefinedCGraphSmoothing2Res(:) = min(salientMapBySpRefinedCGraphSmoothing2(:));
            salientMapBySpRefinedCGraphSmoothing2Res(w(3):w(4),w(5):w(6)) = salientMapBySpRefinedCGraphSmoothing2;
            
            if jj == 1
                fixSPResult = fixSPResult + mat2gray(fixSPResult);
                temp1 = mat2gray(salientMapBySpRefinedLGraphSmoothingUnorRes);
                temp2 = mat2gray(salientMapBySpRefinedLGraphSmoothingNorRes);
                temp3 = mat2gray(salientMapBySpRefinedCGraphSmoothing1Res);
                temp4 = mat2gray(salientMapBySpRefinedCGraphSmoothing2Res);
            else
                fixSPResult = fixSPResult + mat2gray(fixSPResult);                      % original mapped fixation result
                temp1 = temp1 + mat2gray(salientMapBySpRefinedLGraphSmoothingUnorRes); % Lapacian result
                temp2 = temp2 + mat2gray(salientMapBySpRefinedLGraphSmoothingNorRes);  % Manifold Ranking
                temp3 = temp3 + mat2gray(salientMapBySpRefinedCGraphSmoothing1Res);    % CG result of first stage
                temp4 = temp4 + mat2gray(salientMapBySpRefinedCGraphSmoothing2Res);    %CG result of second stage
            end
            out_Dir0 = [Result_Dir '100\multi\']; mkdir(out_Dir0);
            out_filename0 = [out_Dir0 imNames(ii).name(1:end-4) '_' num2str(spnumber) '.jpg'];
            imwrite(mat2gray(fixSPResult),out_filename0);
%         end

            % output the gray and binary result
            
            out_Dir1 = [Result_Dir '101\']; mkdir(out_Dir1);
            out_Dir2 = [Result_Dir '102\']; mkdir(out_Dir2);
            out_Dir3 = [Result_Dir '103\']; mkdir(out_Dir3);
            out_Dir4 = [Result_Dir '104\']; mkdir(out_Dir4);
            out_Dir5 = [Result_Dir '105_1\']; mkdir(out_Dir5);

            
            out_filename1 = [out_Dir1 imNames(ii).name(1:end-4) '.jpg'];                     
            out_filename2 = [out_Dir2 imNames(ii).name(1:end-4) '.jpg'];     
            out_filename3 = [out_Dir3 imNames(ii).name(1:end-4) '.jpg'];
            out_filename4 = [out_Dir4 imNames(ii).name(1:end-4) '.jpg'];     
            out_filename5 = [out_Dir5 imNames(ii).name(1:end-4) '.jpg'];  

            
            imwrite(mat2gray(fixResult),out_filename1);
            imwrite(mat2gray(temp1),out_filename2);
            imwrite(mat2gray(temp2),out_filename3);
            imwrite(mat2gray(temp3),out_filename4);
            imwrite(mat2gray(temp4),out_filename5);
            
            
            
        end    
end

