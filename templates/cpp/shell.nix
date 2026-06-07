pkgs:

pkgs.mkShell {
  packages = with pkgs; [
    # Build toolchain
    cmake
    ninja
    pkg-config
    doxygen
    autoconf
    automake
    libtool
    bison

    # Common C++ libraries
    eigen
    boost
    tbb
    protobuf
    fmt
    spdlog
    nlohmann_json
    rapidjson
    tinyxml-2
    yaml-cpp

    # Numerics / optimization (Ceres/SfM stacks)
    ceres-solver
    glog
    gflags
    suitesparse

    # Computer vision / 3D (uncomment what a project needs)
    # opencv
    # pcl
    # colmap
    # open3d
    # assimp
    # flann

    # Robotics (uncomment what a project needs)
    # urdfdom
    # console-bridge
    # octomap
    # ompl
    # dartsim

    # CAD
    # opencascade-occt

    # GUI / Qt (uncomment what a project needs)
    # qt6.full
    # qt6.qtbase
  ];

  shellHook = ''
    echo "C++ dev shell: $(${pkgs.cmake}/bin/cmake --version | head -n1)"
  '';
}
