sudo apt update
sudo apt install git python3-pip python3-venv python3-dev libstdc++-12-dev
sudo apt update
wget https://repo.radeon.com/amdgpu-install/5.7.1/ubuntu/jammy/amdgpu-install_5.7.50701-1_all.deb
sudo apt install ./amdgpu-install_5.7.50701-1_all.deb
sudo amdgpu-install --usecase=graphics,rocm
sudo usermod -aG video $USER
sudo usermod -aG render $USER
mkdir stable-diffusion
cd stable-diffusion || return
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui || return
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
pip3 uninstall torch torchvision
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
cd ..
echo "Do you have a low end GPU? [y/n]"
read hasLowEndGpu
if [ "$hasLowEndGpu" == "y" ]; then
  echo '#!/bin/sh

source venv/bin/activate

export HSA_OVERRIDE_GFX_VERSION=11.0.0
export HIP_VISIBLE_DEVICES=0
export PYTORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.8,max_split_size_mb:512

python3 launch.py --listen --enable-insecure-extension-access --opt-sdp-attention --no-half --precision full --upcast-sampling --no-half-vae --medvram --theme dark' > run-stable-diffusion.sh
  fi

if [ "$hasLowEndGpu" == "n" ]; then
  echo '#!/bin/sh

source venv/bin/activate

export HSA_OVERRIDE_GFX_VERSION=11.0.0
export HIP_VISIBLE_DEVICES=0
export PYTORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.8,max_split_size_mb:512

python3 launch.py --listen --enable-insecure-extension-access --opt-sdp-attention --theme dark' > run-stable-diffusion.sh
  fi