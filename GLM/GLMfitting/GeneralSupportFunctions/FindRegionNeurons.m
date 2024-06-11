
ROI='SNr'; % find neurons in this region i.e. SNr

for r=1:length(data.x1116764.ML_1116764_S04_M2_SNr.NPX_probes(2).good_cl_coord)
SU_region{r}=data.x1116764.ML_1116764_S04_M2_SNr.NPX_probes(2).good_cl_coord(r).brain_region;
end

GoodROI_Id=find(strcmp(SU_region,ROI));


