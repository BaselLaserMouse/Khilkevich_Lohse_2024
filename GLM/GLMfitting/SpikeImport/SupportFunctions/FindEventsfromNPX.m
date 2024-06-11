  function [AllEventTimes]  = FindEventsfromNPX(folderSorted); 
  
  cd .. % text files are on folder back
    
  % extract event times from text files
    BO=dir('*nidq.XA_1_0.txt'); % stim ON
    BaseON_Times=load(BO.name);
    
    CO=dir('*nidq.XA_2_0.txt'); % change ON
    ChangeON_Times=load(CO.name);
    
    R1O=dir('*nidq.XA_4_0.txt'); % Lick ON
    Resp1ON_Times=load(R1O.name);
    clear BO CO R1O
    
    cd(folderSorted) % return to original folder
    
    AllEventTimes{2}=BaseON_Times;
    AllEventTimes{3}=ChangeON_Times;
    AllEventTimes{5}=Resp1ON_Times;
    