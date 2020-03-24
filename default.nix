{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
  fetchAndBuildMix = { pkg, version, sha256, beamDeps ? [] }: pkgs.beamPackages.buildMix {
    name = pkg;
    version = version;
    inherit beamDeps;

    src = beamPackages.fetchHex {
      pkg = pkg;
      version = version;
      sha256 = sha256;
    };
  };

  ace = fetchAndBuildMix {
    pkg = "ace";
    version = "0.18.10";
    sha256 = "13w5i6hmc5kwai50z7big173qwxl8bcfx43nd6f794ifr4r4k6bk";
    beamDeps = [hpack_erl raxx];
  };

  asciichart = fetchAndBuildMix {
    pkg = "asciichart";
    version = "1.0.0";
    sha256 = "1qif3xrvnaqcbzlj73lizhr5qj2k3yy4swgs229mj5ykrpj7bi7d";
  };

  raxx = fetchAndBuildMix {
    pkg = "raxx";
    version = "1.1.0";
    sha256 = "0inbv4zszwlgx7lvv27n4dv1lh94nrrf79r9f7z0v29746vc9zaq";
  };

  hpack_erl = beamPackages.buildRebar3 {
    name = "hpack_erl";
    version = "0.2.3";

    src = beamPackages.fetchHex {
      pkg = "hpack_erl";
      version = "0.2.3";
      sha256 = "0fmjrdwk6lhni2rc3bmf3xbnvfivr5ng638455j8m2sbghb81x86";
    };
  };

  elixir_make = fetchAndBuildMix {
    pkg = "elixir_make";
    version = "0.6.0";
    sha256 = "0l7017ai8nrfnifab99628q1qnwhdcxfgpxjzk0b9w5pjddnj8nm";
  };

  ex_termbox = pkgs.beamPackages.buildMix rec {
    name = "ex_termbox";
    version = "1.0.0";

    src = beamPackages.fetchHex {
      pkg = name;
      version = version;
      sha256 = "1z3yzxr3bqm7cdkgmzp0rmma3sci5lwq9wy963l6yy4dka5cx030";
    };

    postPatch = ''
      substituteInPlace mix.exs \
        --replace "compilers: [:elixir_make | Mix.compilers()]," ""
    '';

    beamDeps = [ elixir_make termbox];
  };

  ratatouille = fetchAndBuildMix {
    pkg = "ratatouille";
    version = "0.5.0";
    sha256 = "018dlv33cgf39ccb2p6ydx5kk18z2i79l3qsqkn1i5fqkhhckkfq";
    beamDeps = [asciichart ex_termbox];
  };

  jason = fetchAndBuildMix {
    pkg = "jason";
    version = "1.1.2";
    sha256 = "1zispkj3s923izkwkj2xvaxicd7m0vi2xnhnvvhkl82qm2y47y7x";
  };

  mime = fetchAndBuildMix {
    pkg = "mime";
    version = "1.3.1";
    sha256 = "1wbmp3rsdac4yznahr76712vdkjb41ilrgri14da798cd8fpdgkc";
  };

  tesla = fetchAndBuildMix {
    pkg = "tesla";
    version = "1.2.1";
    sha256 = "1jprxr98v8gfhdd8wrkx9zcmy1gac38iia5ryg8mx5c8g9xjgiyg";
    beamDeps = [mime];
  };

  logger_file_backend = fetchAndBuildMix {
    pkg = "logger_file_backend";
    version = "0.0.11";
    sha256 = "0ig4smb76a6pb560y0ns9q52rrbs5qza365wlaq64k340ipq5gk2";
  };

  porcelain = fetchAndBuildMix {
    pkg = "porcelain";
    version = "2.0.3";
    sha256 = "081ns89r0mi41ixifib23bm50ph6ff3apiw7qw99kh6vzaw6m6fw";
  };
in
beamPackages.buildMix rec {
  name = "tefter-cli-${version}";
  version = "v0.2.0";

  src = fetchFromGitHub {
    owner = "tefter";
    repo = "cli";
    rev = "${version}";
    sha256 = "0bwm3x6nr43hxw6ya1sr8c8h82z0b9f6x9a96316qpz1y268dz70";
  };

  beamDeps = [
    porcelain
    ace
    ratatouille
    jason
    tesla
    erlang
    logger_file_backend
  ];

  buildPhase = ''
    export HEX_OFFLINE=1
    export HEX_HOME=`pwd`
    export MIX_ENV=prod
    export MIX_NO_DEPS=1

    mix deps
    mix escript.build --no-deps-check
  '';

  installPhase = ''
    mkdir -p $out/bin
  '';
}
