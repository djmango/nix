# btop that draws the host's NVIDIA GPUs on any Linux host.
#
# btop finds GPUs by dlopen()ing libnvidia-ml.so.1 when it starts. The Nix build
# searches only its own glibc and gcc directories, so on a host whose driver
# lives outside Nix (Debian, Ubuntu, Fedora, Arch, WSL, or NixOS's
# /run/opengl-driver) the library is never found and btop draws no GPU at all.
#
# Putting the host's lib directory on LD_LIBRARY_PATH is not the fix: the loader
# then takes that directory's libc.so.6 ahead of the Nix glibc btop was linked
# against, and btop segfaults. So the wrapper exposes ONE file. Each candidate
# driver directory below gets a store directory holding a single link named
# libnvidia-ml.so.1, and the wrapper puts only the first one whose target exists
# on LD_LIBRARY_PATH. The driver library needs nothing but glibc, which btop has
# already loaded. A host with no NVIDIA driver runs btop exactly as before.
#
# On a host with 1 to 4 NVIDIA GPUs the wrapper also picks the richest layout
# that fits the window, GPU panels first, and writes it to shown_boxes before
# btop starts. btop's own size check is not enough: with cpu, mem, net, proc and
# four GPU panels it accepts 72 to 75 rows and then draws nothing. The row
# counts below are the smallest that drew every GPU panel on btop 1.4.7. A GPU
# panel is a fixed 12 rows; re-measure them when btop's minor version moves.
# Keys 1 to 4 and 5 to 8 still toggle boxes once btop is open.
{ lib, btop, runCommand, symlinkJoin, writeShellApplication, coreutils, gnugrep, gnused }:

let
  # Where a host's driver installs libnvidia-ml.so.1, most specific first.
  driverDirs = [
    "/run/opengl-driver/lib" # NixOS
    "/usr/lib/x86_64-linux-gnu" # Debian, Ubuntu
    "/usr/lib/aarch64-linux-gnu"
    "/usr/lib64" # Fedora, RHEL
    "/usr/lib" # Arch
    "/usr/lib/wsl/lib" # WSL 2
  ];

  nvmlLinks = runCommand "btop-nvml-links" { } (
    "mkdir $out\n"
    + lib.concatImapStrings (i: dir: ''
      mkdir $out/${toString i}
      ln -s ${dir}/libnvidia-ml.so.1 $out/${toString i}/libnvidia-ml.so.1
    '') driverDirs
  );

  findNvml = lib.concatImapStrings (i: dir: ''
    if [ -z "$nvml" ] && [ -e ${dir}/libnvidia-ml.so.1 ]; then nvml=${nvmlLinks}/${toString i}; fi
  '') driverDirs;

  measured = "1.4";

  wrapper = writeShellApplication {
    name = "btop";
    text = ''
      nvml=""
      ${findNvml}
      if [ -n "$nvml" ]; then
        export LD_LIBRARY_PATH="$nvml''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      fi

      # Prints the shown_boxes for a window of $1 rows by $2 columns with $3
      # GPUs, or nothing to leave the config as it is.
      fit_boxes() {
        local rows=$1 cols=$2 n=$3 g="" i full
        case $n in
          1) full=36 ;;
          2) full=48 ;;
          3) full=61 ;;
          4) full=76 ;;
          *) return 0 ;;
        esac
        for ((i = 0; i < n; i++)); do g="$g gpu$i"; done
        g=''${g# }
        if [ "$cols" -lt 80 ]; then echo "cpu mem net proc"
        elif [ "$rows" -ge "$full" ]; then echo "cpu mem net proc $g"
        elif [ "$rows" -ge $((12 * n + 16)) ]; then echo "$g proc"
        elif [ "$rows" -ge $((12 * n + 8)) ]; then echo "cpu $g"
        elif [ "$rows" -ge $((12 * n)) ]; then echo "$g"
        else echo "cpu mem net proc"
        fi
      }

      own_config=""
      for arg in "$@"; do
        case $arg in -c | --config | --config=*) own_config=1 ;; esac
      done

      # The layout is a convenience: nothing here may stop btop from starting,
      # and a config that home-manager links in from the store is left alone.
      shopt -s nullglob
      gpus=(/dev/nvidia[0-9]*)
      conf=''${XDG_CONFIG_HOME:-$HOME/.config}/btop/btop.conf
      size=""
      if [ -n "$nvml" ] && [ -z "$own_config" ] && [ -t 1 ] && [ ''${#gpus[@]} -gt 0 ] && [ ! -L "$conf" ]; then
        size=$(${coreutils}/bin/stty size </dev/tty 2>/dev/null) || size=""
      fi
      if [[ $size =~ ^[1-9][0-9]*\ [1-9][0-9]*$ ]]; then
        boxes=$(fit_boxes "''${size% *}" "''${size#* }" "''${#gpus[@]}")
        if [ -z "$boxes" ]; then :
        elif [ -f "$conf" ] && ${gnugrep}/bin/grep -q '^shown_boxes = ' "$conf"; then
          ${gnused}/bin/sed -i "s/^shown_boxes = .*/shown_boxes = \"$boxes\"/" "$conf" || :
        else
          { ${coreutils}/bin/mkdir -p "''${conf%/*}" && printf 'shown_boxes = "%s"\n' "$boxes" >>"$conf"; } 2>/dev/null || :
        fi
      fi

      exec -a btop ${btop}/bin/btop "$@"
    '';
  };
in
lib.warnIf (lib.versions.majorMinor btop.version != measured)
  "btop ${btop.version}: the GPU layout rows in overlays/btop-package.nix were measured on ${measured}; re-measure them."
  (symlinkJoin {
    name = "btop-${btop.version}";
    inherit (btop) version;
    paths = [ btop ];
    postBuild = ''
      rm $out/bin/btop
      ln -s ${wrapper}/bin/btop $out/bin/btop
    '';
    passthru.unwrapped = btop;
    meta = btop.meta // { mainProgram = "btop"; };
  })
