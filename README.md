**Install relic:**
```
git clone git@github.com:relic-toolkit/relic.git
cd relic
mkdir -p relic-target
cd relic-target
../preset/x64-pbc-bls12-381.sh ../
make -j 8
sudo make install
```

**Build pii:**
```

cd PII
make -j8 pii.x 
```

## Running benchmarks

Run the two parties:

` ./pii.x -p 0 -I 10`

` ./pii.x -p 1 -I 10`