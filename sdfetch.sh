#!/bin/bash

set -e

# Set your model download URL here
MODEL_URL="https://huggingface.co/AnythingV3/anything-v3.ckpt"  # Change this URL to your specific model's URL
MODEL_NAME="anything-v3.ckpt"

echo "[*] Updating system..."
sudo pacman -Syu --noconfirm

echo "[*] Installing dependencies..."
sudo pacman -S --noconfirm git python python-pip cmake gcc make wget unzip \
    ffmpeg libgl python-virtualenv nvidia nvidia-utils nvidia-settings cuda cudnn

echo "[*] Cloning stable-diffusion-webui..."
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

echo "[*] Creating models directory..."
mkdir -p models/Stable-diffusion

# Download the model
echo "[*] Downloading model from $MODEL_URL..."
wget -O "models/Stable-diffusion/$MODEL_NAME" $MODEL_URL

echo "[*] Done. The model has been downloaded to models/Stable-diffusion/$MODEL_NAME"
echo "[*] You can replace it with any other model if desired."

echo "[*] Launching Web UI..."
./webui.sh