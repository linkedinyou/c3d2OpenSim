c3d2Opensim
================
Matlab code for processing c3d motion data and modeling using the OpenSim API. 

## Quick Start 

1. Download btk-c3d software and put in Matlab path.
The matlab (64-bit tested) binaries can be downloaded from here; https://code.google.com/p/b-tk/wiki/MatlabBinaries

2. Download zip of this project. Unzip folder and put in Matlab Path.

3. Type 'c3d2Opensim' in the Matlab command window. If previous steps have been completed successfully, a selection window will appear and by selecting a c3d file, a marker file (.trc) and a ground reaction force file (.mot) will be created. 

4. You can setup a batch script by sending it a path to a c3d file ie c3d2Opensim('C:\MoCapData\subject1_trial1.c3d').

5. If you have issues, please post to the issue section on Github

Gdluck and please contribute back to the code. 

## Limitations and known issues ##

- We only support Force platforms of type 2 and 4. The outputs of the forceplate must be 3 forces (fx,fy,fz) and three moments (mx,my,mz). If you have unsupported force plates, please post a request. 

- The c3d must have at least marker data in it. You don't need to have forces. 

- The string 'static' in the name of the c3d file will skip any force processing and just generate a .trc.  

- We don't process other types of analog data (EMG). This will be in a future release.  

## Acknowledgements ##

First, we would like to acknowledge Arnaud Barre and Stephane Armand for their wonderful BTK (Biomechanical Toolkit) software, which is used for c3d reading. We are sure that we are not leveraging it as much as we could. Please support the btk project. 

Barre, A. Armand, S. (2014) Biomechanical ToolKit: Open-source framework to visualize and process biomechanical data. Computer methods and programs in biomedicine. 114:1 Page: 80 - 87 (http://www.sciencedirect.com/science/article/pii/S0169260714000248)

We would also like to acknowledge Thor Besier (U Ackland), Cyril Donnelly (U Western Australia) and Glen Litchwark (U Queensalnd) for their significant code contributions to the c3d2OpenSim pipeline. 

## Licensing ##
Licensed under the Apache License, Version 2.0 (the "License");         
you may not use this file except in compliance with the License.        
You may obtain a copy of the License at                                 
http://www.apache.org/licenses/LICENSE-2.0.                             
                                                                         
Unless required by applicable law or agreed to in writing, software     
distributed under the License is distributed on an "AS IS" BASIS,       
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         
implied. See the License for the specific language governing            
permissions and limitations under the License.                          
