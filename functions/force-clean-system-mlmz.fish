function force-clean-system-mlmz
  sudo rm -rf \
    /usr/local/include/manzanita/ \
    /usr/local/include/madronalib/ \
    /usr/local/include/clap/ \
    /usr/local/lib/libmadrona.a \
    /usr/local/lib/libmanzanita.a \
    /usr/local/lib/libmadrona-debug.a \
    /usr/local/lib/libmanzanita-debug.a \
    /usr/local/lib/cmake/madronalib \
    /usr/local/lib/cmake/manzanita/ \
    /usr/local/lib/cmake/clap/
end
