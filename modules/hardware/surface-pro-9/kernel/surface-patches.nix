{ fetchFromGitHub, ... }:
let
  linuxSurface = fetchFromGitHub {
    owner = "linux-surface";
    repo = "linux-surface";
    rev = "b49ed6d04df91cd9e88f0f726535dd221dde67fa";
    hash = "sha256-wGsSm8wCxfv+nXX2FCrxIOBQTAs5z+RnLscf/7PrTJs=";
  };
in map (pname: {
  name = "linux-surface-${pname}";
  patch = (linuxSurface + "/patches/6.6/${pname}.patch");
}) [
  "0004-ipts"
  "0005-ithc"
  "0006-surface-sam"
  "0009-surface-typecover"
  "0010-surface-shutdown"
  "0011-surface-gpe"
  "0014-rtc"
]
