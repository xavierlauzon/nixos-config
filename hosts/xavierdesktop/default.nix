{ config, inputs, pkgs, lib, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    application = {
      firejail.enable = true;
    };
    container = {
      #socket-proxy.enable = true;
      #traefik = {
      #  enable = false;
      #  logship = "false";
      #  monitor = "false";
      #};
      #traefik-internal = {
      #  enable = true;
      #  logship = "false";
      #  monitor = "false";
      #};
    };
    feature = {
      graphics = {
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
    };
    filesystem = {
    };
    hardware = {
      cpu = "amd";
      gpu.type = "amd";
      printing.enable = false;
      raid.enable = true;
    };
    network = {
      dns = {
        servers = [ "192.168.2.5" ];
        hostname = "xavierdesktop";
      };
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1 = {
          mac = "10:ff:e0:3a:3f:e6";
        };
      };
      bridges = {
        br0 = {
          interfaces = [ "eno1" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.2.10/22" ];
            gateway = "192.168.0.1";
          };
        };
      };
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "8d1c312afa3be618" # LM
            "e5cd7a9e1cfbc9a8"
            "dade4211851dff13" #im
            "dade421185de795d" #is
          ];
        };
      };
    };
    role = "desktop";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
  programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
  hardware.amdgpu.overdrive.enable = true;
  programs.nix-ld.enable = true;

  # Simple virtual audio routing using pw-loopback
  systemd.user.services.virtual-audio-sink = {
    description = "Virtual Audio Sink";
    after = [ "pipewire.service" ];
    requires = [ "pipewire.service" ];
    wantedBy = [ "pipewire.service" ];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "3";
      ExecStart = "${pkgs.pipewire}/bin/pw-loopback --name='Virtual Audio Sink' --capture-props='media.class=Audio/Sink node.name=VirtualSink node.description=\"Virtual Audio Sink\"' --playback-props='node.target=alsa_output.usb-Schiit_Audio_Schiit_Modi_3E-00.pro-output-0 node.description=\"Music Output\"'";
    };
  };

  # Virtual microphone mixing: Application audio + Yeti microphone
  services.pipewire.extraConfig.pipewire."10-virtual-microphone" = {
    "context.modules" = [
      # Create a mixer sink for combining audio sources
      {
        "name" = "libpipewire-module-loopback";
        "args" = {
          "node.description" = "Virtual Microphone Mixer";
          "capture.props" = {
            "node.name" = "VirtualMicrophoneMixer";
            "media.class" = "Audio/Sink";
            "audio.position" = [ "FL" "FR" ];
            "node.description" = "Virtual Microphone Mixer";
          };
          "playback.props" = {
            "node.name" = "VirtualMicrophone";
            "media.class" = "Audio/Source";
            "node.description" = "Virtual Microphone";
          };
        };
      }
      # Route VirtualSink monitor to mixer
      {
        "name" = "libpipewire-module-loopback";
        "args" = {
          "node.description" = "App Audio to Virtual Mic";
          "capture.props" = {
            "node.name" = "app-audio-capture";
            "node.target" = "VirtualSink";
            "stream.capture.sink" = true;
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "app-audio-to-mixer";
            "node.target" = "VirtualMicrophoneMixer";
            "node.passive" = true;
          };
        };
      }
      # Route Yeti Nano to mixer
      {
        "name" = "libpipewire-module-loopback";
        "args" = {
          "node.description" = "Yeti Audio to Virtual Mic";
          "capture.props" = {
            "node.name" = "yeti-audio-capture";
            "node.target" = "alsa_input.usb-Blue_Microphones_Yeti_Nano_8846B12471040506-00.analog-stereo";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "yeti-audio-to-mixer";
            "node.target" = "VirtualMicrophoneMixer";
            "node.passive" = true;
          };
        };
      }
    ];
  };

  # WirePlumber rules to ensure proper device behavior
  services.pipewire.wireplumber.extraConfig."52-virtual-microphone-rules" = {
    "monitor.alsa.rules" = [
      {
        "matches" = [
          { "node.name" = "VirtualMicrophone"; }
        ];
        "actions" = {
          "update-props" = {
            "node.pause-on-idle" = false;
            "session.suspend-timeout-seconds" = 0;
          };
        };
      }
    ];
  };
}
