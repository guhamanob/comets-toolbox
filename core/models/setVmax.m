function [model, status] = setVmax( model, rxnNames, vmax )
%SETVMAX Set the Vmax of a reaction in a format to be included in a COMETS
%model file.
%Arguments:
% model: a Cobra model struct
% rxnName: the String name of a reaction as in model.rxns, or in 
%             model.rxnNames if not found in rxns.
%          Or a cell array of reaction names
%          Alternatively, the index of a reaction or an array of indexes
% vmax: the Double value to set
%     or 'default', 'd' or NaN to reset the value to the default
%
%Returns a modified model struct, and status = 1 if successful or 0 if the
%reaction could not be found.
%
% $Author: mquintin $	$Date: 2016/30/12 $	$Revision: 0.1 $
% Last edit: mquintin 12/30/2016
% Copyright: Daniel Segr�, Boston University Bioinformatics Program 2016
%

status = 0;
idx = -1;

%parse the reaction names
if ischar(rxnNames) %a single reaction name
    rxnNames = {rxnNames};
end
if iscell(rxnNames) %string names given
    idx = zeros(length(rxnNames));
    for i = 1:length(rxnNames)
        j = stridx(rxnNames{i},model.rxns,false);
        if isempty(j)
            j = stridx(rxnNames{i},model.rxnNames,false);
        end
        if ~isempty(j)
            idx(i) = j(1);
            status = 1;
        end
    end
end

if isnumeric(rxnNames) %works for a single index or an array
    idx = rxnNames;
end

%handle cases where the value is being reset
if isnan(vmax) || strcmpi('d',vmax) || strcmpi('default',vmax)
    vmax = NaN;
end

%initialize or grow the Vmax vector if necessary
if ~isfield(model,'vmax')
    model.vmax = NaN(length(model.rxns),1);
elseif length(model.vmax) < length(model.rxns)
    model.vmax(length(model.vmax)+1:length(model.rxns)) = NaN;
end

%set the value
for i=1:length(idx)
    j = idx(i);
    model.vmax(j) = vmax;
end

end