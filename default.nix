{ ... }:

{
  imports = [
    ./common/cpu/amd
    ./common/gpu/nvidia/prime.nix
    #./common/gpu/amd
    #../../../common/pc/laptop
    #../../../common/pc/ssd
  ];

  # fixes mic mute button
  #services.udev.extraHwdb = ''
  #  evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
 #    KEYBOARD_KEY_ff31007c=f20
 # '';
}
