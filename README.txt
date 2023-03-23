Harmonic Optical Tomography Data

"z-stack" refers to the [N x N x z] hologram data & reconstructed E-Fields. 
Images are recorded at different z positions by moving the sample in the axial direction of the defocused illuminating beam. 

--Functions--
Matlab scripts/functions used to reconstruct hologram images. 
"Hologram_Image_Reconstruction.m" is the main script used to create a z-stack of E-fields.
Implement "Hologram_Image_Reconstruction" section by section, and read commented sections for help.
Ensure other functions "HoloFilterGen3_yrf.m" and "MeasureReferenceTilt2_yrf.m" are in matlab file path.
The function "saveastiff.m" was acquired from Mathworks File Exchange (https://www.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack)

--Previous_SHG_HOT_data--
This folder contains raw data acquired by Jeff Field ("Hologram_zstack_BBO_50NAcondenser_Jeff_old_SHG_HOT" and "Reference_BBO_50NAcondenser_Jeff_old_SHG_HOT")
The data is second harmonic generation holographic images of a beta barium oxide crystal. 
This is a similar set of data that was used in the PNAS publication "Harmonic Optical Tomography of Nonlinear Structures (2020)".
Within this folder contains an E-Field zstack of data that has been reconstructed using "Hologram_Image_Reconstruction.m".


--THG_holography_data--
This folder contains the ongoing work (starting Winter 2023) of performing THG HOT.
The data set includes a THG holography of a ~10 micron glass sphere suspended in agarose. 

