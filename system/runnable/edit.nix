#!/run/current-system/sw/bin/env /run/current-system/sw/bin/bash

TIMESTAMP=$(date --rfc-3339=ns)

cd /copycat
nvim /copycat/nixos/default.nix

git add -A

RESULT="fail"
nh os switch
[[ $? -eq 0 ]] && RESULT="pass"

GENERATIONS=$(nixos-rebuild --flake /copycat/nixos#copycat list-generations)

COMMIT_MSG=$(cat <<- EOF
 .copycat. [$RESULT] [$TIMESTAMP]

$GENERATIONS

    へ
（• ˕ •マ
   ~mew.
EOF

)
git commit -m "$COMMIT_MSG"
sudo git push
