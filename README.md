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
The dataset is available to download at https://data.nist.gov/od/id/mds2-2417.
There are two options to generate the received signals, which need to be used as the input of ITU AI/ML 5G Challenge.

* Option 1: download the received signals dataset, which has been alredy generated.
  * Execute the matlab script dataset/downloadDataset.m or the phyton script dataset/downloadDataset.py
  * A menu will display multiple download options: enter S to download the received signals.
There are 46738 files in the dataset with a total size of 850.475747 GB.
The download  might take long time depending on the network and local storage speed. 
A progress percentage reports the download status.
  * The received signals are downloaded in dataset\rxSignal.

* Option 2: download channel data and generate received signals.
  * Execute the matlab script dataset/downloadDataset.m or the phyton script dataset/downloadDataset.py
  * A menu will display multiple download options: enter C to download the received signals.
There are 15582 files in the dataset with a total size of 394.556356 GB. The download  might take long time depending 
on the network and local storage speed. 
A progress percentage reports the download status.
  * When the download is completed, execute the script receivedSignalGeneration/scriptGenerateRxSig.m. The script is 
generating a transmit signal, pass it trough the downloaded channels and add AWGN noise. The received signals are stored in dataset\rxSignal


## How to generate dataset
* Download dataset
* Run the `scriptGenerateRxSig.m` script

## License
Please refer to the [LICENSE](LICENSE) file for more information.
