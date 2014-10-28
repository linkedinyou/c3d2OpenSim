c3d2Opensim
================
Matlab code for processing c3d motion data into OpenSim format.

### Quick Start

- Download btk-c3d software and put in Matlab path.
The matlab (64-bit tested) binaries can be downloaded from here; https://code.google.com/p/b-tk/wiki/MatlabBinaries

- Download zip of this project. Unzip folder and put in Matlab Path.

- Type 'c3d2Opensim' in the matlab command window, If previous steps have been completed successfully, a selection window will appear and by selecting a c3d file, a marker file (.trc) and a ground reaction force file (.mot) will be created.

- You can setup a batch script by sending it a path to a c3d file ie c3d2Opensim('C:\MoCapData\subject1_trial1.c3d').

- If you have issues, please post to the issue section on Github

Gdluck and please contribute back to the code.

### Sending inputs to the function

Input arguments using the name (string) followed by the input variable. The below example uses the file 'example.c3d', rotates the data 90 degrees about Z then 90 degrees about X, filters the markers with a butterworth filter at 16Hz and the ground reaction forces with a critically damped filter at 40Hz,  and only exports the markers named LTH1, LTH2, RTH1, RTH2, RTH3.


```matlab
c3d2Opensim( 'c3dFilePath','C:\path2c3dFile\example.c3d', ...
             'rotation', {'z' 90 'x' 90}, ...
             'filter', {'mrks' 'butt' 16 'grf' 'critt' 40},...
             'mrkList', {'LTH1' 'LTH2' 'RTH1' 'RTH2' 'RTH3'});
```

The below code block uses 'example2.c3d', rotates the data 90 degrees about X and filters the ground reaction forces with a butterworth filter at 40Hz. No marker filtering occurs and all markers are exported.


```matlab
c3d2Opensim( 'c3dFilePath','C:\path2c3dFile\example2.c3d', ...
             'rotation', {'x' 90}, ...
             'filter', {'grf' 'butt' 40});
```



### Limitations and known issues

- This has only been tested on Force platforms of type 2. The outputs of the forceplate must be 3 forces (fx,fy,fz) and three moments (mx,my,mz). If you have unsupported force plates, please post a request.

- The c3d must have at least marker data in it. You don't need to have forces.

- The string 'static' in the name of the c3d file will skip any force processing and just generate a .trc.  

- We don't process other types of analog data (EMG). This will be in a future release.  

### Acknowledgements

First, we would like to acknowledge Arnaud Barre and Stephane Armand for their wonderful BTK (Biomechanical Toolkit) software, which is used for c3d reading. We are sure that we are not leveraging it as much as we could. Please support the btk project.

Barre, A. Armand, S. (2014) Biomechanical ToolKit: Open-source framework to visualize and process biomechanical data. Computer methods and programs in biomedicine. 114:1 Page: 80 - 87 (http://www.sciencedirect.com/science/article/pii/S0169260714000248)

We would also like to acknowledge Thor Besier (U Ackland), Cyril Donnelly (U Western Australia) and Glen Litchwark (U Queensalnd) for their significant code contributions to the c3d2OpenSim pipeline.

### Licensing
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
