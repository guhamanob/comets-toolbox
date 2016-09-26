function xlsStruct=xls2struct(file,flag)
%xls2struct Load Excel file contents as a structure
% xlsstruct = xls2struct(file) loads the Excel file 'file'. The first row is
% used to generate the field names for the 1x1 structure xlsstruct. Each
% column (excluding the first row) is then converted to a numeric/cell
% array and assigned to the corresponding field name. All columns are
% expected to have equal number of entries.
%
% xlsstructArray = xls2struct(file,'structArray') will return a 1xNumCol
% structure array xlsstructArray. The kth element of the structure will
% have field names corresponding to the first row and values corresponding
% to the kth row.
%
% GENVARNAME is used to generate a valid MATLAB structure field name from
% the first row data.
%
% Blank entries are returned as 'NaN'.
%
% Platform support is dependent on XLSREAD.
%
% %Example: Given this Excel file content (9 columns, 5 rows):
%
% %one     two      three      four      ' '      six      se ven
% %1       2        3                             6        7
% %11      22       three
% %                                                        seven
% %        222      33
%
% xlsStruct=xls2struct('example.xls')
% % Where:
% %     xlsStruct.one'   =     1    11      NaN     NaN
% %     xlsStruct.two'   =     2    22      NaN     222
% %     xlsStruct.three' =     [3]  'three' [NaN]   [33]
% %     xlsStruct.four'  =     NaN  NaN     NaN     NaN
% %     xlsStruct.x'     =     NaN  NaN     NaN     NaN
% %     xlsStruct.six'   =     6    NaN     NaN     NaN
% %     xlsStruct.seVen' =     [7]  [NaN]   'seven' [NaN]
%
% xlsStructArray=xls2struct('example.xls','structArray')
% % Where:
% % xlsStructArray = 
% % 
% % 1x4 struct array with fields:
% %     one
% %     two
% %     three
% %     four
% %     x
% %     six
% %     seVen

% See also: xlsread genvarname

% Copyright (c) 2010, Ashish Uthama
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.


%% handle argin
if nargin < 1
    error('MATLAB:xls2struct:FileName',...
        'Input excel filename must be specified.');
elseif nargin ==1
    flag = '';
elseif nargin ==2
    if(strcmpi(flag,'structArray'))
        flag=true;
    else
        error('MATLAB:xls2struct:flag',...
            'Invalid second argument');
    end
else
    error('MATLAB:xls2struct:inputArgCount',...
        'Invalid number of input arguments.');
end


if ~ischar(file)
    error('MATLAB:xls2struct:InputClass','Filename must be a string.');
end


%% XLSREAD the file
try
    %obtain numeric and text data (mutually exclusive contents)
    [num,txt, raw]=xlsread(file);
catch ME
    error('MATLAB:xls2struct:xlsreaderr',...
        'XLSREAD was unable to read this file: %s',ME.message);
end

%% Process the data

% The cell array txt contains all the strings in the excel file
% including the first 'header' row which we assume to be variable names
[rows,numVars]=size(raw); %#ok<ASGLU>

%If the first column is all string, then the num matrix has one column
%less, so keep a dedicated index to the columns in num
numColInd=1; 

for varInd=1:numVars
    
    %loop through each column in the excel sheet
    
    %Assume first row element in the current column is the variable name
    varName=txt{1,varInd};
    
    %since this string might not be a valid MATLAB variable name (it might
    %contain spaces, create one from it:
    varName=genvarname(varName);
    
    %if there is a string in this column (other than the first one of
    %course) we create a cell array for the data.
    stringData=txt(2:end,varInd);
    strInds=~cellfun(@isempty,stringData);
    
    if( any(strInds) )
        %this column contains strings, use cells
        varData={};
        
        try %#ok<TRYNC>
            %try to convert any numbers present in this column to cells
            varData=num2cell( num(:,varInd) );
        end
        varData(strInds)=stringData(strInds); %#ok<AGROW>
        
    else
        %this column only contains numbers, use arrays
        varData=num(:,numColInd);        
        numColInd=numColInd+1;
               
        if(flag)
            %we need a cell array to 'deal' to fields of structure array
            varData=num2cell(varData);
        end      
        
    end
        
    
    %Use dynamic field names for MATLAB structures
    if(flag)
        %create structure array as output
        [xlsStruct(1:length(varData)).(varName)]=deal(varData{:});
    else
        %create field arrays as output
        xlsStruct.(varName)=varData;
    end
    
end


