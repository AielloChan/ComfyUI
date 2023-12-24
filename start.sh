#!/bin/zsh

################## 配置区域 ##################

CONDA_ENV_NAME="comfyui"
CONDA_ENV_PYTHON_VERSION=3.11

############## 逻辑代码，不用修改 ##############

# 处理 homebrew
{
    if ! command -v brew &>/dev/null; then
        echo "Homebrew 未安装，正在安装 Homebrew (https://brew.sh/)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# 处理 mamba
{
    if command -v mamba &>/dev/null; then
        eval "$(mamba shell hook --shell bash)"
    elif command -v micromamba &>/dev/null; then
        alias mamba='micromamba'
        eval "$(mamba shell hook --shell bash)"
    else
        echo "mamba 未安装，正在安装 micromamba..."
        brew install micromamba -y
        micromamba shell init -s zsh -p ~/micromamba
        alias mamba='micromamba'
    fi
}

# 处理 mamba 环境
{
    if mamba env list | grep -q $CONDA_ENV_NAME; then
        mamba activate $CONDA_ENV_NAME
    else
        echo "$CONDA_ENV_NAME 环境不存在，创建中..."

        mamba config append channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
        mamba config append channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
        mamba config append channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge

        mamba create --name $CONDA_ENV_NAME python=$CONDA_ENV_PYTHON_VERSION -y
        mamba activate $CONDA_ENV_NAME
    fi
}

# 处理依赖
{
    # 以下就是先装一遍，因为如果有安装过，则不会重复安装
    pip install torch torchvision torchaudio
    pip install -r requirements.txt
}

# 启动
python main.py --force-fp16
