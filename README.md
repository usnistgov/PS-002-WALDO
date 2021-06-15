# PS-002 WALDO (Wireless Artificial intelligence Location DetectiOn)), we finally know where you are: sensing using mmWave communications and ML.
> Software and dataset resource for ITU AI/ML 5G Challenge.

## Table of Contents
* [Installation](#installation)
* [Requirements](#requirements)
* [Download Dataset](#download-dataset)
* [How to generate dataset](#how-to-generate-dataset)
* [License](#license)

## Installation
The software does not require any installation procedure: simply download or clone the repository to your local folders.

### Requirements
The codebase to generate the dataset is written in MATLAB. It is currently being tested on MATLAB R2020b.
No toolboxes are needed to run the code.

The dataset has been alredy generated and it can be downloaded directly (see [Download Dataset](#download-dataset))

## Download dataset
The dataset is available to download at https://data.nist.gov/od/id/mds2-2417
To download the dataset run the matlab script dataset/downloadDataset.m or the phyton script dataset/downloadDataset.py

## How to generate dataset
* Download dataset
* Run the `scriptGenerateRxSig.m` script

## License
Please refer to the [LICENSE](LICENSE) file for more information.
