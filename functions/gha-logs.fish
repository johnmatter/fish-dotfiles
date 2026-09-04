function gha-logs
  set -l repo $argv[1]
  set -l run_id $argv[2]

  if not string match -q '*/*' $repo
    echo "Error: repo must be in 'owner/repo' format"
    return 1
  end

  set -l repo_slug (string replace '/' '-' $repo)
  set -l outdir "github-actions-$repo_slug-$run_id"

  mkdir -p $outdir
  if not gh api repos/$repo/actions/runs/$run_id/logs > $outdir/logs.zip 2>/dev/null
    echo "Error: failed to fetch logs (check repo name and run ID)"
    rm -rf $outdir
    return 1
  end

  unzip -q $outdir/logs.zip -d $outdir
  rm $outdir/logs.zip

  echo "Logs extracted to $outdir/"
end
