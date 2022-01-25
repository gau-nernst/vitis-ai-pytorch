# vitis-ai-pytorch

Dockerfiles for [Vitis AI](https://github.com/Xilinx/Vitis-AI) with only PyTorch. Optimize for smaller container images.

All Dockerfiles are modified from the official ones [here](https://github.com/Xilinx/Vitis-AI/tree/master/setup/docker/dockerfiles). Recommend to use Vitis AI 2.0.0, since it comes with PyTorch 1.7.1 by default.

## Pull image

To pull from Docker Hub

```bash
docker pull gaunernst/vitis-ai-pytorch:1.4.1-cpu
```

Change the tag accordingly to select different versions. Docker Hub page: https://hub.docker.com/r/gaunernst/vitis-ai-pytorch/tags

## Build image

To build

```bash
docker build --network=host -f 1.4.1/cpu.Dockerfile ./
```

For Vitis AI 1.4.1, you will also need `vai_q_pytorch` from [here](https://github.com/Xilinx/Vitis-AI/tree/master/tools/Vitis-AI-Quantizer/vai_q_pytorch) to build `pytorch_nndct` when upgrading to PyTorch 1.7.1
