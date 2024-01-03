#!/bin/zsh

################## 配置区域 ##################

CONDA_ENV_NAME="comfyui"
CONDA_ENV_PYTHON_VERSION=3.11

############## 逻辑代码，不用修改 ##############

set -e

# 处理 homebrew
{
    if ! command -v brew &>/dev/null; then
        echo "Homebrew 未安装，正在安装 Homebrew (https://brew.sh/)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# 处理 conda
{
    if command -v conda &>/dev/null; then
        eval "$(conda shell.bash hook)"
    else
        echo "conda 未安装，正在安装 miniconda..."
        brew install miniconda
    fi
}

# 处理 conda 环境
{
    conda init bash

    if conda env list | grep -q $CONDA_ENV_NAME; then
        conda activate $CONDA_ENV_NAME
    else
        echo "$CONDA_ENV_NAME 环境不存在，创建中..."
        conda create --name $CONDA_ENV_NAME python=$CONDA_ENV_PYTHON_VERSION -y
        conda activate $CONDA_ENV_NAME
    fi
}

# 处理依赖
{
    # 以下就是先装一遍，因为如果有安装过，则不会重复安装
    pip install torch torchvision torchaudio 'httpx[socks]'
    pip install -r requirements.txt
}

# 启动
python main.py --force-fp16
