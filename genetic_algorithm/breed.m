% Sample input: (genomes, 3, newMets)
% newMets={'ATP', 'Citrate', 'Ethanol','L-Maltatem','D-Lactate'}
function modGenomes=breed(genomesArray, numStaySame, newMets)
    genomeSize=length(genomesArray);
    copyGen=genomesArray;  

    % First three genomes are populated by the three fittest genomes from
    % prior generation
    for i=1:numStaySame
        maxScore=0;
        index=1;
        for k=1:genomeSize
            if copyGen(k).score>maxScore
                temp=copyGen(k);
                index=k;
                maxScore=copyGen(k).score;
            end
        end
        modGenomes(i)=temp;
        copyGen(index).score=0;
        maxIndicies(i)=index;
    end
    
    %TODO: Paramterize # of cross breeding/mutating
    diff=genomeSize-numStaySame;
    if mod(diff,2)~=0
        diff=diff+1;
    end
    for i=numStaySame+1:genomeSize
        % Cross-Breeding
        counter=1;
        for j=1:diff/2  
            max1=maxIndicies(j);
            if mod(counter,2)~=0 % Allows for both recombinations
                max2=maxIndicies(j+1);
            else
                max2=maxIndicies(j-1);
            end
                g1=genomesArray(max1);
                g2=genomesArray(max2);
                sq1=g1.sequence;
                models1=sq1(g1.endOfMets+1:length(sq1));
                sq2=g2.sequence;
                mets2=sq2(1:g2.endOfMets);
                tempG=Genome();
                tempG=tempG.addMetsAndModels(mets2,models1);
                modGenomes(numStaySame+counter)=tempG;
                counter=counter+1;
        end
        
        % Mutations
        mut=1;
        metPos=genomesArray(i).endOfMets;
        posOfMutation=randi(1,metPos);
        for k=genomeSize-numStaySame+(counter):genomeSize
            genIndex=maxIndicies(mut);
            gen=genomesArray(genIndex);
            
            randMet=randi([1,length(newMets)]);
            gen.sequence(posOfMutation)=newMets(randMet);
            modGenomes(k)=gen;
            mut=mut+1;
        end
        
        % Scores for new mutants
        for i=numStaySame+1:genomeSize
            modGenomes(i)=modGenomes(i).getScore();
        end
    end
end
