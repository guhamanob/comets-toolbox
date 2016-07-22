function createCometsParamsFile( directory, filename, params )
%CREATECOMETSPARAMSFILE Create the Comets params file for a COMETS run.
%Input:
%   directory: location of the output file
%   filename: name of the params file
%   params: a CometsParams object

%field names and values should be case insensitive.

%names of possible fields
allparams = {'timeStep',...
    'deathRate',...
    'activeRate',...
    'maxSpaceBiomass',...
    'minSpaceBiomass',...
    'spaceWidth',...
    'slideshowColorValue',...
    'spaceVolume',...
    'isCommandLine',...
    'showGraphics',...
    'allowCellOverlap',...
    'toroidalWorld',...
    'showCycleTime',...
    'showCycleCount',...
    'pause',...
    'pauseOnStep',...
    'saveSlideShow',...
    'showText',...
    'colorRelative',...
    'slideshowColorRelative',...
    'simulateActivation',...
    'displayLayer',...
    'pixelScale',...
    'gridRows',...
    'gridCols',...
    'gridLayers',...
    'maxCycles',...
    'diffusionsPerStep',...
    'mediaRespawnRate',...
    'slidshowRate',...
    'slideshowLayer',...
    'slideshowName',...
    'lastDirectory',...
    };

%ensure these are written as 'true' or 'false'
booleanparams = {'isCommandLine','showGraphics','allowCellOverlap',...
    'toroidalWorld','showCycleTime','showCycleCount','pause',...
    'pauseOnStep','saveSlideshow','showText','colorRelative',...
    'slideshowColorRelative','simulateActivation'};

f = fopen(fullfile(directory,filename),'w');

pfields = fields(params);
usedIdx = ismember(upper(pfields),upper(allparams));
used = pfields(usedIdx); %the names of fields which occur in the given CometsParams

    function printparam(name)
        val = params.(name);
        if ismember(upper(name),upper(booleanparams))
            if val
                fprintf(f,'%s = true \n',name);
            else
                fprintf(f,'%s = false \n',name);
            end
        elseif isnumeric(val)
            fprintf(f,'%s = %d \n',name,val);
        else
            fprintf(f,'%s = %s \n',name,val);
        end
    end

cellfun(@printparam,used);%do the writing

fclose(f);

end
