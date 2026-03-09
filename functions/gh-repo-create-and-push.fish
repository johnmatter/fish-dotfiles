function gh-repo-create-and-push
  test (count $argv) -ge 1; or begin; echo "Usage: gh-init <repo-name> [--private]"; return 1; end
  set -l vis --public
  contains -- --private $argv; and set vis --private
  echo "Will create $vis GitHub repo '$argv[1]', add as origin, and push."
  read -P "Continue? [y/N] " -l confirm
  string match -qi y $confirm; or return
  gh repo create $argv[1] --source=. $vis --push
end
