# Step 1: Enable IOMMU in the Linux kernel
echo "Enabling IOMMU in the Linux kernel..."

# Edit GRUB config to enable IOMMU (intel_iommu=on for Intel)
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"/' /etc/default/grub

# Rebuild GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot system to apply changes
echo "Rebooting system for IOMMU changes to take effect..."
sudo reboot

# Check IOMMU is enabled
echo "Checking if IOMMU is enabled..."
dmesg | grep -e DMAR -e IOMMU

# Step 2: Check IOMMU groups and GPU PCI device
echo "Checking PCI devices and IOMMU groups..."
sudo pacman -S pciutils
for d in /sys/kernel/iommu_groups/*/devices/*; do
  echo -n "$d: "; lspci -nns ${d##*/};
done

# Step 3: Blacklist Nvidia driver and bind GPU to VFIO
echo "Blacklisting the Nvidia driver and binding GPU to VFIO..."

# Blacklist Nvidia and Nouveau drivers
echo -e "blacklist nouveau\nblacklist nvidia" | sudo tee /etc/modprobe.d/blacklist-nvidia.conf

# Create VFIO conf for Nvidia GPU (replace with your GPU device IDs)
echo "options vfio-pci ids=10de:1e04,10de:10f0" | sudo tee /etc/modprobe.d/vfio.conf

# Regenerate initramfs
sudo mkinitcpio -P

# Reboot to apply VFIO changes
echo "Rebooting system to apply VFIO bindings..."
sudo reboot

# Step 4: Install necessary packages for QEMU, KVM, Virt-Manager
echo "Installing QEMU, KVM, Virt-Manager, and related packages..."
sudo pacman -S qemu virt-manager virt-viewer libvirt edk2-ovmf

# Enable and start libvirtd service
sudo systemctl enable --now libvirtd

# Add user to libvirt group (replace with your username if needed)
sudo usermod -aG libvirt $(whoami)

# Step 5: Launch Virt-Manager and create the VM
echo "Launching Virt-Manager..."
virt-manager &

# Manual steps:
# 1. In Virt-Manager, create a new virtual machine, select Windows ISO.
# 2. Configure RAM, CPU, and Disk for the VM.
# 3. Add a "PCI Host Device" for the Nvidia GPU.
# 4. Enable UEFI boot by adding an OVMF firmware option if needed.
# 5. Start the VM and proceed with Windows installation.

# Step 6: Enable PCIe ACS override (if needed)
echo "Enabling PCIe ACS override for better IOMMU grouping..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on pcie_acs_override=downstream,multifunction"/' /etc/default/grub

# Rebuild GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot system to apply changes
echo "Rebooting system for PCIe ACS override..."
sudo reboot

# Step 7: Install Nvidia drivers on Windows VM (after installation)

echo "Now you can install the Nvidia drivers on the Windows VM and complete the setup!"

