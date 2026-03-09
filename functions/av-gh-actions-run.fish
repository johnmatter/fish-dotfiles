function av-gh-actions-run
  gh workflow run build.yml \
    --repo madrona-labs/aaltoverb \
    --ref clap-migration \
    -f madronalib-version=linux-20251209 \
    -f manzanita-version=linux-20251209
end
