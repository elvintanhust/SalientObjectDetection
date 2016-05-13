1.The Microsfot-1000 dataset can be downloaded from: http://research.microsoft.com/en-us/um/people/jiansun/SalientObject/salient_object.htm, ground truth data can be downloaded from: http://ivrlwww.epfl.ch/supplementary_material/RK_CVPR09/
2.To execute the programe, just run run_salient_detection.m
3.Under the "result" directory, ./100 is the original mapped superpixel fixation result,./101 is the original fixation ,./102 is the diffusion result of Lapacian Graph embedding,
 ./103 is the diffusion result of Manifold ranking,./104 is the diffuions result of CGEFD, ./105-1 is the diffusion result of CGEMD.

4. Please cite the following paper if you use the code for object detection:
 Yihua Tan,Yansheng Li,Chen Chen,Jin-Gang Yu,and Jinwen Tian. Cauchy graph embedding based diffusion model for salient object detection,Journal of the Optical Society of America A,2016,33(5):887-898