# LPQ++: A Discriminative Blur-insensitive Textural Descriptor with Spatial-channel Interaction
This is the official Matlab implementation for "LPQ++: A Discriminative Blur-insensitive Textural Descriptor with Spatial-channel Interaction".
![LPQ++](https://github.com/hustzhzhu/LPQplusplus/blob/main/IMG/main_idea.jpg)

## Citation
~~~
@article{zhu2020lpq++,
  title={LPQ++: A Discriminative Blur-insensitive Textural Descriptor with Spatial-channel Interaction},
  author={Zhu, Zihao and Xiao, Yang and Li, Shuai and Cao, Zhiguo and Fang, Zhiwen and Zhou, Joey Tianyi},
  journal={Information Sciences},
  year={2020},
  publisher={Elsevier}
}
~~~

## Installation
This code is tested on Windows Server 2012, Matlab R2014b.<br>
1. Install Matlab.<br>
2. LIBSVM package is required. The package has already been placed in the folder "./code/Libsvm".<br>
3. VLFeat package is required. The package has already been placed in the folder "./code/vlfeat-0.9.20". Installation details can be acquired [Here](https://www.vlfeat.org/sandbox/install-matlab.html).<br>

## Run 
To excecute LPQ++ for blurred texture recognition on [KTH-TIPS](https://www.csc.kth.se/cvap/databases/kth-tips/download.html) dataset:<br>
~~~
cd code
run LPQplusplus_classification.m
~~~

## Contact
For any question, please contact Zihao Zhu zihaozhu@hust.edu.cn
