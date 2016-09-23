#!/usr/bin/env bash


cd ..

echo start to packge

python setup.py sdist

pip uninstall dagobah
pip install dist/dagobah-0.3.3.tar.gz