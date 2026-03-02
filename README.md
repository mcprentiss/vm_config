# vm_config


- Change name of VM  
sudo hostnamectl set-hostname colin  

- Cuda  
  
1. Install the Prerequisites  
First, ensure you have the necessary compiler and Linux headers installed so CUDA can build its modules.  
    
   sudo apt update    
   sudo apt install build-essential linux-headers-$(uname -r)  
  
2. Add the NVIDIA CUDA Repository  
Instead of downloading a massive .run file, use NVIDIA's cuda-keyring. This hooks directly into apt so you get future updates naturally.  
   
   wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb  
   sudo dpkg -i cuda-keyring_1.1-1_all.deb  
   sudo apt update  
   Note: If you are on Ubuntu 22.04, simply change the ubuntu2404 part of that URL to ubuntu2204

3. Install the Toolkit (The Crucial Step)    
Do not run sudo apt install cuda. That is a "metapackage" that bundles both the toolkit and the newest NVIDIA display driver, which often causes conflicts.  
  
   Instead, tell apt you only want the developer tools:  
  
   sudo apt install cuda-toolkit  

4. Update Your Environment Variables  
   CUDA installs itself into /usr/local/cuda, but your system doesn't know to look there yet. You need to add it to your path.  

   Open your shell config (like ~/.bashrc or ~/.zshrc):  
  
   Add these lines to the very bottom of the file  
   export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}  
   export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}  
   Save the file, and then apply the changes immediately with:  
   source ~/.bashrc  # or ~/.zshrc  

5. Verify the Installation  
   To make sure the compiler is installed and your path is correct, run:
   nvcc --version  

- rust - curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

- julia - curl -fsSL https://install.julialang.org | sh

- fonts - https://github.com/chriskempson/base16-shell  
                                                                               
- dasht - https://github.com/sunaku/dasht
