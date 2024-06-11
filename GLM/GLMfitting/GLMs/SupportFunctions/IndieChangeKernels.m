if BehavData.Raw.changeTF{SelectTrial}==1
    trial(curTrial).changeON0 = BehavData.Raw.BaseT(SelectTrial)*1000;
    trial(curTrial).changeON1 = NaN;
    trial(curTrial).changeON2 = NaN;
    trial(curTrial).changeON3 = NaN;
    trial(curTrial).changeON4 = NaN;
    trial(curTrial).changeON5 = NaN;
    
elseif BehavData.Raw.changeTF{SelectTrial}==1.25
    trial(curTrial).changeON0 = NaN;
    trial(curTrial).changeON1 = BehavData.Raw.BaseT(SelectTrial)*1000;
    trial(curTrial).changeON2 = NaN;
    trial(curTrial).changeON3 = NaN;
    trial(curTrial).changeON4 = NaN;
    trial(curTrial).changeON5 = NaN;
    
elseif BehavData.Raw.changeTF{SelectTrial}==1.35
    trial(curTrial).changeON0 = NaN;
    trial(curTrial).changeON1 = NaN;
    trial(curTrial).changeON2 = BehavData.Raw.BaseT(SelectTrial)*1000;
    trial(curTrial).changeON3 = NaN;
    trial(curTrial).changeON4 = NaN;
    trial(curTrial).changeON5 = NaN;
    
elseif BehavData.Raw.changeTF{SelectTrial}==1.5
    trial(curTrial).changeON0 = NaN;
    trial(curTrial).changeON1 = NaN;
    trial(curTrial).changeON2 = NaN;
    trial(curTrial).changeON3 = BehavData.Raw.BaseT(SelectTrial)*1000;
    trial(curTrial).changeON4 = NaN;
    trial(curTrial).changeON5 = NaN;
    
elseif BehavData.Raw.changeTF{SelectTrial}==2
    trial(curTrial).changeON0 = NaN;
    trial(curTrial).changeON1 = NaN;
    trial(curTrial).changeON2 = NaN;
    trial(curTrial).changeON3 = NaN;
    trial(curTrial).changeON4 = BehavData.Raw.BaseT(SelectTrial)*1000;
    trial(curTrial).changeON5 = NaN;
    
elseif BehavData.Raw.changeTF{SelectTrial}==4
    trial(curTrial).changeON0 = NaN;
    trial(curTrial).changeON1 = NaN;
    trial(curTrial).changeON2 = NaN;
    trial(curTrial).changeON3 = NaN;
    trial(curTrial).changeON4 = NaN;
    trial(curTrial).changeON5 = BehavData.Raw.BaseT(SelectTrial)*1000;  
    
end