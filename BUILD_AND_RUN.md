```bash
git clone https://github.com/thu-pacman/UniQ.git --recursive
cd UniQ/third-party/hptt/ && make # build third-party/hptt/lib/libhptt.a and libhptt.so
cd ../../../UniQ/
CXX=g++-10 cmake . -DHARDWARE=cpu -DLOCAL_QUBIT_SIZE=15 # The default local qubit size is 10, which results in very slow performance.
make
./main input.qasm
```